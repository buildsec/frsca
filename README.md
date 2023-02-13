# FRSCA

<p align="center">
<img src="frsca_mascot-color.png" alt="frsca logo" width="200"></img>
</p>

## About The Project

Factory for Repeatable Secure Creation of Artifacts (aka FRSCA pronounced Fresca)
aims to help secure the supply chain by securing build pipelines.

It achieves its goals by being 2 things:

1. A suite of build, pipeline, signing, visibility, identity, and policy tools
   configured to operate securely.
2. A set of build pipeline abstractions and definitions with security guardrails
   ensuring all builds follow supply chain security best practices.

At its core FRSCA uses these projects to achieve its goals:

- [Kubernetes] - For control plane
- [Tekton Pipelines] - For build pipelines
- [Tekton Chains] - For pipeline task observation
- [Sigstore] - For signing software, attestations, SBOMs and other metadata
- [SPIFFE/Spire] - For build workload identities
- [Vault] - For secrets management
- [Helm] and [CUE] - For provisioning kubernetes resources
- [CUE] - For secure pipeline abstractions and definitions

See: [Architecture Docs](https://buildsec.github.io/frsca/docs/getting-started/architecture/)
for more info

FRSCA is also an implementation of the CNCF's
[Secure Software Factory Reference Architecture](https://github.com/cncf/tag-security/blob/main/supply-chain-security/secure-software-factory/Secure_Software_Factory_Whitepaper.pdf)
which is based on the CNCF's
[Software Supply Chain Best Practices White Paper](https://github.com/cncf/tag-security/blob/main/supply-chain-security/supply-chain-security-paper/CNCF_SSCP_v1.pdf).
It is also intended to follow [SLSA](https://slsa.dev) requirements closely
and generate in-toto attesttations for SLSA provenance predicates.

_NOTE_: FRSCA is under very active development. A lot will change, it isn't
production ready yet.

## Quickstart

To quickly provision a Minikube cluster with FRSCA deployed and run an example
pipeline run:

```bash
# Install and setup minikube (run only if need a local k8s)
make setup-minikube
make setup-frsca
```

This will perform the following actions:

1. Install and setup minikube, and supporting cli tools, like `cosign` and `jq`
   if they are not already installed.
1. Install development tooling to simulate a production environment, which includes:
   1. [Cert-manager]
   1. [registry]
   1. [SPIFFE/Spire]
   1. [Vault]
1. Install and setup FRSCA's components which include:
   1. [Tekton Pipelines]
   1. [Tekton Chains]
   1. [Kyverno]
1. Setup a mirror of example repositories and tekton triggers for each mirror.

Once FRSCA has been installed you can follow the various examples under `/examples`.

Tearing down the Minikube cluster generated in the quickstart, simply run:

```bash
make teardown
```

## Going further

The full documentation is available at
<https://buildsec.github.io/frsca/>

## Community

It is a project under the [OpenSSF](https://openssf.org/)
[Supply Chain Integrity Working Group](https://github.com/ossf/wg-supply-chain-integrity).

Community meetings every other Wednesday at 10AM Eastern - See OpenSSF
[community calendar](https://calendar.google.com/calendar/u/0?cid=czYzdm9lZmhwNWk5cGZsdGI1cTY3bmdwZXNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ)
for more info.

Slack channel: #frsca on [OpenSSF slack](https://slack.openssf.org/)

### Built With

Platform:

- [Kyverno]
- [Kubernetes]
- [Tekton Pipelines]
- [Tekton Chains]
- [SPIFFE/Spire]
- [Vault]

Tooling:

- [Cosign/Sget]
- [Crane]
- [Cue]
- [Make]
- [Rekor CLI]
- [Helm]

[tekton chains]: https://github.com/tektoncd/chains
[tekton pipelines]: https://tekton.dev/
[kyverno]: https://kyverno.io/
[kubernetes]: https://k8s.io/
[spiffe/spire]: https://spiffe.io/
[cosign/sget]: https://github.com/sigstore/cosign
[crane]: https://github.com/google/go-containerregistry
[cue]: https://cuelang.org/
[make]: https://www.gnu.org/software/make/
[rekor cli]: https://github.com/sigstore/rekor
[vault]: https://www.vaultproject.io/
[helm]: https://helm.sh/
[sigstore]: https://www.sigstore.dev/
[cert-manager]: https://cert-manager.io/
[registry]: https://hub.docker.com/_/registry
