SHELL = /bin/sh

.SUFFIXES:
.SUFFIXES: .example .json .lock .yml .yaml 

DOCKER_COMPOSE_DIR=./.docker
DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.yml
DEFAULT_CONTAINER=workspace
DOCKER_COMPOSE=docker-compose -f $(DOCKER_COMPOSE_FILE) --project-directory $(DOCKER_COMPOSE_DIR)
DOCKER=docker

_DEPS = composer.json composer.lock .docker/docker-compose.yml 

DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ [Docker] Build / Infrastructure
.docker/.env:
	cp $(DOCKER_COMPOSE_DIR)/.env.example $(DOCKER_COMPOSE_DIR)/.env

composer.json.check: ./composer.json
	cp composer.json $(DOCKER_COMPOSE_DIR)/app/composer/composer.json

composer.lock.check: ./composer.lock
	cp ./composer.lock $(DOCKER_COMPOSE_DIR)/app/composer/composer.lock

composer: composer.json.check composer.lock.check

#.docker/docker-composer.yml: .docker/docker-compose.yml

.PHONY: docker-clean
docker-clean: ## Remove the .env file for docker
	rm -f $(DOCKER_COMPOSE_DIR)/.env

.PHONY: docker-init
docker-init: .docker/.env composer ## Make sure the .env file exists for docker

.PHONY: docker-build-from-scratch
docker-build-from-scratch: docker-init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) rm -fs $(CONTAINER) && \
	$(DOCKER_COMPOSE) build --pull --no-cache --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: docker-test
docker-test: docker-init docker-up ## Run the infrastructure tests for the docker setup
	sh $(DOCKER_COMPOSE_DIR)/docker-test.sh

.PHONY: docker-build
docker-build: docker-init ## Build all docker images. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) build --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)
	
.PHONY: docker-prune
docker-prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
	docker system prune -a -f --volumes

.PHONY: docker-up
docker-up: docker-init ## Start all docker containers. To only start one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) up -d $(CONTAINER)

.PHONY: docker-down
docker-down: docker-init ## Stop all docker containers. To only stop one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) down $(CONTAINER)

.PHONY: docker-commit
docker-commit:  ## Commit a container’s file changes or settings into a new image. CONTAINER="container ID", AUTHOR="Author" (optional), CHANGE="change to apply" (optional), REPOSITORY="Repository name". TAG="tag" (optional)
	OPTIONS=
	ifndef CONTAINER
	$(error No CONTAINER specified.)
	.ABORT
	else ifndef REPOSITORY
	$(error No REPOSITORY specified.)
	.ABORT
	else
	  ifdef $TAG
		REPOSITORY=$(REPOSITORY):$TAG
		if def AUTHOR
		OPTIONS=--author "$(AUTHOR)"
		endif
		ifdef CHANGE
		OPTIONS=$(OPTIONS) --change "$(CHANGE)" 
		endif
		ifdef MESSAGE
		OPTIONS=$(OPTIONS) --message "$(MESSAGE)"
		endif
	endif
	$(DOCKER) commit $(OPTIONS) $REPOSITORY

.PHONY: commit 
commit: ## Commit all changes to local git repository. Add a message to the repository with MESSAGE="message for commit goes here"
	if ndef MESSAGE
	$(error No message was included for the file commit. Include one with MESSAGE="commit message goes here")
	.ABORT
	endif
	git add -A .
	git commit -m "$MESSAGE"

.PHONY: push
push: commit ## Commit any outstanding changes, and push the local repository to origin master. Add a commit message with MESSAGE="commit message goes here"
	ifndef MESSAGE
	MESSAGE="Commit before pushing local repository to the origin master."
	endif
	git push -u origin master

.PHONY: clean
clean: docker-down docker-prune ## Clean up everything.
	VOLUMES=$($(DOCKER) volume ls -qf dangling=true)
	$(if $(strip $(VOLUMES)),$(DOCKER) volume rm $(VOLUMES) --log-level fatal,)
	VOLUMES=$($(DOCKER) volume ls -qf dangling=true)
	$(if $(strip $(VOLUMES)),echo $(VOLUMES) | xargs -r $(DOCKER) volume rm,)
	NETWORKS=$($(DOCKER) network ls | grep "bridge" | awk '/ / { print $1 }')
	$(if $(strip $(NETWORKS)),$(DOCKER) network rm $(NETWORKS),)
	IMAGES=$($(DOCKER) images --filter "dangling=true" -q --no-trunc)
	$(if $(strip $(IMAGES)),$(DOCKER) rmi $(IMAGES),)
	IMAGES=$($(DOCKER) images | grep "none" | awk '/ / { print $3 }')
	$(if $(strip $(IMAGES)),$(DOCKER) rmi $(IMAGES),)
	$CONTAINERS=$($(DOCKER) ps -qa --no-trunc --filter "status=exited")
	$(if $(strip $(CONTAINERS)),$(DOCKER) rm $(CONTAINERS),)