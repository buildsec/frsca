# FRSCA Sample Tekton Pipeline

This is a sample tekton based application build pipeline.

> :warning: This pipeline is not intended to be used in production

Follow these instructions to setup this pipeline and run it against your sample
application repository. In this example, we are going to build and deploy
[tekton-tutorial-openshift](https://github.com/IBM/tekton-tutorial-openshift)
application. You can use `minikube` to run your tekton pipeline and deploy this
application.

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Use the built-in registry, or replace with your own local registry
export REGISTRY=host.minikube.internal:5443

# Setup FRSCA environment
make setup-frsca

# if using the built-in registry, run the proxy in the background or another window
make registry-proxy >/dev/null &

# Run a new pipeline.
make example-sample-pipeline

# Wait until it completes.
tkn pr logs --last -f

# Export the value of IMAGE_URL from the last taskrun and the taskrun name:
IMAGE_URL=$(tkn pr describe --last -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name == "IMAGE_URL") | .value')
TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] as $k | {"k": $k, "v": .[$k]} | select(.v.status.taskResults[]?.name == "IMAGE_URL") | .k')
if [ "${REGISTRY}" = "registry.registry" ] || [ "${REGISTRY}" = "host.minikube.internal:5443" ]; then
  : "${REGISTRY_PORT:=5000}"
  IMAGE_URL="$(echo "${IMAGE_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:'${REGISTRY_PORT}'#')"
fi

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"

# Verify the image and the attestation.
cosign verify --insecure-ignore-tlog --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --insecure-ignore-tlog --type slsaprovenance --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"

# Download the SBOM
cosign download sbom "${IMAGE_URL}"

# Verify the signature and attestation with tkn.
# These commands do not work with the built in registry.
tkn chain signature "${TASK_RUN}"
tkn chain payload "${TASK_RUN}"

# if the registry proxy is running in the background, it can be stopped
kill %?registry-proxy
```

Once successfully completed. You should be able to see your application deployed
on the cluster

```bash
% kubectl get all -n prod
NAME                          READY   STATUS    RESTARTS   AGE
pod/picalc-576dd6b788-sszmh   1/1     Running   0          32s

NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/picalc   NodePort   10.107.77.128   <none>        8080:30907/TCP   37s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/picalc   1/1     1            1           38s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/picalc-576dd6b788   1         1         1       38s
```
