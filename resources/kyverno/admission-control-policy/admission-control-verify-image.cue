package ssf

ssf: clusterPolicy: "verify-image": {
	spec: rules: [{
		verifyImages: [{
			image: "gcr.io/tekton-releases/github.com/tektoncd/*"
			key:   "{{ keys.data.tektoncd }}"
		}, {
			image: "gcr.io/projectsigstore/*"
			key:   "{{ keys.data.projectsigstore }}"
		}, {
			image: "ttl.sh/*"
			key:   "{{ keys.data.ttlsh }}"
		}, {
			image:   "ghcr.io/google/ko"
			subject: "https://github.com/google/ko/*"
			issuer:  "https://token.actions.githubusercontent.com"
			roots: """
				-----BEGIN CERTIFICATE-----
				MIIB9zCCAXygAwIBAgIUALZNAPFdxHPwjeDloDwyYChAO/4wCgYIKoZIzj0EAwMw
				KjEVMBMGA1UEChMMc2lnc3RvcmUuZGV2MREwDwYDVQQDEwhzaWdzdG9yZTAeFw0y
				MTEwMDcxMzU2NTlaFw0zMTEwMDUxMzU2NThaMCoxFTATBgNVBAoTDHNpZ3N0b3Jl
				LmRldjERMA8GA1UEAxMIc2lnc3RvcmUwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAAT7
				XeFT4rb3PQGwS4IajtLk3/OlnpgangaBclYpsYBr5i+4ynB07ceb3LP0OIOZdxex
				X69c5iVuyJRQ+Hz05yi+UF3uBWAlHpiS5sh0+H2GHE7SXrk1EC5m1Tr19L9gg92j
				YzBhMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRY
				wB5fkUWlZql6zJChkyLQKsXF+jAfBgNVHSMEGDAWgBRYwB5fkUWlZql6zJChkyLQ
				KsXF+jAKBggqhkjOPQQDAwNpADBmAjEAj1nHeXZp+13NWBNa+EDsDP8G1WWg1tCM
				WP/WHPqpaVo0jhsweNFZgSs0eE7wYI4qAjEA2WB9ot98sIkoF3vZYdd3/VtWB5b9
				TNMea7Ix/stJ5TfcLLeABLE4BNJOsQ4vnBHJ
				-----END CERTIFICATE-----
				"""
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
