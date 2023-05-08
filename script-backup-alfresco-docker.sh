#!/bin/bash

# script-backup-alfresco
# A Backup Script for Alfresco by @ambientelivre
# The project is open source in https://github.com/ambientelivre/alfresco-backup-linux
# contrib!
# Create by marcio@ambientelivre.com.br

# Configs do Script
DESTDIR=/home/ambientelivre    	                     # diretório de destino do backup
DATE_NOW=$(date +%d-%m-%y)                           # padrão do nome do arquivo com data
INSTALL_ALFRESCO=/opt/docker-compose                 # diretório de instalacao do alfresco
DIR_ALFDATA=/opt/docker-compose/data/alf-repo-data   # diretório de dados (alfdata) alfresco]
DBENGINE=mariadb

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
DBPORT=3306
DBDATABASE=alfresco

mkdir $DESTDIR/$DATE_NOW

#postgres
#docker-compose exec postgres pg_dump --username $PGUSER $PGDATABASE > $DESTDIR/$DATE_NOW/postgresql.sql
#pg_dump --host $PGHOST --port $PGPORT --username $PGUSER --format tar --file $DESTDIR/$DATE_NOW/postgresql.backup $PGDATABASE

#mariadb
docker-compose exec mariadb mysqldump -u $DBUSER -p$DBPASS $DBDATABASE > $DESTDIR/$DATE_NOW/alfresco.sql

# content
tar -pczvf $DESTDIR/$DATE_NOW/alfdata.tar.gz $DIR_ALFDATA

# DockerFile + customs modules + amps.
tar -pczvf $DESTDIR/$DATE_NOW/alfresco.module.tar.gz $INSTALL_ALFRESCO/alfresco
tar -pczvf $DESTDIR/$DATE_NOW/share.module.tar.gz    $INSTALL_ALFRESCO/share 
cp $INSTALL_ALFRESCO/docker-compose.yml  $DESTDIR/$DATE_NOW/

#tar -pczvf $DESTDIR/$DATE_NOW/swalfresco.tar.gz $INSTALL_ALFRESCO --exclude=$DIR_ALFDATA/.*
