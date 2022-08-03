# Factory for Repeatable Secure Creation of Artifacts (FRSCA)

## About The Project

Factory for Repeatable Secure Creation of Artifacts (FRSCA) is an [OpenSSF](https://openssf.org/)
[Supply Chain Integrity Working Group Project](https://github.com/ossf/wg-supply-chain-integrity).
The purpose of the project is to provide a set of tools, patterns, and
policies in order to build artifacts with increased confidence around its
authenticity and integrity, and with traceable provenance.

FRSCA is an implementation of the CNCF's
[Secure Software Factory Reference Architecture](https://github.com/cncf/tag-security/blob/main/supply-chain-security/secure-software-factory/Secure_Software_Factory_Whitepaper.pdf)
which is based on the CNCF's
[Software Supply Chain Best Practices White Paper](https://github.com/cncf/tag-security/blob/main/supply-chain-security/supply-chain-security-paper/CNCF_SSCP_v1.pdf).
It is also intended to follow [SLSA](https://slsa.dev) requirements closely
and generate in-toto attesttations for SLSA provenance predicates.

FRSCA is 3 things:

1. A set of interfaces managing CI pipelines while ensuring supply chain
   security and establishing provenance
2. A set of CI/Build tools and systems glued together in order to enable
   #1.
3. A set of secure defaults in order to enable #1 and #2

## Quickstart

To quickly provision a Minikube cluster with [Tekton Pipelines], [Tekton
Chains], and the [buildpacks] pipeline, simply run:

```bash
make quickstart
```

Tearing down the Minikube cluster generated in the quickstart, simply run:

```bash
make teardown
```

## Going further

The full documentation is available at
<https://buildsec.github.io/frsca/>

### Built With

Platform:

- [Kyverno](https://kyverno.io/)
- [Kubernetes](http://k8s.io/)
- [Tekton Pipelines]
- [Tekton Chains]
- [Spire](https://spiffe.io/)

Tooling:

- [Cosign/Sget](https://github.com/sigstore/cosign)
- [Crane](https://github.com/google/go-containerregistry)
- [Cue](https://cuelang.org/)
- [Make](https://www.gnu.org/software/make/)
- [Rekor CLI](https://github.com/sigstore/rekor)

[buildpacks]: https://buildpacks.io/
[tekton chains]: https://github.com/tektoncd/chains
[tekton pipelines]: https://tekton.dev/
