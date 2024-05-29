# tornjak-frontend

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.2.2](https://img.shields.io/badge/AppVersion-v1.2.2-informational?style=flat-square)
[![Development Phase](https://github.com/spiffe/spiffe/blob/main/.img/maturity/dev.svg)](https://github.com/spiffe/spiffe/blob/main/MATURITY.md#development)

A Helm chart to deploy Tornjak frontend

**Homepage:** <https://github.com/spiffe/helm-charts-hardened/tree/main/charts/spire>

## Version support

> [!Note]
> This Chart is still in development and still subject to change the API (`values.yaml`).
> Until we reach a `1.0.0` version of the chart we can't guarantee backwards compatibility although
> we do aim for as much stability as possible.

| Dependency | Supported Versions |
|:-----------|:-------------------|
| Helm       | `3.x`              |

## Tornjak

Tornjak is the UI and Control Plane for SPIRE [https://github.com/spiffe/tornjak](https://github.com/spiffe/tornjak) and it is composed of two components:

* [Backend](../spire-server/README.md) - Tornjak APIs that extend SPIRE APIs with Control Plane functionality
* Frontend (this chart) - Tornjak UI

## Prerequisites

This chart requires access to Tornjak Backend (`tornjakFrontend.apiServerURL`).
This URL needs to be reachable from your web browser and can therefore not be a cluster internal URL.

Obtain the URL for Tornjak APIs. If deployed in the same cluster, locally,
Tornjak APIs are typically available at `http://localhost:10000`.
Review Tornjak documentation for more details.

## Usage

Since this is just a demo version, to access Tornjak APIs you can use
port forwarding. See the chart NOTES output for more details.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| mrsabath | <mrsabath@gmail.com> | <https://mrsabath.github.io> |

## Source Code

* <https://github.com/spiffe/tornjak>

<!-- The parameters section is generated using helm-docs.sh and should not be edited by hand. -->

## Parameters

### Chart parameters

| Name                               | Description                                                                                                                                                                                                                            | Value                                                                            |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `image.registry`                   | The OCI registry to pull the image from                                                                                                                                                                                                | `ghcr.io`                                                                        |
| `image.repository`                 | The repository within the registry                                                                                                                                                                                                     | `spiffe/tornjak-frontend`                                                        |
| `image.pullPolicy`                 | The image pull policy                                                                                                                                                                                                                  | `IfNotPresent`                                                                   |
| `image.tag`                        | Overrides the image tag whose default is the chart appVersion                                                                                                                                                                          | `""`                                                                             |
| `imagePullSecrets`                 | Pull secrets for images                                                                                                                                                                                                                | `[]`                                                                             |
| `nameOverride`                     | Name override                                                                                                                                                                                                                          | `""`                                                                             |
| `namespaceOverride`                | Namespace override                                                                                                                                                                                                                     | `""`                                                                             |
| `fullnameOverride`                 | Fullname override                                                                                                                                                                                                                      | `""`                                                                             |
| `serviceAccount.create`            | Specifies whether a service account should be created                                                                                                                                                                                  | `true`                                                                           |
| `serviceAccount.annotations`       | Annotations to add to the service account                                                                                                                                                                                              | `{}`                                                                             |
| `serviceAccount.name`              | The name of the service account to use. If not set and create is true, a name is generated.                                                                                                                                            | `""`                                                                             |
| `labels`                           | Labels for tornjak frontend pods                                                                                                                                                                                                       | `{}`                                                                             |
| `podSecurityContext`               | Pod security context                                                                                                                                                                                                                   | `{}`                                                                             |
| `securityContext`                  | Security context                                                                                                                                                                                                                       | `{}`                                                                             |
| `service.type`                     | Service type                                                                                                                                                                                                                           | `ClusterIP`                                                                      |
| `service.port`                     | Service port                                                                                                                                                                                                                           | `3000`                                                                           |
| `service.annotations`              | Annotations for service resource                                                                                                                                                                                                       | `{}`                                                                             |
| `nodeSelector`                     | Select specific nodes to run on (currently only amd64 is supported by Tornjak)                                                                                                                                                         |                                                                                  |
| `affinity`                         | Affinity rules                                                                                                                                                                                                                         | `{}`                                                                             |
| `tolerations`                      | List of tolerations                                                                                                                                                                                                                    | `[]`                                                                             |
| `topologySpreadConstraints`        | List of topology spread constraints for resilience                                                                                                                                                                                     | `[]`                                                                             |
| `apiServerURL`                     | URL of the Tornjak APIs (backend). Since Tornjak Frontend runs in the browser, this URL must be accessible from the machine running a browser. If unset, autodetection is atempted.                                                    | `""`                                                                             |
| `spireHealthCheck.enabled`         | Enables the SPIRE Healthchecker indicator                                                                                                                                                                                              | `true`                                                                           |
| `startupProbe.enabled`             | Enable startupProbe on Tornjak frontend container                                                                                                                                                                                      | `true`                                                                           |
| `startupProbe.initialDelaySeconds` | Initial delay seconds for startupProbe                                                                                                                                                                                                 | `5`                                                                              |
| `startupProbe.periodSeconds`       | Period seconds for startupProbe                                                                                                                                                                                                        | `10`                                                                             |
| `startupProbe.timeoutSeconds`      | Timeout seconds for startupProbe                                                                                                                                                                                                       | `5`                                                                              |
| `startupProbe.failureThreshold`    | Failure threshold count for startupProbe                                                                                                                                                                                               | `6`                                                                              |
| `startupProbe.successThreshold`    | Success threshold count for startupProbe                                                                                                                                                                                               | `1`                                                                              |
| `workingDir`                       | Set to override the default path containing the Tornjak frontend within the image                                                                                                                                                      | `""`                                                                             |
| `ingress.enabled`                  | Flag to enable ingress for Tornjak frontend service                                                                                                                                                                                    | `false`                                                                          |
| `ingress.className`                | Ingress class name for Tornjak frontend service                                                                                                                                                                                        | `""`                                                                             |
| `ingress.controllerType`           | Specify what type of ingress controller you're using to add the necessary annotations accordingly. If blank, autodetection is attempted. If other, no annotations will be added. Must be one of [ingress-nginx, openshift, other, ""]. | `""`                                                                             |
| `ingress.annotations`              | Annotations for Tornjak frontend service                                                                                                                                                                                               | `{}`                                                                             |
| `ingress.host`                     | Host name for the ingress. If no '.' in host, trustDomain is automatically appended. The rest of the rules will be autogenerated. For more customizability, use hosts[] instead.                                                       | `tornjak-frontend`                                                               |
| `ingress.tlsSecret`                | Secret that has the certs. If blank will use default certs. Used with host var.                                                                                                                                                        | `""`                                                                             |
| `ingress.hosts`                    | Host paths for ingress object. If emtpy, rules will be built based on the host var.                                                                                                                                                    | `[]`                                                                             |
| `ingress.tls`                      | Secrets containing TLS certs to enable https on ingress. If emtpy, rules will be built based on the host and tlsSecret vars.                                                                                                           | `[]`                                                                             |
| `tests.bash.image.registry`        | The OCI registry to pull the image from                                                                                                                                                                                                | `cgr.dev`                                                                        |
| `tests.bash.image.repository`      | The repository within the registry                                                                                                                                                                                                     | `chainguard/bash`                                                                |
| `tests.bash.image.pullPolicy`      | The image pull policy                                                                                                                                                                                                                  | `IfNotPresent`                                                                   |
| `tests.bash.image.tag`             | Overrides the image tag whose default is the chart appVersion                                                                                                                                                                          | `latest@sha256:5921884408efe50b77796675dc109ad2126f54476fe7403c37d8898a5ceb2e76` |
