package ssf

ssf: clusterPolicy: "attest-code-review": {
	spec: rules: [{
		verifyImages: [{
			image: #public.repo
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
			key: "{{ keys.data.ttlsh }}"
		}]
		match: resources: namespaces: ["prod"]
	}]
	metadata: annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}
