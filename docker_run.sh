#!/bin/bash

SITE_DIR="sites/$SITE"

docker build --build-arg site="$SITE_DIR/conf.d" . -t nginx-certbot
docker volume create certbot_data
docker rm -f nginx-certbot || :
docker run -d \
    --restart=always \
    --net=host \
    -v certbot_data:/etc/letsencrypt \
    --env-file "$SITE_DIR/settings.env" \
    --name nginx-certbot \
    nginx-certbot
