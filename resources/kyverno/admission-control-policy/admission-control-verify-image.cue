package ssf

clusterPolicy: "verify-image": {
	spec: rules: [{
		verifyImages: [{
			image: "gcr.io/tekton-releases/github.com/tektoncd/*"
			key:   "{{ keys.data.tektoncd }}"
		}, {
			image: "gcr.io/projectsigstore/*"
			key:   "{{ keys.data.projectsigstore }}"
		}, {
			// Change below to your public keys if you built the images yourself.
			image: "ghcr.io/*"
			key:   "{{ keys.data.ghcrio }}"
		}, {
			image: "ttl.sh/*"
			key:   "{{ keys.data.ttlsh }}"
		}]
		match: resources: namespaces: ["default"]
	}]
	metadata: annotations: {
		"policies.kyverno.io/title":       "Verify Image"
		"policies.kyverno.io/category":    "Sample"
		"policies.kyverno.io/severity":    "medium"
		"policies.kyverno.io/subject":     "Pod"
		"policies.kyverno.io/minversion":  "1.4.2"
		"policies.kyverno.io/description": "Using the Cosign project, OCI images may be signed to ensure supply chain security is maintained. Those signatures can be verified before pulling into a cluster. This policy checks the signature of an image repo called ghcr.io/kyverno/test-verify-image to ensure it has been signed by verifying its signature against the provided public key. This policy serves as an illustration for how to configure a similar rule and will require replacing with your image(s) and keys."
	}
}
