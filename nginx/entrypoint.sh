#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

if [ -z ${DEVPI_DEFAULT_HOST:-} ]; then
    DEVPI_DEFAULT_HOST=devpi
fi

if [ -z ${DEVPI_DEFAULT_PORT:-} ]; then
    DEVPI_DEFAULT_PORT=8000
fi

sed -i -e "s/devpi_host:devpi_port/${DEVPI_DEFAULT_HOST}:${DEVPI_DEFAULT_PORT}/g" /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
