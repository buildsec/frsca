> **NOTE: See [old README](README.old.md) for out of date info that provides some context while the Secure Software Factory is being rearchitected**

# The Secure Software Factory

## About The Project

The Secure Software Factory is a prototype implementation of the CNCF's [Secure Software Factory Reference Architecture](https://docs.google.com/document/d/1FwyOIDramwCnivuvUxrMmHmCr02ARoA3jw76o1mGfGQ/edit#heading=h.ufqjnib6ho5z) which is based on the CNCF's [Software Supply Chain Best Practices White Paper](https://github.com/cncf/tag-security/blob/main/supply-chain-security/supply-chain-security-paper/CNCF_SSCP_v1.pdf)

The purpose of the project is to provide a set of tools, patterns, and polices in order to build artifacts with increased confidence around its authenticity and integrity, and with traceable provenance.

### Built With

Platform:
* [Kubernetes](http://k8s.io/)
* [Tekton Pipelines](https://tekton.dev/)
* [Tekton Chains](https://github.com/tektoncd/chains)
* [Spire](https://spiffe.io/)
* [Kyverno](https://kyverno.io/)

Tooling:
* [Cosign/Sget](https://github.com/sigstore/cosign)
* [Crane](https://github.com/google/go-containerregistry)
* [Make](https://www.gnu.org/software/make/)

## Getting Started

The following describes how to set up a dev environment with the Secure Software Factory installed.

### Prerequisites

Required:
* Make
* Kubernetes cluster (if not using local Minikube)

Optional Tools:
* Crane

### Installation

TODO: Put key makefile commands


## Usage

See `/examples` for examples of the 

## Roadmap

TODO: Put roadmap


## Contributing

TODO: Create CONTRIBUTING.MD

## License

See LICENSE.MD
