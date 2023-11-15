package frsca

frsca: clusterPolicy: "attest-code-review": {
	spec: rules: [{
		verifyImages: [{
			image: #public.repo
			attestations: [{
				type: "https://slsa.dev/provenance/v0.2"
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
            keys: {
              publicKeys: "{{ keys.data.ttlsh }}"
              ctlog: ignoreSCT: true
              rekor: {
                ignoreTlog: true
                url: "https://rekor.sigstore.dev"
              }
            }
          }]
        }]
			}]
			// key: "{{ keys.data.ttlsh }}"
		}, {
			image: "gcr.io/tekton-releases/github.com/tektoncd/*"
			attestations: [{
				type: "https://slsa.dev/provenance/v0.2"
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
