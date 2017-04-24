#!/bin/sh
# $1: nodename $2: container port (start from 10001)
# step1: download the latest zip file
# step2: unzip the file and copy user and config directory
#        to /data/dbface/$1
# step3: sudo docker pull dbface/dbface-docker
# step4: sudo docker run -d -p $2:80 --name $1 -v /data/dbface/$1/config:/var/www/config -v /data/dbface/$1/user:/var/www/user -t dbface/docker
if [ -z "$1" ];then
  echo "please input the node name"
  exit
fi

if [ -z "$2" ];then
  echo "please input the node port"
  exit
fi
mkdir /data/dbface
mkdir /data/dbface/$1
wget https://s3-ap-southeast-1.amazonaws.com/download-dbface/v7/dbface-template.zip -O /tmp/dbface-template.zip
unzip -d /data/dbface/$1 /tmp/dbface-template.zip 
chmod -R 777 /data/dbface/$1/user
chmod -R 777 /data/dbface/$1/config
rm /tmp/dbface-template.zip
sudo docker pull dbface/dbface-docker
sudo docker run -d -p $2:80 --name $1 -v /data/dbface/$1/config:/var/www/config -v /data/dbface/$1/user:/var/www/user -t dbface/dbface-docker