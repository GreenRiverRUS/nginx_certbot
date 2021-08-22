#!/bin/sh
set -e

mkdir -p "/var/www/certbot"

echo "Checking nginx..."
if nginx -t 1>&2 2>/dev/null; then
    echo "Ok. Exiting init script..."
    exit 0
else
    echo "Fail. Starting full procedure..."
fi

echo "Initializing nginx..."
echo "$LETSENCRYPT_DOMAINS"

echo "Creating dummy certs..."
domain_args=""
for domain in $LETSENCRYPT_DOMAINS; do
    cert_path="/etc/letsencrypt/live/$domain"
    mkdir -p "$cert_path"
    domain_args="$domain_args -d $domain"

    openssl req -x509 -nodes -newkey rsa:1024 -days 1\
        -keyout "$cert_path/privkey.pem" \
        -out "$cert_path/fullchain.pem" \
        -subj "/CN=localhost" 1>&2 2>/dev/null
    echo -e "\tCreated dummy cert for $domain"
done

echo "Starting nginx..."
nginx -g "daemon on;"

echo "Deleting dummy certs..."
for domain in $LETSENCRYPT_DOMAINS; do
    cert_path="/etc/letsencrypt/live/$domain"

    rm -rf "$cert_path"
    echo -e "\tDeleted dummy cert for $domain"
done

echo "Requesting certificates..."
certbot certonly \
    --webroot -w /var/www/certbot \
    $domain_args \
    --email $LETSENCRYPT_EMAIL \
    --agree-tos \
    --rsa-key-size 4096 \
    --noninteractive \
    --force-renewal
    #--staging

echo "Stopping nginx..."
nginx -s quit

echo "Checking nginx..."
nginx -t 1>&2 2>/dev/null && echo "Ok" || echo "Fail"
