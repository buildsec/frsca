# Dual storage backend setup

## Use cases

### Migration

An organization might already have a provenance storage set up for a provider,
e.g. oci, and they want to move to document storage docdb. To ease the
transition, they might want to output to both simultaneously during that
transition/migration period.

### Duplication due to requirements, regulated or otherwise

An organization's security policy or regulatory requirements may dictate the
data needs to be stored within multiple systems be it for redundancy or
different methods of analysis/usage:

- e.g. docdb for querying, oci for keeping the provenance next to signatures, or
  gcs for longer term archive storage
- if there is an issue with one of the storage methods either due to chains or
  an outage with that particular method of storage

## Setup

Assuming you don't have a Kubernetes cluster available, start by spinning one
up. We provide a simple command to provision minikube. Run the following command
from the root of the FRSCA project:

```bash
make setup-minikube
```

Setup tekton and chains:

```bash
make setup-tekton-chains
```

Configure Chains to use two storage backends and generate encryption keys:

```bash
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{"artifacts.oci.format":"simplesigning", "artifacts.oci.storage": "tekton,oci", "artifacts.taskrun.format":"slsa/v1", "artifacts.taskrun.storage": "tekton,oci"}}'
make tekton-generate-keys
```

Here the configuration specifies two storages for the artifacts: `tekton,oci`
and their respective formats: `slsa/v1` and `simplesigning`.

Start the buildpacks pipeline:

```bash
make example-buildpacks
```

Wait a little bit until it completes and ensure the last task has been signed:

```bash
tkn tr describe --last -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output `true`
```

Set some useful variables:

```bash
export IMAGE_URL=$(tkn tr describe --last -o  jsonpath='{.status.taskResults[?(@.name=="APP_IMAGE_URL")].value}')
export TASKRUN_UID=$(tkn tr describe --last -o  jsonpath='{.metadata.uid}')
```

Use cosign to verify the signature and the attestation stored in OCI:

```bash
cosign verify --key k8s://tekton-chains/signing-secrets ${IMAGE_URL}
cosign verify-attestation --type slsaprovenance --key k8s://tekton-chains/signing-secrets ${IMAGE_URL}
```

Retrieve the signature and the attestation stored in the taskrun annotations:

```bash
tkn tr describe --last -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/payload-taskrun-$TASKRUN_UID}" | base64 -d | jq
tkn tr describe --last -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/signature-taskrun-$TASKRUN_UID}" | base64 -d | jq
```

Verify the attestation with cosign 1.5.1+:

```bash
tkn tr describe --last -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/signature-taskrun-$TASKRUN_UID}" | base64 -d > sig
cosign verify-blob --key k8s://tekton-chains/signing-secrets --signature sig sig
# Should output `Verified OK`
```

## Advanced concepts

### Parametrizing pipelines with CUE

In this example, we are using [CUE](https://cuelang.org/) to parametrize the
pipeline run.

We want to be able to customize the repository, the image name and the cache
image name, but we want to use sensible defaults values. We defined them as
follow in the `buildpacks.cue` file:

```cue
_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/slsapoc" | string @tag(appImage)
_CACHE_IMAGE: *"\(_REPOSITORY)/slsapoc-cache" | string @tag(cacheImage)
```

The rest of the `.cue` file is straightforward to read as is resembles to
standard YAML, with the use of the variables previously defined.

The pipeline is then being created is `cue` and `kubectl`.

First we run the `apply` command to prepare all the kubernetes objects that are
required for the pipeline to run:

```cue
cue apply ./examples/buildpacks | kubectl apply -f -
```

Then we create the pipeline itself:

```cue
cue create ./examples/buildpacks | kubectl create -f -
```

If we need to specify a value for a parameter we can add it to the cue commands,
like for instance `-t repository=double-backend-tutorial`.
