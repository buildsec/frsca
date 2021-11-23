+++
title = "Quick Start"
description = "One page summary about how to setup a new SSF."
date = 2021-11-26T08:20:00+00:00
updated = 2021-11-26T08:20:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "One page summary of how to setup a new SSF."
toc = true
top = false
+++

## Requirements

The requirements will be installed automatically by the scripts if they are not
detected, but for information they are listed in a
[dedicated section bellow](#requirement-list) .

## Installation steps

### Step 1: start your cluster (optional)

If you do not have a Kubernetes cluster ready to use, this command will
provision and configure `minikube`:

```bash
make setup-minikube
```

### Step 2: prepare minikube registry (optional)

The examples use the [ttl.sh](https://ttl.sh) registry to upload images by
default. It is possible to change it to any registry of your choice.

You may also use the registry addon coming with `minikube`. To do so, open a
separate terminal run the following command to enable port forwarding:

```bash
./platform/05-minikube-registry-proxy.sh
```

### Step 3: setup tekton w/ chains

[Tekton Pipelines] and [Tekton Chains] are the foundations of the secure
software factory. The next command will deploy and configure them:

```bash
make setup-tekton-chains tekton-generate-keys setup-kyverno
```

### Step 4: run a new pipeline

Several pipelines are provided as examples, feel free to choose any of them.

An installer is provided with each example. They can be executed from the root
of this repository using the following syntax:

```bash
./examples/<tutorial-name>/<tutorial-name>.sh
```

For instance:

```bash
./examples/ibm-tutorial/ibm-tutorial.sh
```

Follow the progression and wait until the pipeline completes to proceed with the
next steps. The logs can be displayed with:

```bash
tkn pr logs --last -f
```

### Step 5: validations

#### First some convenience exports

We start by defining some variables to simplify the validation commands:

```bash
IMAGE_URL=$(tkn pr describe --last -o json | jq -r '.spec.params[] | select(.name=="imageUrl") | .value')
export IMAGE_URL=localhost:8888${IMAGE_URL#"registry.kube-system.svc.cluster.local"}
export IMAGE_TAG=$(tkn pr describe --last -o json | jq -r '.spec.params[] | select(.name=="imageTag") | .value')
export DOCKER_IMG="${IMAGE_URL}:${IMAGE_TAG}"
export COSIGN_KEY="k8s://tekton-chains/signing-secrets"
```

#### Ensure the task has been signed

```bash
tkn tr describe --last -o json | jq -r '.metadata.annotations["chains.tekton.dev/signed"]'
# Should output "true"
```

#### Ensure the attestation and the signature were uploaded to OCI

```bash
crane ls "${IMAGE_URL}"
```

#### Verify the image and the attestation

```bash
cosign verify --key "${COSIGN_KEY}" "${DOCKER_IMG}"
cosign verify-attestation --key "${COSIGN_KEY}" "${DOCKER_IMG}"
```

## Requirement list

### Platform

* [Kubernetes](http://k8s.io/)
* [Tekton Pipelines]
* [Tekton Chains]
* [Spire](https://spiffe.io/)
* [Kyverno](https://kyverno.io/)

### Tooling

* [Cosign/Sget](https://github.com/sigstore/cosign)
* [Crane](https://github.com/google/go-containerregistry)
* [Make](https://www.gnu.org/software/make/)
* [Rekor CLI](https://github.com/sigstore/rekor)
* [Cue](https://cuelang.org/)

## TODO BEFORE MERGEABLE

* Everything should come from the Makefile
  * make start-registry-proxy
  * make example-buildpacks
  * probably also the verification commands
* Provide output examples when applicable
  * crane ls IMG

[Tekton Chains]: https://github.com/tektoncd/chains
[Tekton Pipelines]: https://tekton.dev/
