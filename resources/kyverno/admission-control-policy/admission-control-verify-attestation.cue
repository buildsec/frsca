package ssf

clusterPolicy: "attest-code-review": {
	spec: rules: [{
		verifyImages: [{
			image: #public.repo
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
			key: "{{ keys.data.ttlsh }}"
		}]
		match: resources: namespaces: ["prod"]
	}]
	metadata: annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}
