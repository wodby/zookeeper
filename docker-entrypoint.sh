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

_gotpl "zoo.cfg.tmpl" "/conf/zoo.cfg"

if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

sudo init_container

if [[ "${1}" == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec "${@}"
fi
