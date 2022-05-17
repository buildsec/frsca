# FRSCA Maven Tekton Pipeline

This is a sample maven tekton pipeline.

> :warning: This pipeline is not intended to be used in production

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-certs setup-tekton-chains setup-spire setup-vault

# Run a new pipeline.
make example-maven

# Wait until it completes.
tkn pr logs --last -f

# to do 
verify jar-file
```

## References

- <https://github.com/redhat-scholars/tekton-tutorial>
- <https://redhat-scholars.github.io/tekton-tutorial/tekton-tutorial/>
- <https://github.com/redhat-scholars/tekton-tutorial-greeter>
