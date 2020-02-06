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
}

function initialize_user {
    if [ -z "${READ_USER}" ]; then
        echo "No READ_USER defined"
        exit 1
    fi
    if [ -z "${READ_PASSWORD}" ]; then
        echo "No READ_PASSWORD defined"
        exit 1
    fi
    htpasswd -cb /data/htpasswd "${READ_USER}" "${READ_PASSWORD}"
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

if [ ! -f /data/htpasswd ]; then
    initialize_user
fi

exec devpi-server --restrict-modify root --serverdir /data/server --host 0.0.0.0 --port 8000 --theme semantic-ui
