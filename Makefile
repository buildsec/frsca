# General.
SHELL = /usr/bin/env bash

help: # Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST) | sort

.PHONY: quickstart
quickstart: setup-minikube setup-frsca example-buildpacks ## Spin up the FRSCA project into minikube

.PHONY: teardown
teardown: ## Destroy the minikube environment
	minikube delete

.PHONY: setup-minikube
setup-minikube: ## Setup a Kubernetes cluster using Minikube
	bash platform/00-kubernetes-minikube-setup.sh

.PHONY: setup-dev
setup-dev: setup-certs install-spire install-vault install-gitea setup-spire setup-vault setup-registry ## Setup prerequisities for a development environment

.PHONY: setup-frsca-core
setup-frsca-core: install-tekton-pipelines install-tekton-chains install-kyverno setup-tekton-pipelines setup-tekton-chains setup-kyverno ## Setup FRSCA environment

.PHONY: setup-examples
setup-examples: setup-example-mirror setup-example-buildpacks setup-example-golang-pipeline setup-example-gradle setup-example-ibm-tutorial setup-example-maven setup-example-sample ## Setup examples, mirroring external repos and creating tekton triggers

.PHONY: setup-frsca
setup-frsca: setup-dev setup-frsca-core setup-examples ## Deploy FRSCA with the development components and examples

.PHONY: setup-certs
setup-certs: ## Setup certificates used by vault and spire
	bash platform/02-setup-certs.sh

.PHONY: setup-registry
setup-registry: ## Setup a registry
	bash platform/04-registry-setup.sh

.PHONY: registry-proxy
registry-proxy: ## Forward the registry to the host
	bash platform/05-registry-proxy.sh

.PHONY: install-gitea
install-gitea: ## Install a Gitea server
	bash platform/06-gitea-install.sh

.PHONY: install-tekton-pipelines
install-tekton-pipelines: ## Install a Tekton CD
	bash platform/10-tekton-pipelines-install.sh

.PHONY: setup-tekton-pipelines
setup-tekton-pipelines: ## Setup a Tekton CD
	bash platform/11-tekton-pipeline-setup.sh
	bash platform/14-tekton-tasks.sh

.PHONY: install-tekton-chains
install-tekton-chains: ## Install a Tekton Chains
	bash platform/12-tekton-chains-install.sh

.PHONY: setup-tekton-chains
setup-tekton-chains: ## Setup a Tekton Chains
	bash platform/13-tekton-chains-setup.sh

.PHONY: tekton-generate-keys
tekton-generate-keys: ## Generate key pair for Tekton
	bash scripts/gen-keys.sh

.PHONY: tekton-verify-taskrun
tekton-verify-taskrun: ## Verify taskrun payload against signature
	bash scripts/provenance.sh

.PHONY: install-spire
install-spire: ## install spire
	bash platform/20-spire-install.sh

.PHONY: setup-spire
setup-spire: ## Setup spire
	bash platform/21-spire-setup.sh

.PHONY: install-vault
install-vault: ## Install vault
	bash platform/25-vault-install.sh

.PHONY: setup-vault
setup-vault: ## Setup vault
	bash platform/26-vault-setup.sh

.PHONY: install-kyverno
install-kyverno: ## Install Kyverno
	bash platform/30-kyverno-install.sh

.PHONY: setup-kyverno
setup-kyverno: ## Setup Kyverno
	bash platform/31-kyverno-setup.sh

.PHONY: setup-opa-gatekeeper
setup-opa-gatekeeper: ## Setup opa gatekeeper
	bash platform/35-opa-gatekeeper-setup.sh

.PHONY: setup-efk-stack
setup-efk-stack: ## Setup up EFK stack
	bash platform/40-efk-stack-setup/40-efk-stack-setup.sh

.PHONY: setup-example-mirror
setup-example-mirror: ## Mirror example repos to gitea development server
	bash platform/50-example-mirror.sh

.PHONY: setup-example-buildpacks
setup-example-buildpacks: ## Setup the buildpacks example
	bash examples/buildpacks/buildpacks-setup.sh

.PHONY: setup-example-golang-pipeline
setup-example-golang-pipeline: ## Setup the go-pipeline example
	bash examples/go-pipeline/go-pipeline-setup.sh

.PHONY: setup-example-gradle
setup-example-gradle: ## Setup the gradle example
	bash examples/gradle-pipeline/gradle-pipeline-setup.sh

.PHONY: setup-example-ibm-tutorial
setup-example-ibm-tutorial: ## Setup the IBM pipeline example
	bash examples/ibm-tutorial/ibm-tutorial-setup.sh

.PHONY: setup-example-maven
setup-example-maven: ## Setup the maven example
	bash examples/maven/maven-setup.sh

.PHONY: setup-example-sample
setup-example-sample: ## Setup the sample-pipeline example
	bash examples/sample-pipeline/sample-pipeline-setup.sh

.PHONY: example-buildpacks
example-buildpacks: ## Run the buildpacks example
	bash examples/buildpacks/buildpacks-run.sh

.PHONY: example-cosign
example-cosign: ## Run the cosign example
	bash examples/cosign/cosign.sh

.PHONY: example-golang-pipeline
example-golang-pipeline: ## Run the go-pipeline example
	bash examples/go-pipeline/go-pipeline-run.sh

.PHONY: example-gradle-pipeline
example-gradle-pipeline: ## Run the gradle-pipeline example
	bash examples/gradle-pipeline/gradle-pipeline-run.sh

.PHONY: example-ibm-tutorial
example-ibm-tutorial: ## Run the IBM pipeline example
	bash examples/ibm-tutorial/ibm-tutorial-run.sh

.PHONY: example-maven
example-maven: ## Run the maven example
	bash examples/maven/maven-run.sh

.PHONY: example-sample-pipeline
example-sample-pipeline: ## Run the sample-pipeline example
	bash examples/sample-pipeline/sample-pipeline-run.sh

.PHONY: docs-setup
docs-setup: ## Install the tool to build the documentation
	bash docs/bootstrap.sh

.PHONY: docs-serve
docs-serve: ## Serve the site locally with hot-reloading
	bash docs/serve.sh

.PHONY: docs-build
docs-build: ## Build the documentation site
	cd docs && zola build

.PHONY: lint
lint: lint-md lint-yaml lint-shell ## Run all linters

.PHONY: lint-md
lint-md: ## Lint markdown files
	npx --yes markdownlint-cli2  "**/*.md" "#docs/themes" "#platform/vendor"

.PHONY: lint-shell
lint-shell: ## Lint shell files
	shfmt -f ./ | grep -ve "platform/vendor/.*/" | xargs shellcheck

.PHONY: lint-spellcheck
lint-spellcheck:
	npx --yes cspell --no-progress --show-suggestions --show-context "**/*"

.PHONY: lint-yaml
lint-yaml: ## Lint yaml files
	yamllint .

.PHONY: fmt-md
fmt-md: ## Format markdown files
	npx --yes prettier --write --prose-wrap always "**/*.md"

.PHONY: vendor
vendor: ## vendor upstream projects
	bash platform/vendor/vendor.sh
	bash platform/vendor/vendor-helm-all.sh -f

.PHONY: cue.mod
cue.mod:
	rm -rf cue.mod/gen
	cue get go github.com/kyverno/kyverno/api/kyverno/v1
	cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1
	cue get go github.com/tektoncd/triggers/pkg/apis/triggers/v1beta1
	cue get go k8s.io/api/core/v1
	cue get go k8s.io/api/rbac/v1

.PHONY: setup-tests ## Setup the integration tests
setup-tests:
	cd integration-tests/integration-tests && poetry install --without dev

.PHONY: test ## Run the integration tests
test:
	cd integration-tests/integration-tests \
		&& poetry run pytest -v -m chains --hosts="kubectl://pod?context=minikube&namespace=tekton-chains"
