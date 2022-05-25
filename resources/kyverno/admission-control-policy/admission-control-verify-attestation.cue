package frsca

frsca: clusterPolicy: "attest-code-review": {
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
		}, {
			image: "gcr.io/tekton-releases/github.com/tektoncd/*"
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
			key: "{{ keys.data.tektoncd }}"
		}]
		match: resources: namespaces: ["tekton-pipelines",
			"tekton-chains",
			"prod"]
	}]
	metadata: annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}
