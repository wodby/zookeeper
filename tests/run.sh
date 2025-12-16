#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

cid="$(docker run -d -e DEBUG --name "${NAME}" "${IMAGE}")"
trap "docker rm -vf $cid > /dev/null" EXIT

zoo() {
    docker run --rm -i -e DEBUG --link "${NAME}" "${IMAGE}" "${@}"
}

zoo make check-ready max_try=10 host="${NAME}"

echo -n "Checking Zookeeper stats... "
zoo make stat host="${NAME}" | grep -q "Mode: standalone"
echo "OK"
