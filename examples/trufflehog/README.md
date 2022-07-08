# Trufflehog

## How to run this demo

Execute the following commands from the root of this repository:

**Please note:** This demo requires tetragon to be running in the kubernetes env.
Currently the requirement is the base kernel should support BTF or the BTF file 
should be placed where Tetragon can read it. This will not work on MacOS natively.

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup FRSCA environment
make setup-frsca

# Run a new pipeline.
make example-trufflehog

# Wait until it completes.
tkn pr logs --last -f
```

The purpose of this pipeline is to demostrate that tetragon will kill the `/usr/bin/trufflehog`
from running and find leaked credentials that might be stored in the git repo. Similar conditions can be set up to block access to
`/etc/shadow` file for example.

## Links

- TruffleHog: <https://github.com/trufflesecurity/trufflehog>