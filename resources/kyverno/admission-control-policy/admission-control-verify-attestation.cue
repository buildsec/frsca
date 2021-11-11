package policy

apiVersion: "kyverno.io/v1"
kind:       "ClusterPolicy"
metadata: {
	name: "attest-code-review"
	annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
}
spec: {
	validationFailureAction: "enforce"
	background:              false
	webhookTimeoutSeconds:   30
	failurePolicy:           "Fail"
	rules: [{
		name: "attest"
		match: resources: kinds: [
			"Pod",
		]
		verifyImages: [{
			image: "registry.io/org/*"
			key: key.public

			attestations: [{
				predicateType: "https://tekton.dev/chains/provenance"
				conditions: [{
					all: [{
						key:      "{{ repo.uri }}"
						operator: "Equals"
						value:    "https://git-repo.com/org/app"
					}, {
						key:      "{{ repo.branch }}"
						operator: "Equals"
						value:    "main"
					}, {
						key:      "{{ reviewers }}"
						operator: "In"
						value: ["ana@example.com", "bob@example.com"]
					}]
				}]
			}]
		}]
	}]
}
