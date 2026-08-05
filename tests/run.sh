#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

cid="$(docker run -d -e DEBUG -e ZOO_DATA_LOG_DIR=/data/datalog-test --name "${NAME}" "${IMAGE}")"
trap "docker rm -vf $cid > /dev/null" EXIT

zoo() {
    docker run --rm -i -e DEBUG --link "${NAME}" "${IMAGE}" "${@}"
}

zoo make check-ready max_try=10 host="${NAME}"

echo -n "Checking transaction log directory override... "
docker exec "$cid" grep -qx 'dataLogDir=/data/datalog-test' /opt/zookeeper/conf/zoo.cfg
zoo zkCli.sh -server "${NAME}:2181" create /datalog-test ok >/dev/null
docker exec "$cid" test -f /data/datalog-test/version-2/log.1
echo "OK"

echo -n "Checking Zookeeper stats... "
zoo make stat host="${NAME}" | grep -q "Mode: standalone"
echo "OK"
