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

# Wait until it completes.
tkn pr logs --last -f

# Export the value of IMAGE_URL from the last pipeline run and the associated taskrun name:
export IMAGE_URL="$(tkn pr describe --last -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')"
export TASK_RUN="$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] as $k | {"k": $k, "v": .[$k]} | select(.v.status.taskResults[]?.name | match("IMAGE_URL$")) | .k')"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"

# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"

# Verify the signature and attestation with tkn.
tkn chain signature "${TASK_RUN}"
tkn chain payload "${TASK_RUN}"
```
