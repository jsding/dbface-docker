# DbFace On-premises
#
# VERSION 10 (20211029)

FROM php:7.4-alpine

RUN apk update && apk add bash dcron curl wget rsync ca-certificates && rm -rf /var/cache/apk/*

# Setup GD extension
RUN apk add --no-cache \
      freetype \
      libjpeg-turbo \
      libpng \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && docker-php-ext-configure gd \
      --with-freetype=/usr/include/ \
      --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && rm -rf /tmp/*

RUN apk add libzip-dev

RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql zip bcmath 

RUN apk add --no-cache php7-imap && \
  mkdir -p setup && cd setup && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube.tar.gz && \
  tar -xf ioncube.tar.gz && \
  mv ioncube/ioncube_loader_lin_7.2.so /usr/lib/php7/modules/ && \
  echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_7.2.so' >  /etc/php7/conf.d/00-ioncube.ini && \
  cd .. && rm -rf setup
    
ADD conf/000-default /etc/apache2/sites-enabled/000-default.conf

RUN wget https://dbface.oss-us-east-1.aliyuncs.com/v9/dbface_php7.2.zip -O /tmp/dbfacephp.zip && unzip -d /var/www/html /tmp/dbfacephp.zip && rm /tmp/dbfacephp.zip

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/user

# set up cronjob
# steup crontab 5min
# Add crontab file in the cron directory
COPY conf/dbface /var/spool/cron/crontabs/root

# Create the log file to be able to run tail
RUN touch /var/www/html/user/logs/cronlog.log

EXPOSE 80

COPY conf/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

CMD ["/bin/bash", "/usr/bin/docker-entrypoint.sh"]

