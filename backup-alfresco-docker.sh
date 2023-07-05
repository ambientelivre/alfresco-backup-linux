#!/bin/bash

# script-backup-alfresco
# A Backup Script for Alfresco by @ambientelivre
# The project is open source in https://github.com/ambientelivre/alfresco-backup-linux
# contrib!
# Create by marcio@ambientelivre.com.br marcos@ambientelivre.com.br

# Configs of Script
DESTDIR=/home/ambientelivre/backup    	             # backup destination directory
DATE_NOW=$(date +%d-%m-%y)                           # default filename with date
INSTALL_ALFRESCO=/opt/alfresco                	     # directory where alfresco is installed 
DIR_ALFDATA=/opt/alfresco/data/alf-repo-data         # alfresco data directory (alf-data)
DBENGINE=mariadb				     # Examples: mariadb or postgres
INDEXBACKUP=false                                    # Set Solr Backup: true or false

## Configs Database PostgreSQL
PGUSER=alfresco
PGPASSWORD=sejalivre
PGHOST=localhost
#PGPORT=5432
PGDATABASE=alfresco

## Configs Database MariaDB.
DBUSER=alfresco
DBPASS=alfresco
DBHOST=localhost
#DBPORT=3306
DBDATABASE=alfresco

mkdir $DESTDIR/$DATE_NOW
cd $INSTALL_ALFRESCO

if [ $DBENGINE = "mariadb" ]
then
  docker-compose exec mariadb mysqldump -u$DBUSER -p$DBPASS $DBDATABASE > $DESTDIR/$DATE_NOW/$DBDATABASE'_'$DBENGINE.sql
elif [ $DBENGINE = "postgres" ]
then
  docker-compose exec postgres pg_dump --username $PGUSER $PGDATABASE > $DESTDIR/$DATE_NOW/postgresql.sql
fi

# content
tar -pczvf $DESTDIR/$DATE_NOW/alfdata.tar.gz $DIR_ALFDATA

# DockerFile + customs modules + amps.
tar -pczvf $DESTDIR/$DATE_NOW/alfresco.module.tar.gz $INSTALL_ALFRESCO/alfresco
tar -pczvf $DESTDIR/$DATE_NOW/share.module.tar.gz    $INSTALL_ALFRESCO/share
cp $INSTALL_ALFRESCO/docker-compose.yml  $DESTDIR/$DATE_NOW/

if [ $INDEXBACKUP = "true" ]
then
  tar -pczvf $DESTDIR/$DATE_NOW/solr.tar.gz $INSTALL_ALFRESCO/data/solr-data
fi

