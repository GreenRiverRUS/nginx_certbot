#!/bin/sh
set -e

/bin/init.sh "$@"
while :; do
    echo "Checking certificates for renewal..."
    certbot renew --deploy-hook "nginx -s reload"
    echo -e "\n\nDone"
    sleep 12h
done &
nginx -g "daemon off;"
