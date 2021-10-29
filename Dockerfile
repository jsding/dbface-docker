# DbFace On-premises
#
# VERSION 10 (20211029)

FROM php:7.4-alpine

RUN apk add --no-cache wget

RUN apk add --no-cache php7-imap && \
  mkdir -p setup && cd setup && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube.tar.gz && \
  tar -xf ioncube.tar.gz && \
  mv ioncube/ioncube_loader_lin_7.2.so /usr/lib/php7/modules/ && \
  echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_7.2.so' >  /etc/php7/conf.d/00-ioncube.ini && \
  cd .. && rm -rf setup
    

RUN wget https://dbface.oss-us-east-1.aliyuncs.com/v9/dbface_php7.2.zip -O /tmp/dbfacephp.zip && unzip -d /var/www/html /tmp/dbfacephp.zip && rm /tmp/dbfacephp.zip

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/user
