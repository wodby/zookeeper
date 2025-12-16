-include env_make

ZOO_VER ?= 3.9.4
ZOO_VER_MINOR=$(shell echo "${ZOO_VER}" | grep -oE '^[0-9]+\.[0-9]+')

TAG ?= $(ZOO_VER_MINOR)

REPO = wodby/zookeeper
NAME = zookeeper-$(ZOO_VER_MINOR)

PLATFORM ?= linux/arm64

ifneq ($(ARCH),)
	override TAG := $(TAG)-$(ARCH)
endif

IMAGETOOLS_TAG ?= $(TAG)

.PHONY: test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
	    --build-arg ZOO_VER=$(ZOO_VER) \
		./
.PHONY: build

buildx-build:
	docker buildx build --platform $(PLATFORM) -t $(REPO):$(TAG) \
	    --build-arg ZOO_VER=$(ZOO_VER) \
	    --load \
		./
.PHONY: buildx-build

buildx-push:
	docker buildx build --push --platform $(PLATFORM) -t $(REPO):$(TAG) \
	    --build-arg ZOO_VER=$(ZOO_VER) \
	    ./

buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(IMAGETOOLS_TAG) \
				  $(REPO):$(TAG)-amd64 \
				  $(REPO):$(TAG)-arm64
.PHONY: buildx-imagetools-create 

test:
	cd ./tests && NAME=$(NAME) IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -e DEBUG=1 $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
