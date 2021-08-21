DOCKER_REPO ?= gcr.io/cardano-308403
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
IMG_NAME ?= cardano-node

auth:
	gcloud auth login

docker:
	gcloud auth configure-docker

build:
	docker build -t $(DOCKER_REPO)/$(IMG_NAME) -t $(DOCKER_REPO)/$(IMG_NAME):$(GIT_COMMIT) .

push docker:
	docker push $(DOCKER_REPO)/$(IMG_NAME)
	docker push $(DOCKER_REPO)/$(IMG_NAME):$(GIT_COMMIT)
