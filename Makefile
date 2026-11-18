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

# CI combines the exact architecture images this workflow run pushed; see
# wodby/images arch-image-pins. Per-architecture tags are shared by every run,
# so an overlapping run may already have replaced one of them.
arch-image = $(if $(ARCH_IMAGE_PINS),$(or $(shell cat '$(ARCH_IMAGE_PINS)/$(subst :,_,$(subst /,_,$(1)))' 2>/dev/null),$(error No digest of $(1) was pushed by this workflow run)),$(1))

buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(IMAGETOOLS_TAG) \
				  $(call arch-image,$(REPO):$(TAG)-amd64) \
				  $(call arch-image,$(REPO):$(TAG)-arm64)
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

# Print the image make builds and pushes; CI pushes exactly this reference.
.PHONY: image-ref
image-ref:
	@printf '%s\n' '$(REPO):$(TAG)'
