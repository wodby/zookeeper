FROM eclipse-temurin:21-jre-alpine AS base

ARG ZOO_VER
ARG TARGETPLATFORM

ENV ZOO_HOME=/opt/zookeeper \
    ZOO_USER=zookeeper \
    ZOO_GROUP=zookeeper \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_CONF_DIR=/conf \
    ZOO_LOG_DIR=/logs \
    PATH="/opt/zookeeper/bin:$PATH"

RUN set -eux; \
    \
    apk add --no-cache \
      bash \
      make \
      sudo \
      curl \
      shadow \
      tzdata \
      ca-certificates; \
    update-ca-certificates; \
    \
    groupadd -g 1000 zookeeper; \
    useradd  -u 1000 -m -s /bin/bash -g zookeeper zookeeper; \
    \
    apk add --update --no-cache -t .zoo-build-deps git; \
    \
    mkdir -p "$ZOO_HOME" "$ZOO_CONF_DIR" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR"; \
    chown -R "$ZOO_USER:$ZOO_GROUP" "$ZOO_HOME" "$ZOO_CONF_DIR" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR"; \
    ZOO_TGZ="apache-zookeeper-${ZOO_VER}-bin.tar.gz"; \
    ZOO_URL="https://downloads.apache.org/zookeeper/zookeeper-${ZOO_VER}/${ZOO_TGZ}"; \
    curl -fsSL "$ZOO_URL" -o "/tmp/${ZOO_TGZ}"; \
    tar -xzf "/tmp/${ZOO_TGZ}" --strip=1 -C /opt/zookeeper; \
    rm -rf "/tmp/${ZOO_TGZ}" "$ZOO_HOME"/docs "$ZOO_HOME"/recipes; \
    \
    gotpl_url="https://github.com/wodby/gotpl/releases/latest/download/gotpl-${TARGETPLATFORM/\//-}.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz --no-same-owner -C /usr/local/bin; \
    \
    git clone https://github.com/wodby/alpine /tmp/alpine; \
    cd /tmp/alpine; \
    latest=$(git describe --abbrev=0 --tags); \
    git checkout "${latest}"; \
    mv /tmp/alpine/bin/* /usr/local/bin; \
    \
    touch "$ZOO_HOME/conf/zoo.cfg"; \
    chown zookeeper:zookeeper "$ZOO_HOME/conf/zoo.cfg"; \
    \
    { \
        echo "Defaults secure_path=\"$PATH\""; \
        \
        echo -n 'zookeeper ALL=(root) NOPASSWD:SETENV: ' ; \
        echo '/usr/local/bin/init_container' ; \
    } | tee /etc/sudoers.d/zookeeper; \
    \
    apk del --purge .zoo-build-deps; \
    rm -rf \
        /tmp/* \
        /var/cache/apk/* ;

COPY docker-entrypoint.sh /
COPY templates /etc/gotpl/
COPY bin /usr/local/bin/

VOLUME ["/data", "/datalog", "/logs"]

EXPOSE 2181 2888 3888 8080

USER zookeeper

WORKDIR /opt/zookeeper

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
