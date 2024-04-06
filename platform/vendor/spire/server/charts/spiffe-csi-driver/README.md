# spiffe-csi-driver

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.3](https://img.shields.io/badge/AppVersion-0.2.3-informational?style=flat-square)

A Helm chart to install the SPIFFE CSI driver.

**Homepage:** <https://github.com/spiffe/helm-charts-hardened/tree/main/charts/spire>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| marcofranssen | <marco.franssen@gmail.com> | <https://marcofranssen.nl> |
| kfox1111 | <Kevin.Fox@pnnl.gov> |  |
| faisal-memon | <fymemon@yahoo.com> |  |
| edwbuck | <edwbuck@gmail.com> |  |

## Source Code

* <https://github.com/spiffe/helm-charts-hardened/tree/main/charts/spire>

<!-- The parameters section is generated using helm-docs.sh and should not be edited by hand. -->

## Parameters

### SPIFFE CSI Driver Chart parameters

| Name                                          | Description                                                                                                    | Value                                       |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `pluginName`                                  | Set the csi driver name deployed to Kubernetes.                                                                | `csi.spiffe.io`                             |
| `image.registry`                              | The OCI registry to pull the image from                                                                        | `ghcr.io`                                   |
| `image.repository`                            | The repository within the registry                                                                             | `spiffe/spiffe-csi-driver`                  |
| `image.pullPolicy`                            | The image pull policy                                                                                          | `IfNotPresent`                              |
| `image.tag`                                   | Overrides the image tag whose default is the chart appVersion                                                  | `""`                                        |
| `resources`                                   | Resource requests and limits for spiffe-csi-driver                                                             | `{}`                                        |
| `healthChecks.port`                           | The healthcheck port for spiffe-csi-driver                                                                     | `9809`                                      |
| `updateStrategy.type`                         | The update strategy to use to replace existing DaemonSet pods with new pods. Can be RollingUpdate or OnDelete. | `RollingUpdate`                             |
| `updateStrategy.rollingUpdate.maxUnavailable` | Max unavailable pods during update. Can be a number or a percentage.                                           | `1`                                         |
| `livenessProbe.initialDelaySeconds`           | Initial delay seconds for livenessProbe                                                                        | `5`                                         |
| `livenessProbe.timeoutSeconds`                | Timeout value in seconds for livenessProbe                                                                     | `5`                                         |
| `imagePullSecrets`                            | Image pull secret details for spiffe-csi-driver                                                                | `[]`                                        |
| `nameOverride`                                | Name override for spiffe-csi-driver                                                                            | `""`                                        |
| `namespaceOverride`                           | Namespace to install spiffe-csi-driver                                                                         | `""`                                        |
| `fullnameOverride`                            | Full name override for spiffe-csi-driver                                                                       | `""`                                        |
| `csiDriverLabels`                             | Labels to apply to the CSIDriver                                                                               | `{}`                                        |
| `initContainers`                              | Init Containers to apply to the CSI Driver DaemonSet                                                           | `[]`                                        |
| `serviceAccount.create`                       | Specifies whether a service account should be created                                                          | `true`                                      |
| `serviceAccount.annotations`                  | Annotations to add to the service account                                                                      | `{}`                                        |
| `serviceAccount.name`                         | The name of the service account to use. If not set and create is true, a name is generated.                    | `""`                                        |
| `podAnnotations`                              | Pod annotations for spiffe-csi-driver                                                                          | `{}`                                        |
| `podSecurityContext`                          | Security context for CSI driver pods                                                                           | `{}`                                        |
| `securityContext.readOnlyRootFilesystem`      | Flag for read only root filesystem                                                                             | `true`                                      |
| `securityContext.privileged`                  | Flag for specifying privileged mode                                                                            | `true`                                      |
| `nodeSelector`                                | Node selector for CSI driver pods                                                                              | `{}`                                        |
| `tolerations`                                 | Tolerations for CSI driver pods                                                                                | `[]`                                        |
| `affinity`                                    | Node affinity                                                                                                  | `{}`                                        |
| `nodeDriverRegistrar.image.registry`          | The OCI registry to pull the image from                                                                        | `registry.k8s.io`                           |
| `nodeDriverRegistrar.image.repository`        | The repository within the registry                                                                             | `sig-storage/csi-node-driver-registrar`     |
| `nodeDriverRegistrar.image.pullPolicy`        | The image pull policy                                                                                          | `IfNotPresent`                              |
| `nodeDriverRegistrar.image.tag`               | Overrides the image tag                                                                                        | `v2.9.4`                                    |
| `nodeDriverRegistrar.resources`               | Resource requests and limits for CSI driver pods                                                               | `{}`                                        |
| `agentSocketPath`                             | The unix socket path to the spire-agent                                                                        | `/run/spire/agent-sockets/spire-agent.sock` |
| `kubeletPath`                                 | Path to kubelet file                                                                                           | `/var/lib/kubelet`                          |
| `priorityClassName`                           | Priority class assigned to daemonset pods. Can be auto set with global.recommendations.priorityClassName.      | `""`                                        |
| `restrictedScc.enabled`                       | Enables the creation of a SecurityContextConstraint based on the restricted SCC with CSI volume support        | `false`                                     |
| `restrictedScc.name`                          | Set the name of the restricted SCC with CSI support                                                            | `""`                                        |
| `restrictedScc.version`                       | Version of the restricted SCC                                                                                  | `2`                                         |
| `selinux.enabled`                             | Enable selinux support                                                                                         | `false`                                     |
| `selinux.context`                             | Which selinux context to use                                                                                   | `container_file_t`                          |
| `selinux.image.registry`                      | The OCI registry to pull the image from                                                                        | `registry.access.redhat.com`                |
| `selinux.image.repository`                    | The repository within the registry                                                                             | `ubi9`                                      |
| `selinux.image.pullPolicy`                    | The image pull policy                                                                                          | `Always`                                    |
| `selinux.image.tag`                           | Overrides the image tag whose default is the chart appVersion                                                  | `latest`                                    |

