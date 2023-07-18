# FRSCA Gradle Tekton Pipeline

This is a sample Gradle tekton pipeline.

> :warning: This pipeline is not intended to be used in production

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Use the built-in registry, or replace with your own local registry
export REGISTRY=registry.registry

# Setup FRSCA environment
make setup-frsca

# if using the built-in registry, run the proxy in the background or another window
make registry-proxy >/dev/null &

# Run a new pipeline.
make example-gradle-pipeline

# Wait until it completes.
tkn pr logs --last -f

# Export the value of IMAGE_URL from the last pipeline run and the associated taskrun name:
TASK_RUNS=($(tkn pr describe --last -o jsonpath='{.status.childReferences}' | jq -r '.[] | select(.kind | match("TaskRun")) | .name'))
TASK_RUN="none" IMAGE_URL="none"; for tr in "${TASK_RUNS[@]}"; do
  image=$(tkn tr describe "${tr}" -o jsonpath='{.status.results}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')
  if [ -n "${image}" ]; then
    TASK_RUN="${tr}"
    IMAGE_URL="${image}"
    break
  fi
done
if [ "${REGISTRY}" = "registry.registry" ]; then
  : "${REGISTRY_PORT:=5000}"
  IMAGE_URL="$(echo "${IMAGE_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:'${REGISTRY_PORT}'#')"
fi

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"

# Verify the image and the attestation.
cosign verify --insecure-ignore-tlog --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --insecure-ignore-tlog --type slsaprovenance --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"

# Verify the signature and attestation with tkn.
# These commands do not work with the built in registry.
tkn chain signature "${TASK_RUN}"
tkn chain payload "${TASK_RUN}"

# if the registry proxy is running in the background, it can be stopped
kill %?registry-proxy
```
