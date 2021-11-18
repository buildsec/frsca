package kube

#keys: {
    name:      "keys"
    namespace: "default"
}

#public: {
    repo: string @tag(repo)
    key: string @tag(key)
}

_spec: {
	_name: string
    _annotations: {}

    apiVersion: "kyverno.io/v1"
    kind:       "ClusterPolicy"
    metadata: {
        annotations: _annotations
        name: _name
    }
    spec: {
		validationFailureAction: "enforce"
		background:              false
		webhookTimeoutSeconds:   *30 | int
		failurePolicy:           "Fail"
        rules: [{
            name: _name
			match: resources: {
				kinds: [
					"Pod",
				]
				namespaces: [
					"default",
				]
			}
            context: [{
				name: #keys.name
				configMap: {
					name:      #keys.name
					namespace: #keys.namespace
				}
			}]
        }]
    }
}

AttestationClusterPolicy: [ID=_]: _spec & {
    _name: ID
    _annotations: "pod-policies.kyverno.io/autogen-controllers": "none"
    spec: rules: [{ verifyImages: 
            [{ image: #public.repo
				key: "{{ keys.data.ttlsh }}"
            }] 
        }]
}

ImageClusterPolicy: [ID=_]: _spec & {
    _name: ID
    _annotations: {	
        "policies.kyverno.io/title":       "Verify Image"
		"policies.kyverno.io/category":    "Sample"
		"policies.kyverno.io/severity":    "medium"
		"policies.kyverno.io/subject":     "Pod"
		"policies.kyverno.io/minversion":  "1.4.2"
		"policies.kyverno.io/description": "Using the Cosign project, OCI images may be signed to ensure supply chain security is maintained. Those signatures can be verified before pulling into a cluster. This policy checks the signature of an image repo called ghcr.io/kyverno/test-verify-image to ensure it has been signed by verifying its signature against the provided public key. This policy serves as an illustration for how to configure a similar rule and will require replacing with your image(s) and keys."
        }
    spec: rules: [{  verifyImages: [{}, {}, {}, {}] }]
           
}

configMap: [ID=_]: {
    apiVersion: "v1"
    kind:       "ConfigMap"
    metadata: {
        name: #keys.name
        namespace: #keys.namespace
    }
    data: {
    	tektoncd: """
			-----BEGIN PUBLIC KEY-----
			MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEnLNw3RYx9xQjXbUEw8vonX3U4+tB
			kPnJq+zt386SCoG0ewIH5MB8+GjIDGArUULSDfjfM31Eae/71kavAUI0OA==
			-----END PUBLIC KEY-----
			"""

		projectsigstore: """
			-----BEGIN PUBLIC KEY-----
			MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEhyQCx0E9wQWSFI9ULGwy3BuRklnt
			IqozONbbdbqz11hlRJy9c7SG+hdcFl9jE9uE/dwtuwU2MqU9T/cN0YkWww==
			-----END PUBLIC KEY-----
			"""

        ghcrio: #public.key

	    ttlsh: #public.key
    }
}