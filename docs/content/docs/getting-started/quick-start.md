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
detected, but for information they are listed on the introduction page.

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
separate terminal and run the following command to enable port forwarding:

```bash
make registry-proxy
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
make example-<tutorial-name>
```

For instance:

```bash
make example-ibm-tutorial
```

Follow the progression and wait until the pipeline completes to proceed with the
next steps. The logs can be displayed with:

```bash
tkn pr logs --last -f
```

### Step 5: validations

> **_NOTE:_** The following assumes you are running a local registry proxy (i.e.
> `make registry-proxy`). It also assumes you have run the IBM tutorial example
> (i.e. `make example-ibm-tutorial`).

#### First some convenience exports

We start by defining some variables to simplify the validation commands:

```bash
IMAGE_URL=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageUrl")].value}')
export IMAGE_URL=localhost:8888${IMAGE_URL#"registry.kube-system.svc.cluster.local"}
export IMAGE_TAG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageTag")].value}')
export DOCKER_IMG="${IMAGE_URL}:${IMAGE_TAG}"
```

#### Ensure the task has been signed

```bash
tkn tr describe --last -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output "true"
```

#### Ensure the attestation and the signature were uploaded to OCI

```bash
crane ls "${IMAGE_URL}"
```

The output should look similar to this:

```bash
$ crane ls ttl.sh/b4527e3a81ef1b77b96d390163ddaad9/slsapoc
latest
sha256-f82fe2b635e304c7d8445c0117a4dbe35dd3c840078a39e21c88073a885c5e0f.att
sha256-f82fe2b635e304c7d8445c0117a4dbe35dd3c840078a39e21c88073a885c5e0f.sig
```

#### Verify the image and the attestation

```bash
cosign verify --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
```
