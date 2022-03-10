# SSF Gradle Tekton Pipeline

This is a sample Gradle tekton pipeline.

> :warning: This pipeline is not intended to be used in production

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys setup-kyverno

# Run a new pipeline.
make example-gradle-pipeline

# Export the value of image from the pipelinerun describe as DOCKER_IMG:
export DOCKER_IMG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="image")].value}')

# Wait until it completes.
tkn pr logs --last -f

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "${DOCKER_IMG}"

# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
```
