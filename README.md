---
title: "The Secure Software Factory"
description: "AdiDoks is a Zola theme helping you build modern documentation websites, which is a port of the Hugo theme Doks for Zola."
date: 2021-05-01T08:00:00+00:00
updated: 2021-05-01T08:00:00+00:00
draft: false
weight: 10
sort_by: "weight"
template: "docs/page.html"

extra:
  toc: true
  top: false
---

## About The Project

The Secure Software Factory is a prototype implementation of the CNCF's
[Secure Software Factory Reference Architecture](https://docs.google.com/document/d/1FwyOIDramwCnivuvUxrMmHmCr02ARoA3jw76o1mGfGQ)
which is based on the CNCF's [Software Supply Chain Best Practices White Paper](https://github.com/cncf/tag-security/blob/main/supply-chain-security/supply-chain-security-paper/CNCF_SSCP_v1.pdf)

The purpose of the project is to provide a set of tools, patterns, and polices
in order to build artifacts with increased confidence around its authenticity
and integrity, and with traceable provenance.

## Quickstart

To quickly provision a Minikube cluster with [Tekton Pipelines],
[Tekton Chains], and the [buildpacks] pipeline, simply run:

```bash
make quickstart
```

## Going further

The full documentation is available at
<https://thesecuresoftwarefactory.github.io/ssf/>

### Built With

Platform:

* [Kyverno](https://kyverno.io/)
* [Kubernetes](http://k8s.io/)
* [Tekton Pipelines]
* [Tekton Chains]
* [Spire](https://spiffe.io/)

Tooling:

* [Cosign/Sget](https://github.com/sigstore/cosign)
* [Crane](https://github.com/google/go-containerregistry)
* [Cue](https://cuelang.org/)
* [Make](https://www.gnu.org/software/make/)
* [Rekor CLI](https://github.com/sigstore/rekor)

[buildpacks]: https://buildpacks.io/
[Tekton Chains]: https://github.com/tektoncd/chains
[Tekton Pipelines]: https://tekton.dev/
