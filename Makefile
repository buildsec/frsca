# Project configuration.
PROJECT_NAME = ssf

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
	bash platform/00-kubernetes-minikube-setup.sh

.PHONY: setup-tekton-chains
setup-tekton-chains: ## Setup a Tekton CD with Chains.
	bash platform/10-tekton-setup.sh
	bash platform/11-tekton-chains.sh

.PHONY: tekton-generate-keys
tekton-generate-keys: ## Generate key pair for Tekton.
	bash scripts/gen-keys.sh

.PHONY: tekton-verify-taskrun
tekton-verify-taskrun: ## Verify taskrun payload against signature
	bash scripts/provenance.sh

.PHONY: setup-kyverno
setup-kyverno: ## Setup Kyverno.
	bash platform/30-kyverno-setup.sh
