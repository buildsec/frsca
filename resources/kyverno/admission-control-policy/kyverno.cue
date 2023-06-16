package frsca

#public: {
	repo: string @tag(repo)
	key:  string @tag(key)
}

#kyvernoKeys: {
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

  ttlsh: #public.key
}

frsca: clusterPolicy: [Name=_]: spec: {
	validationFailureAction: "Enforce"
	background:              false
	webhookTimeoutSeconds:   *30 | int
	failurePolicy:           "Fail"
	rules: [{
		name: Name
		match: resources: kinds: [
			"Pod",
		]
	}]
}
