# IBM Tutorial Demo

## Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys setup-kyverno

## In a separate terminal, port forward the registry: defaults to localhost:8888
#  make registry-proxy

# Run a new pipeline.
make example-ibm-tutorial
# Or re-run the last one.
# tkn pipeline start build-and-deploy-pipeline -L

# Export name of the docker image from the pipelinerun as DOCKER_IMG:
IMAGE_URL=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageUrl")].value}')
export IMAGE_URL=localhost:8888${IMAGE_URL#"registry.kube-system.svc.cluster.local"}
export IMAGE_TAG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageTag")].value}')
export DOCKER_IMG="${IMAGE_URL}:${IMAGE_TAG}"

# Wait until it completes.
tkn pr logs --last -f

# Ensure it has been signed.
tkn tr describe --last -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output "true"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "${IMAGE_URL}"

# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
```

## Links

- [Build and deploy a Docker image on Kubernetes using Tekton Pipelines](https://developer.ibm.com/devpractices/devops/tutorials/build-and-deploy-a-docker-image-on-kubernetes-using-tekton-pipelines/#create-a-task-to-clone-the-git-repository)
