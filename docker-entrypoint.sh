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

if [[ -z $ZOO_SERVERS ]]; then
    echo "server.1=localhost:2888:3888;2181" >> "$ZOO_HOME/conf/zoo.cfg"
else
    local server_id_with_jumps
    [[ "$ZOO_SERVERS" == *"::"* ]] && server_id_with_jumps=1
    read -r -a zookeeper_servers_list <<<"${ZOO_SERVERS//[;, ]/ }"
    for server in "${zookeeper_servers_list[@]}"; do
        if [[ -n "${server_id_with_jumps}" ]]; then
            if ! echo "$server" | grep -q -E "^[^[:space:]]+:[[:digit:]]+:[[:digit:]]+(:observer|:participant)?::[[:digit:]]+$"; then
                echo "Zookeeper server ${server} should follow the next syntax: host:port:port::id. Example: zookeeper:2888:3888::1 zookeeper:2888:3888:observer::1"
                exit 1
            fi
        else
            if ! echo "$server" | grep -q -E "^[^[:space:]]+:[[:digit:]]+:[[:digit:]]+(:observer|:participant)?$"; then
                echo "Zookeeper server ${server} should follow the next syntax: host:port:port. Example: zookeeper:2888:3888 zookeeper:2888:3888:observer"
                exit 1
            fi
        fi
    done
    
    read -r -a zookeeper_servers_list <<<"${ZOO_SERVERS//[;, ]/ }"
    if [[ ${#zookeeper_servers_list[@]} -gt 1 ]]; then
        if [[ -n "${server_id_with_jumps}" ]]; then
            for server in "${zookeeper_servers_list[@]}"; do
                read -r -a srv <<<"${server//::/ }"
                info "Adding server: ${srv[0]} with id: ${srv[1]}"
                echo "server.${srv[1]}=${srv[0]};2181" >> "$ZOO_HOME/conf/zoo.cfg"
            done
        else
            local i=1
            for server in "${zookeeper_servers_list[@]}"; do
                info "Adding server: ${server}"
                echo "server.$i=${server};2181" >> "$ZOO_HOME/conf/zoo.cfg"
                ((i++))
            done
        fi
    else
        info "No additional servers were specified. ZooKeeper will run in standalone mode..."
    fi
fi

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
