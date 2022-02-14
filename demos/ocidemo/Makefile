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

.PHONY: docker-build
docker-build: ## Build the docker image
	@DOCKER_BUILDKIT=1 docker build -t $(DOCKER_IMG) -f $(DOCKERFILE) .

.PHONY: docker-push
docker-push: ## Upload the docker image
	docker push $(DOCKER_IMG)

.PHONY: docker-pull
docker-pull: ## Download the docker image
	docker pull $(DOCKER_IMG)

.PHONY: cosign-keys
cosign-keys: ## Generate a key pair
	COSIGN_PASSWORD= cosign generate-key-pair

.PHONY: cosign-sign
cosign-sign: ## Sign the container image
	COSIGN_PASSWORD= cosign sign -key cosign.key $(DOCKER_IMG)

.PHONY: cosign-verify
cosign-verify: ## Verify the signature of the container image
	cosign verify -key cosign.pub $(DOCKER_IMG)

.PHONY: cosign-attach
cosign-attach: sbom ## Attach the SBOM to the container image
	# We were not able to 1) retrieve the sbom attached with the image, 2) verify
	# whether the sbom was signed. Therefore we decided to use the upload command
	# directly instead.
	# COSIGN_EXPERIMENTAL=1 cosign attach sbom -type cyclonedx -sbom bom.json $(DOCKER_IMG)
	cosign upload blob -f bom.json $(SBOM)
	COSIGN_PASSWORD= cosign sign -key cosign.key $(SBOM)

.PHONY: cosign-retrieve-sbom
cosign-retrieve-sbom: ## Retrieve and validate the SBOM
	sget -key cosign.pub $(SBOM)

# To retrieve the SBOM with crane:
# 	crane pull ttl.sh/ocidemo:sha256-c5478895df26f9005d116864446d51e4642403c8855108c8c0f2b3519928294b.sbom pulled-sbom.tar
# 	tar xf pulled-sbom.tar
#		mv d3d9c25c8875225c28edbf2619d09bb7d55781577604b0a1e96e615efef7c92a.tar.gz pulled-sbom.json
#		bat pulled-sbom.json

.PHONY: crane-ls
crane-ls: ## List the repository tags
	crane ls $(DOCKER_REPO)

.PHONY: crane-digest
crane-digest: ## List the image digest
	crane digest $(DOCKER_IMG)

.PHONY: crane-manifest
crane-manifest: ## Display the image manifest
	crane manifest $(DOCKER_IMG)

.PHONY: sbom
sbom: ## Generate a CycloneDX SBOM
	cargo cyclonedx -f json --all
