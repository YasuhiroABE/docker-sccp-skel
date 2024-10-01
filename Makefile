
DOCKER_CMD ?= podman
DOCKER_OPT ?=   ## --security-opt label=disable for podman on selinux
DOCKER_BUILDER ?= mabuilder
DOCKER_PLATFORM ?= linux/amd64
DOCKER_PLATFORMS ?= linux/amd64,linux/arm64

NAME ?= my-nginx
DOCKER_IMAGE ?= my-nginx
DOCKER_IMAGE_VERSION ?= 1.0.0
IMAGE_NAME := $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER ?= inovtst9.u-aizu.ac.jp
REGISTRY_LIBRARY ?= $(shell id -un)
PROD_IMAGE_NAME := $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

NGINX_PORT ?= 80
DOCKER_PORT ?= 8080

.PHONY: build
build:
	$(DOCKER_CMD) build . $(DOCKER_OPT) --tag $(DOCKER_IMAGE) --platform $(DOCKER_PLATFORM)

.PHONY: build-prod
build-prod:
	$(DOCKER_CMD) build . $(DOCKER_OPT) --pull --tag $(IMAGE_NAME) --no-cache --platform $(DOCKER_PLATFORM)

.PHONY: tag
tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

.PHONY: push
push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

.PHONY: run
run:
	$(DOCKER_CMD) run -d --rm $(DOCKER_OPT) \
	-e NGINX_PORT=$(NGINX_PORT) \
	-p $(DOCKER_PORT):$(NGINX_PORT) \
	--name $(NAME) \
	--platform $(DOCKER_PLATFORM) \
	-v `pwd`/htdocs:/usr/share/nginx/html \
	$(DOCKER_IMAGE)

.PHONY: stop
stop:
	$(DOCKER_CMD) $(DOCKER_OPT) stop $(NAME)

.PHONY: check
check:
	$(DOCKER_CMD) ps -f name=$(NAME)
	$(DOCKER_CMD) images $(IMAGE_NAME)

.PHONY: docker-buildx-init
docker-buildx-init:
	$(DOCKER_CMD) buildx create --name $(DOCKER_BUILDER) --use $(DOCKER_OPT)

.PHONY: docker-buildx-setup
docker-buildx-setup:
	$(DOCKER_CMD) buildx use $(DOCKER_BUILDER) $(DOCKER_OPT)
	$(DOCKER_CMD) buildx inspect --bootstrap $(DOCKER_OPT)

.PHONY: docker-buildx-prod
docker-buildx-prod:
	$(DOCKER_CMD) buildx build --platform $(DOCKER_PLATFORMS) --tag $(PROD_IMAGE_NAME) --no-cache --push . $(DOCKER_OPT)

.PHONY: docker-runx
docker-runx:
	$(DOCKER_CMD) run -it --rm  \
		$(DOCKER_OPT) \
		--env LC_CTYPE=ja_JP.UTF-8 \
		-p $(PORT):8080 \
		--name $(NAME) \
		--platform $(DOCKER_PLATFORM) \
		$(PROD_IMAGE_NAME)

.PHONY: podman-buildx-init
podman-buildx-init:
	$(DOCKER_CMD) rmi $(IMAGE_NAME) || true
	$(DOCKER_CMD) manifest create $(IMAGE_NAME)

.PHONY: podman-buildx
podman-buildx:
	$(DOCKER_CMD) build . $(DOCKER_OPT) --tag $(DOCKER_IMAGE) --platform $(DOCKER_PLATFORMS)

.PHONY: podman-buildx-prod
podman-buildx-prod:
	$(DOCKER_CMD) manifest $(DOCKER_OPT) rm $(PROD_IMAGE_NAME) || true
	$(DOCKER_CMD) build . $(DOCKER_OPT) --pull --no-cache --platform $(DOCKER_PLATFORMS) --manifest $(IMAGE_NAME)

.PHONY: podman-buildx-push
podman-buildx-push:
	$(DOCKER_CMD) manifest push $(DOCKER_OPT) $(IMAGE_NAME) $(PROD_IMAGE_NAME)
