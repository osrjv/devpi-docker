#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

if [ -z "${SERVER_NAME:-}" ]; then
    echo "Environment variable SERVER_NAME undefined"
    exit 1
fi

# Replace placeholders with domain name
sed -i -e "s/__servername__/${SERVER_NAME}/g" /etc/nginx/nginx.conf
sed -i -e "s/__servername__/${SERVER_NAME}/g" /etc/nginx/nginx-https.conf

# Start non-https nginx to renew certificates
nginx

# Wait for files to appear
while [ ! -d "/etc/letsencrypt/live/${SERVER_NAME}" ]; do
    echo "Waiting for certificate folder"
    sleep 2
done

while [ ! -f "/etc/letsencrypt/live/${SERVER_NAME}/fullchain.pem" ]; do
    echo "Waiting for signed certificate"
    sleep 2
done

while [ ! -f "/etc/letsencrypt/live/${SERVER_NAME}/privkey.pem" ]; do
    echo "Waiting for private key"
    sleep 2
done

# Wait for possible renewal of existing files
sleep 15

# Start proper nginx
pkill nginx
cp /etc/nginx/nginx-https.conf /etc/nginx/nginx.conf
exec nginx -g "daemon off;"
