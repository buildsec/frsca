# Cosign Pipeline

This pipeline depicts how to build a Golang project from source, package it in a
container using `ko` and verify that the processed was not tampered with.

## How to run this demo

Execute the following commands from the root of this repository:

```bash
# Only if a cluster is needed.
make setup-minikube

# Use the built-in registry, or replace with your own local registry
export REGISTRY=registry.registry

# Setup FRSCA environment
make setup-frsca

# if using the built-in registry, run the proxy in the background or another window
make registry-proxy >/dev/null &

# Run a new pipeline.
make example-cosign
# Or re-run the last one.
# tkn pipeline start ko -L

# Wait until it completes.
tkn pr logs --last -f

# Ensure it has been signed.
TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] as $k | {"k": $k, "v": .[$k]} | select(.v.status.taskResults[]?.name | match("IMAGE_URL$")) | .k')
tkn tr describe "${TASK_RUN}" -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output "true"

# Export URL of the image created from the pipelinerun as IMAGE_URL.
IMAGE_URL=$(tkn pr describe --last -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')
if [ "${REGISTRY}" = "registry.registry" ]; then
  : "${REGISTRY_PORT:=5000}"
  IMAGE_URL="$(echo "${IMAGE_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:'${REGISTRY_PORT}'#')"
fi

# Double check that the SBOM, the attestation and the signature were uploaded to the OCI.
crane ls "$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"
# Should output something similar to this:
#   latest
#   sha256-7e8eb5bef5ad530a910926df57d73a373ac2860d539eb363c51e0b3479480c88.att
#   sha256-7e8eb5bef5ad530a910926df57d73a373ac2860d539eb363c51e0b3479480c88.sbom
#   sha256-7e8eb5bef5ad530a910926df57d73a373ac2860d539eb363c51e0b3479480c88.sig

# if the registry proxy is running in the background, it can be stopped when you finish the demo
kill %?registry-proxy
```

## Verifications

### SBOM

Based on the [CycloneDX documentation](https://cyclonedx.org/use-cases/),
there is a lot you can do with it! Let's see in practice how it is.

Start by cloning the [cosign] repository:

```bash
git clone https://github.com/sigstore/cosign.git
cd cosign
```

And step into it.

#### SPDX

`ko` generates an SBOM aside the OCI image. The default format is SPDX, but it
can be changed to CycloneDX.

Retrieve the SBOM with [cosign]:

```bash
cosign download sbom "${IMAGE_URL}"
```

By default it looks like the SBOM does not perform any license detection.

#### CycloneDX

Generate the SBOM with [cyclonedx-gomod] from the [cosign] source repository:

```bash
  cyclonedx-gomod app \
  -output cyclonedx.sbom \
  -licenses \
  -json \
  -main cmd/cosign
```

##### Inventory

##### Known vulnerabilities

* CPE
  * Online search: <https://nvd.nist.gov/products/cpe/search>
* SWID
  * Java CLI tool: <https://csrc.nist.gov/Projects/Software-Identification-SWID/resources>
* Use Package URL ([PURL](<https://github.com/package-url/purl-spec>)) standard
  to identify and locate dependencies.

##### Integrity verification

* No tool to verify the integrity automatically

##### Authenticity

* No tool to validate signature(s). There should be something similar to what
[cosign] does with the DSS envelopes.

##### Package evaluation

* Uses PURL
* Seems interesting but I am not so sure what to do with it

##### License compliance

List the licenses found in the SBOM:

```bash
jq '.components[].evidence.licenses[]?.license.id' cyclonedx.sbom |sort -u
```

* No licenses are simply shown as a blank line.
* No tool to validate the licenses against <https://spdx.org/licenses/>.
* No tool to validate licenses against company policy.
* If a dependency has no license, it appears only on the CLI tool output.

##### Assembly

* Not so sure what to do with this one.
* Seems to be CycloneDX specific.

##### Dependency graph

* Not a new feature, it can also be done using the lock files.
* Not sure how useful that is.

##### Provenance

* This would be good to trust software suppliers
* If you trust a supplier, do you trust *ALL* that it supplies?

##### Pedigree

##### Service definition

##### Properties / name-value store

##### Packaging and distribution

* This sounds great!
* It seems to be what we would use instead of a "build tool SBOM".

##### Composition completeness

##### OpenChain conformance

##### Vulnerability remediation

##### Vulnerability exploitability

##### Security advisories

##### External references

### Verify the image the atteastation

Ensures you are running an image from a trusted source, and built from a trusted
process that can be reviewed and audited.

```bash
# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --type slsaprovenance --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
```

[cosign]: https://github.com/sigstore/cosign
[cyclonedx-gomod]: https://github.com/CycloneDX/cyclonedx-gomod
