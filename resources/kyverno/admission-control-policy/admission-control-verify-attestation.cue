package kyverno

AttestationClusterPolicy: "attest-code-review": 
	spec: rules: [{
			verifyImages: [{
				attestations: [{
					predicateType: "https://slsa.dev/provenance/v0.2"
					conditions: [{
						all: [{
							key:      "{{ builder.id }}"
							operator: "Equals"
							value:    "https://tekton.dev/chains/v2"
						}, {
							key:      "{{ buildType }}"
							operator: "Equals"
							value:    "https://tekton.dev/attestations/chains@v2"
						}]
					}]
				}]
			}]
		}]

