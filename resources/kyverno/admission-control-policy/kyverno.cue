package frsca

#keys: {
	name:      "keys"
	namespace: "default"
}

#public: {
	repo: string @tag(repo)
	key:  string @tag(key)
}

frsca: clusterPolicy: [Name=_]: spec: {
	validationFailureAction: *"Enforce" | string
	background:              false
	webhookTimeoutSeconds:   *30 | int
	failurePolicy:           "Fail"
	rules: [{
		name: Name
		match: resources: kinds: [
			"Pod",
		]
		context: [{
			name: #keys.name
			configMap: {
				name:      #keys.name
				namespace: #keys.namespace
			}
		}]
	}]
}
