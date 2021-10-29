#!/bin/bash -e
set -e

# start the cronjob
crond -l 2 -f

# Start Apache in foreground
/usr/sbin/apache2 -DFOREGROUND
