# policy-controller

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.5.2](https://img.shields.io/badge/AppVersion-0.5.2-informational?style=flat-square)

The Helm chart for Policy  Controller

**Homepage:** <https://github.com/sigstore/policy-controller>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dlorenc |  |  |
| hectorj2f |  |  |

## Source Code

* <https://github.com/sigstore/policy-controller>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonNodeSelector | object | `{}` |  |
| commonTolerations | list | `[]` |  |
| cosign.cosignPub | string | `""` |  |
| cosign.webhookName | string | `"policy.sigstore.dev"` |  |
| imagePullSecrets | list | `[]` |  |
| installCRDs | bool | `true` |  |
| policywebhook.env | object | `{}` |  |
| policywebhook.configData | object | `{}` | Set the data of the `policy-config-controller` configmap |
| policywebhook.extraArgs | object | `{}` |  |
| policywebhook.image.pullPolicy | string | `"IfNotPresent"` |  |
| policywebhook.image.repository | string | `"ghcr.io/sigstore/policy-controller/policy-webhook"` |  |
| policywebhook.image.version | string | `"sha256:ae3d5b549c269c8b2a9b208d812365b6fc610d7a21c9ced8dc7eaae0a1914c09"` | `"v0.5.2"` |
| policywebhook.podSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| policywebhook.podSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| policywebhook.podSecurityContext.enabled | bool | `true` |  |
| policywebhook.podSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| policywebhook.podSecurityContext.runAsNonRoot | bool | `true` |  |
| policywebhook.replicaCount | int | `1` |  |
| policywebhook.resources.limits.cpu | string | `"100m"` |  |
| policywebhook.resources.limits.memory | string | `"256Mi"` |  |
| policywebhook.resources.requests.cpu | string | `"100m"` |  |
| policywebhook.resources.requests.memory | string | `"128Mi"` |  |
| policywebhook.securityContext.enabled | bool | `false` |  |
| policywebhook.securityContext.runAsUser | int | `65532` |  |
| policywebhook.service.annotations | object | `{}` |  |
| policywebhook.service.port | int | `443` |  |
| policywebhook.service.type | string | `"ClusterIP"` |  |
| policywebhook.serviceAccount.annotations | object | `{}` |  |
| policywebhook.webhookNames.defaulting | string | `"defaulting.clusterimagepolicy.sigstore.dev"` |  |
| policywebhook.webhookNames.validating | string | `"validating.clusterimagepolicy.sigstore.dev"` |  |
| serviceMonitor.enabled | bool | `false` |  |
| webhook.env | object | `{}` |  |
| webhook.extraArgs | object | `{}` |  |
| webhook.image.pullPolicy | string | `"IfNotPresent"` |  |
| webhook.image.repository | string | `"ghcr.io/sigstore/policy-controller/policy-controller"` |  |
| webhook.image.version | string | `"sha256:f23a23910f873d01864c01122120666adf78a1dbb43f674c4d423d5fe480a718"` | `"v0.5.2"` |
| webhook.name | string | `"webhook"` |  |
| webhook.podSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| webhook.podSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| webhook.podSecurityContext.enabled | bool | `true` |  |
| webhook.podSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| webhook.podSecurityContext.runAsUser | int | `1000` |  |
| webhook.registryCaBundle | object | `{}` |  |
| webhook.replicaCount | int | `1` |  |
| webhook.resources.limits.cpu | string | `"100m"` |  |
| webhook.resources.limits.memory | string | `"256Mi"` |  |
| webhook.resources.requests.cpu | string | `"100m"` |  |
| webhook.resources.requests.memory | string | `"128Mi"` |  |
| webhook.securityContext.enabled | bool | `false` |  |
| webhook.securityContext.runAsUser | int | `65532` |  |
| webhook.service.annotations | object | `{}` |  |
| webhook.service.port | int | `443` |  |
| webhook.service.type | string | `"ClusterIP"` |  |
| webhook.serviceAccount.annotations | object | `{}` |  |
| webhook.volumeMounts | list | `[]` |  |
| webhook.volumes | list | `[]` |  |
| webhook.namespaceSelector.matchExpressions[0].key | string | `"policy.sigstore.dev/include"` |  |
| webhook.namespaceSelector.matchExpressions[0].operator | string | `"In"` |  |
| webhook.namespaceSelector.matchExpressions[0].values[0] | string | `"true"` |  |

### Deploy `policy-controller` Helm Chart

Install `policy-controller` using Helm:

```shell
helm repo add sigstore https://sigstore.github.io/helm-charts

helm repo update

kubectl create namespace cosign-system

helm install policy-controller -n cosign-system sigstore/policy-controller --devel
```

The `policy-controller` enforce images matching the defined list of `ClusterImagePolicy` for the labeled namespaces.

Note that, by default, the `policy-controller` offers a configurable behavior defining whether to allow, deny or warn whenever an image does not match a policy in a specific namespace. This behavior can be configured using the `config-policy-controller` ConfigMap created under the release namespace, and by adding an entry with the property `no-match-policy` and its value `warn|allow|deny`.
By default, any image that does not match a policy is rejected whenever `no-match-policy` is not configured in the ConfigMap.

As supported in previous versions, you could create your own key pair:

```shell
export COSIGN_PASSWORD=<my_cosign_password>
cosign generate-key-pair
```

This command generates two key files `cosign.key` and `cosign.pub`. Next, create a secret to validate the signatures:

```shell
kubectl create secret generic mysecret -n \
cosign-system --from-file=cosign.pub=./cosign.pub
```

**IMPORTANT:** The `cosign.secretKeyRef` flag is not supported anymore. Finally, you could reuse your secret `mysecret` by creating a `ClusterImagePolicy` that sets it as listed authorities, as shown below.

```yaml
apiVersion: policy.sigstore.dev/v1alpha1
kind: ClusterImagePolicy
metadata:
  name: cip-key-secret
spec:
  images:
  - glob: "**your-desired-value**"
  authorities:
  - key:
      secretRef:
        name: mysecret

```
#### Configuring Custom Certificate Authorities (CA)

The `policy-controller` can be configured to use custom CAs to communicate to container registries, for example, when you have a private registry with a self-signed TLS certificate.

To configure `policy-controller` to use custom CAs, follow these steps:

1. Make sure the `policy-controller` namespace exists:

    ```shell
    kubectl create namespace cosign-system
    ```

2. Create a bundle file with all the root and intermediate certificates and name it `ca-bundle.crt`.

3. Create a `ConfigMap` from the bundle:
    ```shell
    kubectl -n cosign-system create cm ca-bundle-config \
      --from-file=ca-bundle.crt="ca-bundle.crt"
    ```

4. Install the `policy-controller`:

    ```shell
    helm install -n cosign-system \
      --set webhook.registryCaBundle.name=ca-bundle-config \
      --set webhook.registryCaBundle.key=ca-bundle.crt \
      policy-controller sigstore/policy-controller
    ```

### Enabling Admission control

To enable the `policy admission webhook` to check for signed images, you will need to add the following label in each namespace that you would want the webhook triggered:

Label: `policy.sigstore.dev/include: "true"`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    policy.sigstore.dev/include: "true"
    kubernetes.io/metadata.name: my-namespace
  name: my-namespace
spec:
  finalizers:
  - kubernetes
```

### Testing the webhook

1. Using Unsigned Images:
Creating a deployment referencing images that are not signed will yield the following error and no resources will be created:

    ```shell
    kubectl apply -f my-deployment.yaml
    Error from server (BadRequest): error when creating "my-deployment.yaml": admission webhook "policy.sigstore.dev" denied the request: validation failed: invalid image signature: spec.template.spec.containers[0].image
    ```

2. Using Signed Images: Assuming a signed `nginx` image with a tag `signed` exists on a registry, the resource will be successfully created.

   ```shell
   kubectl run pod1-signed  --image=< REGISTRY_USER >/nginx:signed -n testns
   pod/pod1-signed created
   ```


## More info

You can find more information about the policy-controller in [here](https://docs.sigstore.dev/policy-controller/overview/).
