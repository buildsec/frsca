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
# Wait until it completes.

# Ensure it has been signed.
tkn tr describe --last -o json | jq -r '.metadata.annotations["chains.tekton.dev/signed"]'
# Should output "true"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls ttl.sh/slsapoc

# Verify the image and the attestation.
export DOCKER_IMG=ttl.sh/slsapoc
cosign verify -key $COSIGN_PUB ${DOCKER_IMG}
cosign verify-attestation -key $COSIGN_PUB ${DOCKER_IMG}
```

## Links

* Buildpacks: <https://buildpacks.io/>
