# SSF Sample Tekton Pipeline

This is a sample tekton based application build pipepline. 

> :warning: This pipeline is not intended to be used in production

Follow these instructions to setup this pipeline and run it against your sample application repository.
In this example, we are going to build and deploy [tekton-tutorial-openshift](https://github.com/IBM/tekton-tutorial-openshift) application.
You can use `minikube` to run your tekton pipeline and deploy this application.

## Getting ready

1. Make sure you have `kubectl` configured with access to some kubernetes cluster
2. You have access to some container registry and update registry credentials in `registry-secret.yaml`

```bash
   # replace <oci-registry> with your container registry url
   # replace <api-key> with your api key
   # replace <api-user> with your username
   # replace <email-address> with your email

   kubectl create secret --dry-run=true -o yaml docker-registry registry-key --docker-server=<oci-registry> --docker-password=<api-key> --docker-username=<api-user> --docker-email=<email-address>
```

Copy `.dockerconfigjson` value from the output to `registry-secret.yaml` 

## Verify your pipeline

Before we start using our pipeline, we should always ensure the pipeline definitions are trusted. In this example, we have signed all the pipeline and task definitions, as well as all the images used in the tasks. We have used [sigstore/cosign](https://github.com/sigstore/cosign) to sign these resources, as annotated respectively.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  annotations:
    cosign.sigstore.dev/imageRef: icr.io/gitsecure/git-clone:v1
```

You can verify these definitions using [tapstry-pipelines](https://github.com/tap8stry/tapestry-pipelines) tool using the provided public key.

```bash
# Assuming you have cloned this repo locally and `chdir` to `sample-pipeline` directory
% tapestry-pipelines tkn verify -d . -i icr.io/gitsecure -t v1 -key ssf-verify.pub
```

## Setup Pipeline

```bash
# Setup access secrets
% kubectl create -f registry-secret.yaml
% kubectl create -f pipeline-account.yaml

# Setup core tasks
% kubectl create -f task-git-clone.yaml
% kubectl create -f task-build-push-image.yaml
% kubectl create -f task-deploy.yaml
% kubectl create -f task-syft-bom-generation.yaml
% kubectl create -f task-gyrpe-scan.yaml

# Setup pipeline
% kubectl create -f ssf-pipeline.yaml
```

## Run Pipeline

In this example, we are using [tekton-tutorial-openshift](https://github.com/IBM/tekton-tutorial-openshift) application sample application. If you want to use other application, make sure to make corresponding changes to `ssf-run.yaml`. You may also have to change params to `build` and `deploy` tasks to reflect correct location for `Dockerfile` context and deployment file resp.

```bash
% kubectl create -f ssf-run.yaml
```

## Observing

To observe execution of the pipeline, consider setting up [tektoncd/dashboard](https://github.com/tektoncd/dashboard). 
The SBOM and vulnerability-report are accessible only in the task logs. 

Once successfully completed. You should be able to see your application deployed on the cluster

```bash
% kubectl get pod
NAME                                                             READY   STATUS      RESTARTS   AGE
picalc-cf9dddfdf-bnwv8                                           1/1     Running     0          59m
```