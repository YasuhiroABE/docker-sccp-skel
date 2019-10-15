
NAME = mynginx
DOCKER_ID = yasuhiroabe
DOCKER_IMAGE = mynginx

IMAGE_NAME = $(DOCKER_ID)/$(DOCKER_IMAGE)

.PHONY: build run stop push

build:
	sudo docker build . --tag $(IMAGE_NAME)

run:
	sudo docker run -d --rm \
	-p 8080:80 \
	--name $(NAME) \
	$(IMAGE_NAME)

stop:
	sudo docker stop $(NAME)

push:
	sudo docker push $(IMAGE_NAME)
