# Kubernetes provenance

This is a collection of scripts to setup Kubernetes demo showcasing [Tekton],
[Chains] and [Spire].

The script are controlled by environment variables, each documented in the
scripts themselves.

## Setup

### 00-kubernetes-minikube-setup.sh

Setup a minikube cluster with options that would be valid for all demos.

## Tekton

### 10-tekton-setup.sh

Setup [Tekton], the [dashboard] and create 2 test pipelines. The first one uses
only resources from the [catalog], the second one coming from a tutorial from
IBM.

### 11-tekton-chains.sh

Setup [chains] to establish the provenance.

The folder `kubernetes/scripts contains script to generate signing keys and to
extract the provenance information from a task.

## Spire

### 20-spire-setup.sh

Script automating the [Spire] setup as defined in the getting started tutorial.

[Tekton]: https://tekton.dev/
[dashboard]: https://github.com/tektoncd/dashboard
[Chains]: https://github.com/tektoncd/chains
[Spire]: https://spiffe.io/docs/latest/spire-about/
[catalog]: https://github.com/tektoncd/catalog
