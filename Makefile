
NAME = mynginx
DOCKER_ID = yasuhiroabe
DOCKER_IMAGE = mynginx
DOCKER_IMAGE_VERSION = 1.0

IMAGE_NAME = $(DOCKER_ID)/$(DOCKER_IMAGE)

.PHONY: build build-prod push run stop push

build:
	sudo docker build . --tag $(IMAGE_NAME)

build-prod:
	sudo docker build . --tag $(IMAGE_NAME):$(DOCKER_IMAGE_VERSION) --no-cache

push:
	sudo docker push $(IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

run:
	sudo docker run -d --rm \
	-p 8080:80 \
	--name $(NAME) \
	-v `pwd`/htdocs:/usr/share/nginx/html \
	$(IMAGE_NAME)

stop:
	sudo docker stop $(NAME)

push:
	sudo docker push $(IMAGE_NAME)
