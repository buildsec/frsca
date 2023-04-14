package frsca

_REPOSITORY: *"ttl.sh" | string @tag(repository)
_KEY: string @tag(key)

frsca: clusterImagePolicy: "frsca-signature": spec: {
  images: [{
    glob: "\(_REPOSITORY)/**"
  }]
  authorities: [{
    name: "frsca-key"
    key: data: _KEY
  }]
}

frsca: clusterImagePolicy: "frsca-attestation": spec: {
  images: [{
    glob: "\(_REPOSITORY)/**"
  }]
  authorities: [{
    name: "frsca-attestation"
    key: data: _KEY
    attestations: [{
      name: "frsca-attestation"
      predicateType: "slsaprovenance"
      policy: {
        type: "cue"
        data: """
          payloadType: "application/vnd.in-toto+json"
          predicateType: "https://slsa.dev/provenance/v0.2"
          predicate: {
            builder: {
              id: "https://tekton.dev/chains/v2"
            }
            buildType: "tekton.dev/v1beta1/TaskRun"
          }
        """
      }
    }]
  }]
}

// This currently doesn't work, likely because of how the SBOM is pushed (cosign
// attach sbom) and signed (chains) rather than packaged as an attestation
frsca: clusterImagePolicy: "frsca-spdx-sbom": spec: {
  mode: "warn"
  images: [{
    glob: "\(_REPOSITORY)/**"
  }]
  authorities: [{
    name: "frsca-spdx"
    key: data: _KEY
    attestations: [{
      name: "frsca-spdx"
      predicateType: "spdxjson"
      policy: {
        type: "cue"
        data: """
          predicateType: "https://spdx.dev/Document"
        """
      }
    }]
  }]
}

