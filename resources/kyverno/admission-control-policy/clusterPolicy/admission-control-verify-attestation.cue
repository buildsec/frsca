package kube

AttestationClusterPolicy: "attest-code-review": 
	spec: rules: [{
			verifyImages: [{
				attestations: [{
					predicateType: "https://in-toto.io/Provenance/v0.1"
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

