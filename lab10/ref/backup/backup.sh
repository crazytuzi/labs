#!/bin/bash
BACKUPDIR="/root/backup/"
SUBDIR=$(date +%Y%m%d%H%M)-$RANDOM
DIR=$BACKUPDIR$SUBDIR/
UPDATEDIR="/root/update"
MAX=50
mkdir $DIR 
service tomcat7 stop
cp -r /var/lib/tomcat7/webapps/nsims $DIR 
cp -r /var/lib/tomcat7/webapps/nsims $UPDATEDIR 
cp /var/lib/tomcat7/webapps/nsims.war $DIR 
mysqldump -u root -pXXXXX nsims > ${DIR}nsims.sql
cd $BACKUPDIR
if [ $(ls $BACKUPDIR | wc -l ) -gt $MAX ]
  then 
    rm -rf $(ls $BACKUPDIR -t| tail -n1)
  fi
service tomcat7 start
