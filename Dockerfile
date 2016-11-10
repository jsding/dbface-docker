# DbFace On-premise
#
# VERSION 6.3 (20161110 17:07)

FROM ubuntu:16.04

MAINTAINER DbFace "support@dbface.com"

# Upgrade system
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
RUN apt-get update

# Setup system and install tools
RUN apt-get -qqy install passwd supervisor sudo unzip wget curl

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
RUN apt-get -qqy install php7.0 php7.0-cli php7.0-mysql php7.0-sqlite php7.0-interbase php7.0-pgsql php7.0-curl php7.0-gd libapache2-mod-php7.0

# Download ioncube loader
RUN cd /var/www/html && \
    wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxvf ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz && \
    echo "zend_extension = /var/www/html/ioncube/ioncube_loader_lin_7.0.so" > /etc/php/7.0/apache2/php.ini

RUN rm -rf /var/www/index.html
RUN wget https://s3.amazonaws.com/dbface/v6/dbface_php5.6.zip -O /tmp/dbfacephp.zip && unzip -d /var/www /tmp/dbfacephp.zip && rm /tmp/dbfacephp.zip

RUN mkdir -p /var/www/application/cache && \
    mkdir -p /var/www/application/logs && \
    mkdir -p /var/www/user && \
    chmod -R 777 /var/www/application/cache && \
    chmod -R 777 /var/www/application/logs && \
    chmod -R 777 /var/www/user && \
    chmod -R 777 /var/www/config/ && \
    chmod 777 /var/www/config/dbface.db

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
    
VOLUME /var/www
EXPOSE 22 80 443

CMD ["/bin/bash", "/usr/bin/startup_container"]
