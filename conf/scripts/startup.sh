#!/bin/bash
chown -R www-data:www-data /var/www/user
/usr/bin/supervisord -n
