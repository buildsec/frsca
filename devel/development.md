# Development Guide

This document is intended to help you get started on the Secure Software Factory.

Please submit an [issue] on Github if you
* Notice something this document doesn't cover
* Find development specs lurking elsewhere in this repo

# Kubernetes setup

The main requirement for developing on SSF is that you have a running kubernetes environment.
There is an *unsupported* script which will initialize a minikube environment `00-kubernetes-minikube-setup.sh`

# Requirements

* [Kubernetes](https://github.com/kubernetes/kubernetes) ( [minikube](https://github.com/kubernetes/minikube) works great for local development )
* [kubectl](https://github.com/kubernetes/kubectl)
* [helm](https://github.com/helm/helm)
* [tekcon cli](https://github.com/tektoncd/cli)
