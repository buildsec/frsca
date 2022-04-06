package ssf

_IMAGE: name: string

_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)

ssf: secret: "kube-api-secret": {
	metadata: annotations: "kubernetes.io/service-account.name": "pipeline-account"
	type: "kubernetes.io/service-account-token"
}

ssf: serviceAccount: "pipeline-account": {
}

ssf: clusterRole: "pipeline-role": rules: [{
	apiGroups: [""]
	resources: ["services"]
	verbs: ["get", "create", "update", "patch"]
}, {
	apiGroups: ["apps"]
	resources: ["deployments"]
	verbs: ["get", "create", "update", "patch"]
}]

ssf: clusterRoleBinding: "pipeline-role-binding": {
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "pipeline-role"
	}
	subjects: [{
		kind: "ServiceAccount"
		namespace: "default"
		name: "pipeline-account"
	}]
}

// generate a PVC for each pipelineRun
for pr in ssf.pipelineRun {
	ssf: persistentVolumeClaim: "\(pr.metadata.generateName)source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

ssf: pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]
