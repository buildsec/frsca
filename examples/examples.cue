package frsca

_IMAGE: name: string

_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)
_GIT_ORG: *"https://gitea-http.gitea:3000/frsca" | string @tag(gitOrg)

frsca: secret: "kube-api-secret": {
	metadata: annotations: "kubernetes.io/service-account.name": "pipeline-account"
	type: "kubernetes.io/service-account-token"
}

frsca: serviceAccount: "pipeline-account": {
}

frsca: clusterRole: "pipeline-role": rules: [{
	apiGroups: [""]
	resources: ["services"]
	verbs: ["get", "create", "update", "patch"]
}, {
	apiGroups: ["apps"]
	resources: ["deployments"]
	verbs: ["get", "create", "update", "patch"]
}]

frsca: clusterRoleBinding: "pipeline-role-binding": {
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
for pr in frsca.pipelineRun {
	frsca: persistentVolumeClaim: "\(pr.metadata.generateName)source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

frsca: pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]

frsca: configMap: "grype-config-map": {
	data: ".grype.yaml": """
		ignore:
		#  - vulnerability: CVE-2022-30065
		#    package:
		#      type: apk

		"""
}

frsca: task: [_]: {
	spec: {
		volumes: [{
			configMap: { name: "ca-certs" }
			name: "ca-certs"
		}]
	}
}

frsca: task: [_]: {
	spec: steps: [...{
		volumeMounts: [{
			mountPath: "/etc/ssl/certs/ca-certificates.crt"
			name: "ca-certs"
			subPath: "ca-certificates.crt"
			readOnly: true
		}]
	}]
}

frsca: task: "grype-vulnerability-scan": {
	spec: {
		params: [{
			description: "image reference"
			name:        "image-ref"
		}, {
			description: "image digest"
			name:        "image-digest"
		}, {
			default:     "0"
			description: "toggles debug mode for the pipeline"
			name:        "pipeline-debug"
		}, {
			name: "fail-on"
			description: "set the return code to 1 if a vulnerability is found with a severity >= the given severity, options=[negligible low medium high critical]"
			default: "medium"
		}, {
			name: "only-fixed"
			description: "ignore matches for vulnerabilities that are not fixed (blank to disable)"
			default: "--only-fixed"
		}]
		stepTemplate: {
			name: "PIPELINE_DEBUG"
			env: [{
				name:  "PIPELINE_DEBUG"
				value: "$(params.pipeline-debug)"
			}]
		}
		steps: [{
			args: [
				"$(params.image-ref)@$(params.image-digest)",
				"-v",
				"$(params.only-fixed)",
				"--fail-on",
				"$(params.fail-on)",
				"--config",
				"/var/grype-config/.grype.yaml"
			]
			image: "anchore/grype:v0.46.0@sha256:6ccf6ac23f90fde7ea202ce2b18d6ad98d3e8992c73455841167afa27a71d93d"
			name:  "grype-scanner"
		}]
		workspaces: [{
			name: "grype-config"
			mountPath: "/var/grype-config"
		}]
	}
}
