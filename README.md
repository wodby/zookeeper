# ZooKeeper Docker container image

[![Build Status](https://github.com/wodby/zookeeper/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/zookeeper/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/zookeeper.svg)](https://hub.docker.com/r/wodby/zookeeper)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/zookeeper.svg)](https://hub.docker.com/r/wodby/zookeeper)

## Docker Images

Use image revision tags such as `wodby/zookeeper:3-rN` to select a Wodby image revision.
Major and minor tags use the repository release number. Full-version tags such as
`wodby/zookeeper:3.9.6-r0` start at `r0` for each exact upstream version.
Every published versioned revision tag has a matching annotated Git tag pointing to its release commit.
Existing tags remain available after support for their major or minor version ends.
See [release tags](https://github.com/wodby/zookeeper/tags) for available revisions and the [image revision policy](https://github.com/wodby/images#image-revisions) for upgrade guidance.
Previously published image tags remain available.

- All images are based on Alpine Linux
- Base image: [eclipse-temurin](https://github.com/adoptium/containers)
- [GitHub actions builds](https://github.com/wodby/zookeeper/actions)
- [Docker Hub](https://hub.docker.com/r/wodby/zookeeper)

[_(Dockerfile)_]: https://github.com/wodby/zookeeper/tree/master/Dockerfile

Supported tags and respective `Dockerfile` links:

* `3.9.4`, `3.9`, `3`, `latest` [_(Dockerfile)_]

### Supported architectures

All images built for `linux/amd64` and `linux/arm64`

## Environment Variables

| Variable                          | Default Value         | Description |
|-----------------------------------|-----------------------|-------------|
| `ZOO_TICK_TIME`                   | `2000`                |             |
| `ZOO_INIT_LIMIT`                  | `5`                   |             |
| `ZOO_SYNC_LIMIT`                  | `2`                   |             |
| `ZOO_AUTOPURGE_SNAP_RETAIN_COUNT` | `3`                   |             |
| `ZOO_AUTOPURGE_PURGE_INTERVAL`    | `0`                   |             |
| `ZOO_MAX_CLIENT_CNXNS`            | `60`                  |             |
| `ZOO_STANDALONE_ENABLED`          | `true`                |             |
| `ZOO_ADMIN_ENABLE_SERVER`         | `true`                |             |
| `ZOO_4LW_COMMANDS_WHITELIST`      | `stat,ruok,conf,isro` |             |

## Orchestration actions

Usage:
```
make COMMAND [params ...]

commands:
    check-ready [host max_try wait_seconds]
    stat [host]
 
default params values:
    host localhost
    max_try 1
    wait_seconds 1
    delay_seconds 0
```

## Deployment

Deploy Zookeeper to your server via ![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby:

* [Zookeeper](https://wodby.com/stacks/zookeeper)
