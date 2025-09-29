#!/bin/bash

# script-backup-alfresco
# A Backup Script for Alfresco by @ambientelivre
# The project is open source in https://github.com/ambientelivre/alfresco-backup-linux
# contrib!
# Create by marcio@ambientelivre.com.br marcos@ambientelivre.com.br

# Configs of Script
DESTDIR="/opt/backup"      	                         # backup destination directory
DATE_NOW=$(date +%d-%m-%y)                           # default filename with date
INSTALL_ALFRESCO=/opt/alfresco                	     # directory where alfresco is installed 
DIR_ALFDATA="${INSTALL_ALFRESCO}/data/alf-repo-data" # alfresco data directory (alf-data)
DBENGINE=postgres				     # Examples: mariadb or postgres
INDEXBACKUP=false                                    # Set Solr Backup: true or false

## Config Bucket S3
#** for this install mc client and config alias (Minio Client)
MINIO_S3_MOVE=false                                   # Set true to move tar.gz to Minio/S3 Bucket
MINIO_S3_BUCKET=alfresco                             # name bucket and path S3
MINIO_S3_ALIAS=magalu                                # Alias set in mc client

## Configs Database PostgreSQL
PGUSER=alfresco
PGPASSWORD=sejalivre
PGDATABASE=alfresco

## Configs Database MariaDB.
DBUSER=alfresco
DBPASS=alfresco
DBDATABASE=alfresco

## Certificados e Nginx Config
NGINX_BACKUP=false
NGINX_CONFIG_DIR="${INSTALL_ALFRESCO}/config"
CERTIFICATES_BACKUP=false
CERTIFICATES_DIR="${INSTALL_ALFRESCO}/letsencrypt/live"

DATE_NOW=$(date +%d-%m-%y)
mkdir -p "$DESTDIR/$DATE_NOW"
cd "$INSTALL_ALFRESCO" || exit 1

cp "$INSTALL_ALFRESCO/docker-compose.yml" "$DESTDIR/$DATE_NOW/"
[ -f "$INSTALL_ALFRESCO/.env" ] && cp "$INSTALL_ALFRESCO/.env" "$DESTDIR/$DATE_NOW/"

# Backup Database
if [ "$DBENGINE" = "mariadb" ]; then
    docker-compose exec -T mariadb mysqldump -u"$DBUSER" -p"$DBPASS" "$DBDATABASE" > "$DESTDIR/$DATE_NOW/${DBDATABASE}_${DBENGINE}.sql"
elif [ "$DBENGINE" = "postgres" ]; then
    docker-compose exec -T postgres pg_dump --username "$PGUSER" "$PGDATABASE" > "$DESTDIR/$DATE_NOW/postgresql.sql"
fi

# Backup Alfresco Data
tar -pczvf "$DESTDIR/$DATE_NOW/alfdata.tar.gz" "$DIR_ALFDATA"

# Backup Docker Alfresco Modules
tar -pczvf "$DESTDIR/$DATE_NOW/alfresco.module.tar.gz" "$INSTALL_ALFRESCO/alfresco"
tar -pczvf "$DESTDIR/$DATE_NOW/share.module.tar.gz" "$INSTALL_ALFRESCO/share"
cp "$INSTALL_ALFRESCO/docker-compose.yml" "$DESTDIR/$DATE_NOW/"

# Backup Solr Data
if [ "$INDEXBACKUP" = "true" ]; then
    tar -pczvf "$DESTDIR/$DATE_NOW/solr.tar.gz" "$INSTALL_ALFRESCO/data/solr-data"
fi

# Backup Certificados
if [ "$CERTIFICATES_BACKUP" = "true" ]; then
    tar -pczvf "$DESTDIR/$DATE_NOW/certificates.tar.gz" "$CERTIFICATES_DIR"
fi

# Backup Nginx Config
if [ "$NGINX_BACKUP" = "true" ]; then
    tar -pczvf "$DESTDIR/$DATE_NOW/nginx-config.tar.gz" "$NGINX_CONFIG_DIR"
fi

# Enviar para Minio/S3
if [ "$MINIO_S3_MOVE" = "true" ]; then
    /usr/local/bin/mc mv "$DESTDIR/$DATE_NOW/*" "$MINIO_S3_ALIAS/$MINIO_S3_BUCKET/$DATE_NOW" --recursive
fi
