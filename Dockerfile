FROM eclipse-temurin:21-jre-alpine AS base

ARG ZOO_VER
ARG TARGETPLATFORM

ENV ZOO_HOME=/opt/zookeeper \
    ZOO_USER=zookeeper \
    ZOO_GROUP=zookeeper \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_CONF_DIR=/conf \
    ZOO_LOG_DIR=/logs

RUN set -eux; \
    addgroup -g 1000 "$ZOO_GROUP"; \
    adduser -D -H -u 1000 -G "$ZOO_GROUP" "$ZOO_USER"; \
    apk add --no-cache \
      bash \
      make \
      sudo \
      curl \
      tzdata \
      ca-certificates; \
    update-ca-certificates; \
    apk add --update --no-cache -t .zoo-build-deps git; \
    \
    mkdir -p "$ZOO_HOME" "$ZOO_CONF_DIR" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR"; \
    chown -R "$ZOO_USER:$ZOO_GROUP" "$ZOO_HOME" "$ZOO_CONF_DIR" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR"; \
    ZOO_TGZ="apache-zookeeper-${ZOO_VER}-bin.tar.gz"; \
    ZOO_URL="https://downloads.apache.org/zookeeper/zookeeper-${ZOO_VER}/${ZOO_TGZ}"; \
    curl -fsSL "$ZOO_URL" -o "/tmp/${ZOO_TGZ}"; \
    tar -xzf "/tmp/${ZOO_TGZ}" --strip=1 -C /opt/zookeeper; \
    rm -rf "/tmp/${ZOO_TGZ}" "$ZOO_HOME"/docs "$ZOO_HOME"/recipes; \
    rm -rf "$ZOO_HOME/conf" && ln -s "$ZOO_CONF_DIR" "$ZOO_HOME/conf"; \
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
    { \
        echo "Defaults secure_path=\"$PATH\""; \
        echo 'Defaults env_keep += "ZOO_DATA_DIR ZOO_DATA_LOG_DIR ZOO_LOG_DIR"' ; \
        \
        if [[ -n "${PHP_DEV}" ]]; then \
            echo 'wodby ALL=(root) NOPASSWD:SETENV:ALL'; \
        else \
            echo -n 'wodby ALL=(root) NOPASSWD:SETENV: ' ; \
            echo '/usr/local/bin/init_container' ; \
        fi; \
    } | tee /etc/sudoers.d/wodby; \
    \
    apk del --purge .zoo-build-deps; \
    rm -rf \
        /tmp/* \
        /var/cache/apk/* ;


ENV PATH="$ZOO_HOME/bin:$PATH"

COPY docker-entrypoint.sh /
COPY templates /etc/gotpl/
COPY bin /usr/local/bin/

VOLUME ["/data", "/datalog", "/logs"]

EXPOSE 2181 2888 3888 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
