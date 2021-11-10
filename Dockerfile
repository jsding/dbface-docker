# DbFace On-premises
#
# VERSION 10 (20211110)
FROM ubuntu:20.04

# Upgrade system
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Setup system and install tools
RUN apt-get update && apt-get -qqy install passwd sudo unzip wget curl cron apt-transport-https gnupg2

# Install nodejs environment
RUN apt-get -qqy install nodejs npm

# Install apache
RUN apt-get -qqy install apache2
RUN a2enmod rewrite
RUN a2enmod ssl
RUN mkdir -p /etc/apache2/conf.d/

RUN echo "ServerName localhost" | tee /etc/apache2/conf.d/fqdn
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ADD conf/apache/000-default /etc/apache2/sites-enabled/000-default.conf

# Install php
RUN apt-get -qqy install php-pear php mcrypt php-dev php-cli php-mysql php-sqlite3 php-interbase php-pgsql php-curl php-mbstring php-gd php-xml php-bcmath php-zip libapache2-mod-php

RUN apt-get -qqy install libssl-dev pkg-config libaio-dev

# MongoDB support
RUN pecl install mongodb && echo "extension=mongodb.so" >> /etc/php/7.4/cli/php.ini && echo "extension=mongodb.so" >> /etc/php/7.4/apache2/php.ini
    
# install sqlsrv
# RUN pecl install sqlsrv
# RUN pecl install pdo_sqlsrv

RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php7.4

# SQL Server Support
# add extension info to ini files
# RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.4/apache2/conf.d/30-pdo_sqlsrv.ini
# RUN echo "extension=sqlsrv.so" >> /etc/php/7.4/apache2/conf.d/20-sqlsrv.ini

# RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.4/cli/conf.d/30-pdo_sqlsrv.ini
# RUN echo "extension=sqlsrv.so" >> /etc/php/7.4/cli/conf.d/20-sqlsrv.ini

# install locales (sqlcmd will have a fit if you don't have this)
RUN apt-get install -y locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Download ioncube loader
RUN cd /var/www/html && \
    wget https://dbface.oss-us-east-1.aliyuncs.com/ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxvf ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz && \
    echo "zend_extension = /var/www/html/ioncube/ioncube_loader_lin_7.4.so" >> /etc/php/7.4/apache2/php.ini && \
    echo "zend_extension = /var/www/html/ioncube/ioncube_loader_lin_7.4.so" >> /etc/php/7.4/cli/php.ini
    
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
RUN touch /var/www/user/logs/cronlog.log

# Run
ADD conf/scripts/startup.sh /usr/bin/startup_container
RUN chmod +x /usr/bin/startup_container

# Cleanup
RUN apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get autoremove -y; \
    rm -rf /var/www/index.html; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
    
EXPOSE 80

CMD ["/bin/bash", "/usr/bin/startup_container"]
