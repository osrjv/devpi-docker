#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

function generate_password() {
    set +e
    tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 | tr -cd '[:alnum:]'
    set -e
}

function initialize_devpi {
    devpi-server --restrict-modify root --start --init --serverdir /data/server --host 127.0.0.1 --port 8000
    devpi-server --serverdir /data/server --status
    devpi use http://localhost:8000
    devpi login root --password=''
    devpi user -m root password="${ROOT_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop --serverdir /data/server
    devpi-server --status --serverdir /data/server
    htpasswd -cb /data/htpasswd root "${ROOT_PASSWORD}"
}

if [ -f "/data/.root_password" ]; then
    ROOT_PASSWORD=$(cat "/data/.root_password")
else
    ROOT_PASSWORD=$(generate_password)
    echo -n "${ROOT_PASSWORD}" > "/data/.root_password"
fi

echo -e "\n*** devpi root password: ${ROOT_PASSWORD}\n"

if [ ! -f /data/server/.serverversion ]; then
    initialize_devpi
fi

if [ -n "${READ_USER:-}" ] && [ -n "${READ_PASSWORD:-}" ]; then
    htpasswd -b /data/htpasswd "${READ_USER}" "${READ_PASSWORD}"
fi

exec devpi-server --restrict-modify root --serverdir /data/server --host 0.0.0.0 --port 8000 --theme semantic-ui
