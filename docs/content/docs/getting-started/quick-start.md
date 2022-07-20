+++
title = "Quick Start"
description = "One page summary about how to setup a new FRSCA."
date = 2021-11-26T08:20:00+00:00
updated = 2021-11-26T08:20:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "One page summary of how to setup a new FRSCA."
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

### Step 2: setup frsca

[Tekton Pipelines] and [Tekton Chains] are the foundations of the secure
software factory. This example sets up local certificates and local registry.

The next command will deploy and configure them:

```bash
make setup-frsca
```

### Step 3: use local registry (optional)

The examples use the [ttl.sh](https://ttl.sh) registry to upload images by
default. It is possible to change it to another registry of your choice by
exporting the `$REGISTRY` variable.

You may also use the local registry deployed inside the cluster. This requires
setting the variable to `registry.registry`:

```bash
export REGISTRY=registry.registry
```

Then to access the registry outside of minikube, open a separate terminal and
run the following command to enable port forwarding:

```bash
make registry-proxy
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

#### First some convenience exports

We start by defining some variables to simplify the validation commands:

```bash
export IMAGE_URL=$(tkn pr describe --last -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')
export TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] as $k | {"k": $k, "v": .[$k]} | select(.v.status.taskResults[]?.name | match("IMAGE_URL$")) | .k')
```

If you are using the local registry, you will also need to change the registry
name to the port exposed by the registry proxy:

```bash
export IMAGE_URL="$(echo "${IMAGE_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:5000#')"
```

#### Ensure the task has been signed

```bash
tkn tr describe --last -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output "true"
```

#### Ensure the attestation and the signature were uploaded to OCI

```bash
crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"
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
cosign verify --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
```

With Tekton CLI (v0.23.0+):

```bash
tkn chain signature "${TASK_RUN}"
tkn chain payload "${TASK_RUN}"
```
