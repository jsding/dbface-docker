# DbFace On-premises
#
# VERSION 9.3 (20200621)

FROM ubuntu:18.04

# Upgrade system
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
RUN apt-get update

# Setup system and install tools
RUN apt-get update && apt-get -qqy install passwd supervisor sudo unzip wget curl cron apt-transport-https gnupg2

RUN apt-get -qqy install software-properties-common

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get -qqy update

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get -qqy install mssql-tools

# add msssql-tools to path 
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN sudo apt-get -qqy install unixodbc-dev

# Setup ssh
RUN apt-get -qqy install openssh-server
RUN mkdir -p /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:root' | chpasswd

# Generate a host key before packing.
RUN service ssh start; service ssh stop

# Create SSL cert
RUN mkdir /root/ssl; \
    openssl genrsa -out /root/ssl/local.key 1024; \
    openssl req -new -key /root/ssl/local.key -out /root/ssl/local.csr -subj "/C=DE/ST=BW/L=FREIBURG/O=Jankowfsky AG/OU=Development/CN=localhost"; \
    openssl x509 -req -days 365 -in /root/ssl/local.csr -signkey /root/ssl/local.key -out /root/ssl/local.crt

# Install apache
RUN apt-get -qqy install apache2 apache2-utils
RUN a2enmod rewrite
RUN a2enmod ssl
RUN mkdir -p /etc/apache2/conf.d/
RUN echo "ServerName localhost" | tee /etc/apache2/conf.d/fqdn
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ADD conf/apache/000-default /etc/apache2/sites-enabled/000-default.conf

# Install php
RUN add-apt-repository ppa:ondrej/php
RUN apt-get -qqy install php-pear php7.2 mcrypt  php7.2-dev php7.2-cli php7.2-mysql php7.2-sqlite php7.2-interbase php7.2-pgsql php7.2-curl php7.2-mbstring php7.2-gd php7.2-xml libapache2-mod-php7.2

RUN apt-get -qqy install libssl-dev pkg-config libaio-dev

# MongoDB support
RUN pecl install mongodb && \
    echo "extension=mongodb.so" >> /etc/php/7.2/cli/php.ini && \
    echo "extension=mongodb.so" >> /etc/php/7.2/apache2/php.ini
    
# install sqlsrv
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php7.2

# SQL Server Support
# add extension info to ini files
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/30-pdo_sqlsrv.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/20-sqlsrv.ini

RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.2/cli/conf.d/30-pdo_sqlsrv.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.2/cli/conf.d/20-sqlsrv.ini

# install locales (sqlcmd will have a fit if you don't have this)
RUN apt-get install -y locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Install Oracle Instantclient
# not enable oracle defautly

# Download ioncube loader
RUN cd /var/www/html && \
    wget http://s3-ap-southeast-1.amazonaws.com/download-dbface/ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxvf ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz && \
    echo "zend_extension = /var/www/html/ioncube/ioncube_loader_lin_7.2.so" >> /etc/php/7.2/apache2/php.ini && \
    echo "zend_extension = /var/www/html/ioncube/ioncube_loader_lin_7.2.so" >> /etc/php/7.2/cli/php.ini
    

RUN rm -rf /var/www/index.html
RUN wget https://dbface.oss-us-east-1.aliyuncs.com/v9/dbface_php7.2.zip -O /tmp/dbfacephp.zip && unzip -d /var/www /tmp/dbfacephp.zip && rm /tmp/dbfacephp.zip

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www/user 

# crontab
# steup crontab 5min
# Add crontab file in the cron directory
ADD conf/dbface /etc/cron.d/dbface

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/dbface

# Create the log file to be able to run tail
RUN touch /var/log/cronlog.log

# Run
# Add supervisor config
ADD conf/supervisor/startup.conf /etc/supervisor/conf.d/startup.conf

ADD conf/scripts/startup.sh /usr/bin/startup_container
RUN chmod +x /usr/bin/startup_container

# Cleanup
RUN apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get autoremove -y; \
    rm -rf /var/www/index.html; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
    
EXPOSE 22 80 443

CMD ["/bin/bash", "/usr/bin/startup_container"]
