# FRSCA Maven Tekton Pipeline

This is a sample maven tekton pipeline.

> :warning: This pipeline is not intended to be used in production

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup FRSCA environment
make setup-frsca

# Run a new pipeline.
make example-maven

# Wait until it completes.
tkn pr logs --last -f

# Export some values for OCI image urls and the task runs that created them
export ARTIFACT_TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] | select(match("upload-artifact$"))' | tr -d '[:space:]')
export ARTIFACT_URL=$(tkn tr describe ${ARTIFACT_TASK_RUN} -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')
export SBOM_TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] | select(match("attach-sbom$"))' | tr -d '[:space:]')
export SBOM_URL=$(tkn tr describe ${SBOM_TASK_RUN} -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')

## If using the registry-proxy
# export ARTIFACT_URL="$(echo "${ARTIFACT_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:5000#')"
# export SBOM_URL="$(echo "${SBOM_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:5000#')"

# Double check that the attestation, signature and SBOM were uploaded to the OCI.
crane ls "$(echo -n ${ARTIFACT_URL} | sed 's|:[^/]*$||')"

# Verify the artifact image and the attestation with cosign.
cosign verify --key k8s://tekton-chains/signing-secrets "${ARTIFACT_URL}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${ARTIFACT_URL}"

# Verify the SBOM image and the attestation with cosign.
cosign verify --key k8s://tekton-chains/signing-secrets "${SBOM_URL}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${SBOM_URL}"
```

## References

- <https://github.com/redhat-scholars/tekton-tutorial>
- <https://redhat-scholars.github.io/tekton-tutorial/tekton-tutorial/>
- <https://github.com/redhat-scholars/tekton-tutorial-greeter>
