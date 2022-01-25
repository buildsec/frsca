# SSF Sample Tekton Pipeline

This is a sample tekton based application build pipepline.

> :warning: This pipeline is not intended to be used in production

Follow these instructions to setup this pipeline and run it against your sample
application repository.
In this example, we are going to build and deploy
[tekton-tutorial-openshift](https://github.com/IBM/tekton-tutorial-openshift)
application.
You can use `minikube` to run your tekton pipeline and deploy this application.

## Verify your pipeline

Before we start using our pipeline, we should always ensure the pipeline
definitions are trusted. In this example, we have signed all the pipeline
and task definitions, as well as all the images used in the tasks.
We have used [sigstore/cosign](https://github.com/sigstore/cosign) to sign
these resources, as annotated respectively.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  annotations:
    cosign.sigstore.dev/imageRef: icr.io/gitsecure/git-clone:v1
```

You can verify these definitions using
[tapstry-pipelines](https://github.com/tap8stry/tapestry-pipelines) tool using
the provided public key.

```bash
# Assuming you have cloned this repo locally and `chdir` to `sample-pipeline` 
# directory
% tapestry-pipelines tkn verify -d . -i icr.io/gitsecure -t v1 -key ssf-verify.pub
```

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys setup-kyverno

# Run a new pipeline.
make example-sample-pipeline

# Export the value of imageUrl from the pipelinerun describe as DOCKER_IMG:
export IMAGE_URL=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageUrl")].value}')
export IMAGE_TAG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="imageTag")].value}')
export DOCKER_IMG="${IMAGE_URL}:${IMAGE_TAG}"

# Wait until it completes.
tkn pr logs --last -f

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "${IMAGE_URL}"

# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
```

Once successfully completed. You should be able to see your application
deployed on the cluster

```bash
% kubectl get pod
NAME                                         READY   STATUS      RESTARTS   AGE
picalc-cf9dddfdf-bnwv8                       1/1     Running     0          59m
```
