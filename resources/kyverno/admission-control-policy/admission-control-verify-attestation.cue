package frsca

frsca: clusterPolicy: "attest-code-review-prod": {
	spec: rules: [{
		verifyImages: [{
			imageReferences: [ #public.repo ]
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
						value:    "tekton.dev/v1beta1/TaskRun"
					}]
				}]
				attestors: [{
					entries: [{
						keys: { publicKeys: #kyvernoKeys.ttlsh }
					}]
				}]
			}]
		}]
		match: resources: namespaces: ["prod"]
	}]
	metadata: annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}

frsca: clusterPolicy: "attest-code-review-tekton": {
	spec: rules: [{
		verifyImages: [{
			imageReferences: [ "gcr.io/tekton-releases/github.com/tektoncd/*" ]
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
						value:    "tekton.dev/v1beta1/TaskRun"
					}]
				}]
				attestors: [{
					entries: [{
						keys: { publicKeys: #kyvernoKeys.tektoncd }
					}]
				}]
			}]
		}]
		match: resources: namespaces: ["tekton-pipelines",
			"tekton-chains"]
	}]
	metadata: annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}
