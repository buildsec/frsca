key: {
    public: string @tag(key)
}

template: {
    apiVersion:  "v1"
    kind:   "ConfigMap"
    metadata: name: "keys"
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

	ghcrio: key.public

	ttlsh: key.public
	}
}
