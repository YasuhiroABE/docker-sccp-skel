
DOCKER_CMD ?= podman
DOCKER_OPT ?=   ## --security-opt label=disable for podman on selinux
DOCKER_BUILDER ?= mabuilder

NAME ?= mynginx
DOCKER_ID ?= $(shell id -un)
DOCKER_IMAGE ?= mynginx
DOCKER_IMAGE_VERSION ?= 1.0
IMAGE_NAME := $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER ?= inovtst9.u-aizu.ac.jp
REGISTRY_LIBRARY ?= $(shell id -un)
PROD_IMAGE_NAME := $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

.PHONY: build
build:
	$(DOCKER_CMD) build . $(DOCKER_OPT) --tag $(DOCKER_IMAGE):latest

.PHONY: build-prod
build-prod:
	$(DOCKER_CMD) build . $(DOCKER_OPT) --pull --tag $(IMAGE_NAME) --no-cache

.PHONY: tag
tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

.PHONY: push
push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

.PHONY: run
run:
	$(DOCKER_CMD) run -d --rm $(DOCKER_OPT) \
	-e NGINX_PORT=80 \
	-p 8080:80 \
	--name $(NAME) \
	-v `pwd`/htdocs:/usr/share/nginx/html \
	$(IMAGE_NAME)

.PHONY: stop
stop:
	$(DOCKER_CMD) stop $(NAME)

.PHONY: check
check:
	$(DOCKER_CMD) ps -f name=$(NAME)
	$(DOCKER_CMD) images $(IMAGE_NAME)

.PHONY: docker-buildx-init
docker-buildx-init:
	$(DOCKER_CMD) buildx create --name $(DOCKER_BUILDER) --use

.PHONY: docker-buildx-setup
docker-buildx-setup:
	$(DOCKER_CMD) buildx use $(DOCKER_BUILDER)
	$(DOCKER_CMD) buildx inspect --bootstrap

.PHONY: docker-buildx-prod
docker-buildx-prod:
	$(DOCKER_CMD) buildx build --platform linux/amd64,linux/arm64 --tag $(PROD_IMAGE_NAME) --no-cache --push .

.PHONY: docker-runx
docker-runx:
	$(DOCKER_CMD) run -it --rm  \
		--env LC_CTYPE=ja_JP.UTF-8 \
		-p $(PORT):8080 \
		--name $(NAME) \
		$(PROD_IMAGE_NAME)
