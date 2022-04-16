# OCI Demo

## Goal

The goal of this demo is to show how to:

1. Build a Docker image and sign it
2. Attach the SBOM of the project to the OCI repository
3. Verify that the image and the SBOM are correctly signed

## Requirements

This demo assumes the following tools are installed:

- `rust` ([official](https://www.rust-lang.org/tools/install))
- `docker` ([official](https://docs.docker.com/engine/install/))
- `cosign` ([github](https://github.com/sigstore/cosign))
- `sget` ([github](https://github.com/sigstore/cosign/blob/main/README.md#sget))
- `crane`
  ([github](https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md))
- `cyclonedx` for rust
  ([github](https://github.com/CycloneDX/cyclonedx-rust-cargo))

## Workflow

```bash
# Generate a key pair if needed.
make cosign-keys

# Build the Docker image and upload it to the registry.
make docker-build docker-push

# Sign the image.
make cosign-sign

# Generate the SBOM and attach it to the OCI repository.
make cosign-attach

# Show the artifacts attached to the OCI repository.
make crane-ls

# Verify the image signature.
make cosign-verify

# Retrieve the SBOM and verify it was signed correctly.
make cosign-retrieve-sbom
```
