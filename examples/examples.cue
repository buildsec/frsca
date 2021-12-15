package ssf

secret: "kube-api-secret": {
	metadata: annotations: "kubernetes.io/service-account.name": "pipeline-account"
	type: "kubernetes.io/service-account-token"
}

serviceAccount: "pipeline-account": {
}

role: "pipeline-role": rules: [{
	apiGroups: [""]
	resources: ["services"]
	verbs: ["get", "create", "update", "patch"]
}, {
	apiGroups: ["apps"]
	resources: ["deployments"]
	verbs: ["get", "create", "update", "patch"]
}]

roleBinding: "pipeline-role-binding": {
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "pipeline-role"
	}
	subjects: [{
		kind: "ServiceAccount"
		name: "pipeline-account"
	}]
}

// generate a PVC for each pipelineRun
persistentVolumeClaim: {
	for pr in pipelineRun {
		"\(pr.metadata.generateName)source-ws-pvc": spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]
