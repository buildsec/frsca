# How FRSCA pipelines are meeting SLSA levels 1-3

## Reminder on SLSA levels

SLSA levels at a high level are as follows (table from [https://slsa.dev/spec/v0.1/levels#summary-of-levels](https://slsa.dev/spec/v0.1/levels#summary-of-levels)):

| **Level** | **Description**                        | **Example**                                           |
| --------- | -------------------------------------- | ----------------------------------------------------- |
| 1         | Documentation of the build process     | Unsigned provenance                                   |
| 2         | Tamper resistance of the build service | Hosted source/build, signed provenance                |
| 3         | Extra resistance to specific threats   | Security controls on host, non-falsifiable provenance |
| 4         | Highest levels of confidence and trust | Two-party review + hermetic builds                    |

The full requirements table can be found here:

[Requirements](https://slsa.dev/spec/v0.1/requirements#summary-table)

## sample-pipeline

```other
frsca/examples/sample-pipeline
```

# SLSA 1 Requirements

1. Build - [Scripted build](https://slsa.dev/spec/v0.1/requirements#scripted-build) **✅**
2. Provenance - [Available](https://slsa.dev/spec/v0.1/requirements#available) ✅

`sample-pipeline` meets both of these requirements.  The build is scripted, which is evident in following individual steps from the `Makefile` down through the various shell scripts which setup the FRSCA environment and trigger the build via Tekton Pipelines.

Because we're using Tekton Chains in conjunction with Tekton Pipelines, provenance is created and available, satisfying the last requirement of SLSA 1.

To prove, once the pipeline completes:

```other
> crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"            
                                                                                                                                                                                            
0066d00de427d12b9a14e56f02f302031d9c40f3
sha256-e6dc8ea1ff666893462b64d997d496af8e69e905f2eeaf2ab7ec1fd565921d46.att
sha256-e6dc8ea1ff666893462b64d997d496af8e69e905f2eeaf2ab7ec1fd565921d46.sbom
sha256-e6dc8ea1ff666893462b64d997d496af8e69e905f2eeaf2ab7ec1fd565921d46.sig
```

# SLSA 2 Requirements

1. Source - [Version controlled](https://slsa.dev/spec/v0.1/requirements#version-controlled) ✅*
2. Build - [Build service](https://slsa.dev/spec/v0.1/requirements#build-service) ✅
3. Provenance - [Authenticated](https://slsa.dev/spec/v0.1/requirements#authenticated) ✅
4. Provenance - [Service generated](https://slsa.dev/spec/v0.1/requirements#service-generated) ✅

SLSA 2 introduces four new requirements in addition to the requirements of SLSA 1, all of which are being met by this sample pipeline.

1. In this example, the original source code is version controlled.

   * It is up to the consumer of FRSCA to ensure they are following proper source requirements.

1. The build is being performed within a TaskRun in a Tekton Pipelines PipelineRun.
2. Provenance is not ony available, but it is authenticated.

```other
> cosign verify --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"                                                                                                                                                                                        

Verification for ttl.sh/6b1d3c200c0fe4005da60bddc63873ef/example-sample:919eef3dd425318e9a65cb79b00ee323210ef070 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key

> cosign verify-attestation --type slsaprovenance --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"                                                                                                                                                      

Verification for ttl.sh/6b1d3c200c0fe4005da60bddc63873ef/example-sample:919eef3dd425318e9a65cb79b00ee323210ef070 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key
```

4. Tekton Chains observes Tekton Pipelines TaskRuns outputting an OCI image and generates provenance directly from the data it obtains, so we're satisfying service generated requirements.

# SLSA 3 Requirements

1. Source - [Verified history](https://slsa.dev/spec/v0.1/requirements#verified-history) ✅*
2. Source - [Retained indefinitely](https://slsa.dev/spec/v0.1/requirements#retained-indefinitely) (18 mo. for SLSA 3) ✅*
3. Build - [Build as code](https://slsa.dev/spec/v0.1/requirements#build-as-code) ✅
4. Build - [Ephemeral environment](https://slsa.dev/spec/v0.1/requirements#ephemeral-environment) ✅
5. Build - [Isolated](https://slsa.dev/spec/v0.1/requirements#isolated) ✅
6. Provenance - [Non-falsifiable](https://slsa.dev/spec/v0.1/requirements#non-falsifiable) (in progress)

Requirements 1 & 2 are asterisked due to the lack of control the FRSCA platform has around the source code management platforms leveraged by the end user.

3. Every step in the end-to-end build process via Tekton is described as code.
4. Tasks are executed within a Pod that is specifically tied to that particular TaskRun, and when the TaskRun is complete, the Pod is not reused.

```other
example-sample-pipeline-7mvgr-clone-repo-pod             0/1     Completed   0          44h
example-sample-pipeline-7mvgr-build-and-push-image-pod   0/2     Completed   0          44h
example-sample-pipeline-7mvgr-vulnerability-scan-pod     0/1     Completed   0          44h
example-sample-pipeline-7mvgr-generate-bom-pod           0/2     Completed   0          44h
example-sample-pipeline-7mvgr-deploy-to-cluster-pod      0/2     Completed   0          44h
```

5. In the same vein, the build process within a PipelineRun is completely isolated from other PipelineRuns, and TaskRuns within a PipelineRun also do not share data between each other unless explicitly defined.
6. Non-falsifiable provenance support by means of SPIFFE/SPIRE is currently in development and awaiting approval.  See [TEP-89](https://github.com/tektoncd/community/blob/main/teps/0089-nonfalsifiable-provenance-support.md) for more information.

