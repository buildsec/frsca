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

.PHONY: quickstart
quickstart: setup-minikube setup-tekton-chains tekton-generate-keys setup-kyverno example-buildpacks ## Spin up the SSF project into minikube

.PHONY: setup-minikube
setup-minikube: ## Setup a Kubernetes cluster using Minikube
	bash platform/00-kubernetes-minikube-setup.sh

.PHONY: registry-proxy
registry-proxy: ## Forward the minikube registry to the host
	bash platform/05-minikube-registry-proxy.sh

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

.PHONY: setup-opa-gatekeeper
setup-opa-gatekeeper: ##  Setup opa gatekeeper
	bash platform/31-opa-gatekeeper-setup.sh

.PHONY: example-buildpacks
example-buildpacks: ## Run the buildpacks example
	bash examples/buildpacks/buildpacks.sh

.PHONY: example-maven
example-maven: ## Run the maven example
	bash examples/maven/maven.sh

.PHONY: example-golang-pipeline
example-golang-pipeline: ## Run the go-pipeline example
	bash examples/go-pipeline/go-pipeline.sh

.PHONY: example-gradle-pipeline
example-gradle-pipeline: ## Run the gradle-pipeline example
	bash examples/gradle-pipeline/gradle-pipeline.sh

.PHONY: example-sample-pipeline
example-sample-pipeline: ## Run the sample-pipeline example
	bash examples/sample-pipeline/sample-pipeline.sh

.PHONY: example-ibm-tutorial
example-ibm-tutorial: ## Run the IBM pipeline example
	bash examples/ibm-tutorial/ibm-tutorial.sh

.PHONY: docs-setup
docs-setup: ## Install the tool to build the documentation
	bash docs/bootstrap.sh

.PHONY: docs-serve
docs-serve: ## Serve the site locally with hot-reloading
	cd docs && zola serve

.PHONY: docs-build
docs-build: ## Build the documentation site
	cd docs && zola build

.PHONY: lint
lint: lint-md lint-yaml lint-shell ## Run all linters

.PHONY: lint-md
lint-md: ## Lint markdown files
	npx --yes markdownlint-cli2  "**/*.md" "#docs/themes"

.PHONY: lint-shell
lint-shell: ## Lint shell files
	shfmt -f ./ | xargs shellcheck

.PHONY: lint-spellcheck
lint-spellcheck:
	npx --yes cspell --no-progress --show-suggestions --show-context "**/*"

.PHONY: lint-yaml
lint-yaml: ## Lint yaml files
	yamllint .

.PHONY: fmt-md ## Format markdown files
fmt-md:
	npx --yes prettier --write --prose-wrap always **/*.md
