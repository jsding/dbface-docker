# What is DbFace?

DbFace is a super easy reports and dashboards builder for MySQL, PostgreSQL, SQL Server, MongoDB databases. 

You can also make your own API Connector to make DbFace work with any application data sources.

DbFace connects to your database and pull down data from it and show you chart reports, dashboards, storyboards.

This repository helps you install DbFace in docker container.

Please get more information from:

* Website: https://www.dbface.com
* Facebook: https://www.facebook.com/dbface
* Twitter: https://www.twitter.com/dbface
* Documentation: https://docs.dbface.com/
* Manual Installation: https://www.dbface.com/download-dbface

## On-Demand

We also provide on-demand version, please follow the page below to get more information:
https://www.dbface.com/pricing

## Install Docker
You should already have the docker environment. 
If not, please refer this page to install Docker :
https://docs.docker.com/engine/installation/#installation

## Install DbFace

```
sudo docker pull dbface/dbface-docker
```

## Run

Use custom user data volume
```
mkdir /data/dbface
docker run -d --name dbface -p 80:80 -v /data/dbface:/var/www/user -t dbface/dbface-docker
```

*Note* Please always use data volume (-v /data/dbface:/var/www/user), or the applications created in DbFace will be destroyed after removing the docker container. 

## Upgrade
```
docker pull dbface/dbface-docker
```
then stop and remove the running container, and create a new container with the same data volume
```
docker run -d --name dbface -p 80:80 -v /data/dbface:/var/www/user -t dbface/dbface-docker
```
## Enjoy

If you are on windows, find your docker IP
```
docker-machine ip default
```
This should output your service IP, it might be:
```
192.168.99.100
```
Now you can access your app via  http://192.168.99.100:8080

## Issues
If you have any problems or questions about this image, please feel free to drop us a mail: support@dbface.com or post a new discussion on our forum: 
https://forum.dbface.com

You can also open a new ticket : https://ticket.dbface.com/


