package kyverno

AttestationClusterPolicy: "attest-code-review": 
	spec: rules: [{
			verifyImages: [{
				attestations: [{
					predicateType: "https://slsa.dev/provenance/v0.1"
					conditions: [{
						all: [{
							key:      "{{ builder.id }}"
							operator: "Equals"
							value:    "tekton-chains"
						}, {
							key:      "{{ recipe.type }}"
							operator: "Equals"
							value:    "https://tekton.dev/attestations/chains@v1"
						}]
					}]
				}]
			}]
		}]

