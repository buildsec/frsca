# SSF Maven Tekton Pipeline

This is a sample maven tekton pipeline.

> :warning: This pipeline is not intended to be used in production

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys setup-kyverno

# Run a new pipeline.
make example-maven-pipeline

# Wait until it completes.
tkn pr logs --last -f

# to do 
verify jar-file

