package kyverno

ImageClusterPolicy: "verify-image": spec: rules: [{
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
}]
