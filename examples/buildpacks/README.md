# buildpacks

## How to run this demo

Execute the following commands from the root of this repository:

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys
export COSIGN_PUB=${PWD}/cosign.pub

# Run a new pipeline.
./examples/buildpacks/buildpacks.sh
# Or re-run the last one.
# tkn pipeline start buildpacks -L

# Export the value of APP_IMAGE from the pipelinerun describe as DOCKER_IMG:
export DOCKER_IMG=$(tkn pr describe --last -o json | jq -r '.spec.params[] | select(.name=="APP_IMAGE") | .value')

# Wait until it completes.
tkn pr logs --last -f

# Ensure it has been signed.
tkn tr describe --last -o json | jq -r '.metadata.annotations["chains.tekton.dev/signed"]'
# Should output "true"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls ${DOCKER_IMG}

# Verify the image and the attestation.
cosign verify --key $COSIGN_PUB ${DOCKER_IMG}
cosign verify-attestation --key $COSIGN_PUB ${DOCKER_IMG}
```

## Links

* Buildpacks: <https://buildpacks.io/>
