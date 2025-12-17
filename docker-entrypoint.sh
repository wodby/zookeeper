#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

_gotpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

_gotpl "zoo.cfg.tmpl" "$ZOO_HOME/conf/zoo.cfg"

if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    HOSTNAME="$(hostname -s)"
    if [[ $HOSTNAME =~ (.*)-([0-9]+)$ ]]; then
        ORD=${BASH_REMATCH[2]}
        ZOO_MY_ID="$((ORD + 1 ))"
        echo "${ZOO_MY_ID}" > "$ZOO_DATA_DIR/myid"
    else
        echo "Failed to get ID from hostname $HOSTNAME, using 1 as default"
        echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
    fi
fi

sudo init_container

if [[ "${1}" == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec "${@}"
fi
