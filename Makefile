# Project configuration.
PROJECT_NAME = ocidemo

# Makefile parameters.
TAG ?= 10m	# This is the TTL for the ttl.sh registry

# General.
SHELL = /bin/bash
TOPDIR = $(shell git rev-parse --show-toplevel)

# Docker.
DOCKERFILE = Dockerfile
DOCKER_ORG = ttl.sh
DOCKER_REPO = $(DOCKER_ORG)/$(PROJECT_NAME)
DOCKER_IMG = $(DOCKER_REPO):$(TAG)
SBOM = $(DOCKER_REPO)/sbom:$(TAG)

help: # Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST) | sort

.PHONY: setup-minikube
setup-minikube: ## Setup a Kubernetes cluster using Minikube.
	bash setup/kubernetes/00-kubernetes-minikube-setup.sh

.PHONY: setup-tekton-chains
setup-tekton-chains: ## Setup a Tekton CD with Chains.
	bash setup/tekton/10-tekton-setup.sh
	bash setup/tekton/11-tekton-chains.sh

.PHONY: tekton-generate-keys
tekton-generate-keys: ## Generate key pair for Tekton.
	bash resources/tekton/scripts/gen-keys.sh

.PHONY: tekton-verify-taskrun
tekton-verify-taskrun: ## Verify taskrun payload against signature
	bash resources/tekton/scripts/provenance.sh
