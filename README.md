# What is DbFace?

DbFace is a super easy reports and dashboards builder for MySQL, PostgreSQL, SQL Server databases. 

You can also make your own API Connector to make DbFace work with No-SQL databases(MongoDb etc.).

DbFace connects to your database and pull down data from it and show you chart reports, dashboards, storyboards.

This repository helps you install DbFace in docker container.

Please get more information from:

* Website: https://www.dbface.com
* Facebook: https://www.facebook.com/dbface
* Twitter: https://www.twitter.com/dbface
* Documentation: https://www.dbface.com/documents/
* Manual Installation: http://www.dbface.com/download-dbface

## Install Docker

Please refer this page to install Docker :

https://docs.docker.com/engine/installation/#installation

## Install DbFace

```
sudo docker pull dbface/dbface-docker
```

## Run

```
sudo docker run -d --name dbface -p 80:80 -t dbface/dbface-docker
```

## Enjoy

Find your docker IP
```
docker-machine ip default
```
This should output your service IP, it might be:
```
192.168.99.100
```
Now you can access your app via  http://192.168.99.100

## License

DbFace On-premise provides 15 days trial, after the trial period, you need to get a license to keep it running. Checkout the following page to get more information:

http://www.dbface.com/pricing

## Issues

If you have any problems or questions about this image, please feel free to drop us a mail: support@dbface.com or post a new discussion on our forum: 
https://plus.google.com/communities/103467353497379821094

You can also open a new ticket : http://www.dbface.com/ticket/


