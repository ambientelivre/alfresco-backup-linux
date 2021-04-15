#!/bin/bash

# script-backup-alfresco
# A Backup Script for Alfresco by @ambientelivre
# The project is open source in https://github.com/ambientelivre/alfresco-backup-linux
# contrib!
# Create by marcio@ambientelivre.com.br

# Configs do Script 
DESTDIR=/home/alfresco    # diretorio de destino do backup
DATE_NOW=$(date +%d-%m-%y)         # padrao do nome do arquivo com data
INSTALL_ALFRESCO=/opt/alfresco     # diretorio de instalacao do alfresco
DIR_ALFDATA=/opt/alfresco/alf_data #diretorio de dados (alfdata) alfresco

## Configs Database
PGUSER=alfresco
PGPASSWORD=sejalivre
PGHOST=localhost
PGPORT=5432
PGDATABASE=alfresco

mkdir $DESTDIR/$DATE_NOW

pg_dump --host $PGHOST --port $PGPORT --username $PGUSER --format tar --file $DESTDIR/$DATE_NOW/postgresql.backup $PGDATABASE

tar -pczvf $DESTDIR/$DATE_NOW/alfdata.tar.gz $DIR_ALFDATA
tar -pczvf $DESTDIR/$DATE_NOW/swalfresco.tar.gz $INSTALL_ALFRESCO --exclude=$DIR_ALFDATA/.*

