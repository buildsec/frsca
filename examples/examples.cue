package frsca

_IMAGE: name: string

_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)
_GIT_ORG: *"https://gitea-http.gitea:3000/frsca" | string @tag(gitOrg)
_NAMESPACE: *"default" | string @tag(namespace)

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
		namespace: "\(_NAMESPACE)"
		name: "pipeline-account"
	}]
}

// generate a PVC for each pipelineRun
for pr in frsca.pipelineRun {
	frsca: persistentVolumeClaim: "\(pr.metadata.generateName)source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "750Mi"
		}
	}
}

frsca: trigger: [Name=_]: pipelineRun: spec: podTemplate: securityContext: {
  fsGroup: 65532
}

frsca: pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]

// same PVC settings for pipelineRuns within a triggerTemplate
for name, tt in frsca.triggerTemplate {
	frsca: persistentVolumeClaim: "\(name)-source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "750Mi"
		}
	}
}
frsca: triggerTemplate: [Name=_]: spec: resourcetemplates: [{
	spec: workspaces: [{
		name: *"\(Name)-ws" | string
		persistentVolumeClaim: claimName: "\(Name)-source-ws-pvc"
	}, ...]
}]

frsca: configMap: "grype-config-map": {
	data: ".grype.yaml": """
		ignore:
		  # - vulnerability: CVE-2023-2650
		  #   package:
		  #     type: apk

		"""
}

frsca: configMap: "syft-config-map": {
	data: ".syft.yaml": """
	quiet: false
	check-for-app-update: true

	rekor-cataloger:
	  cataloger:
	    enabled: true

	package:
	  search-indexed-archives: true
	  search-unindexed-archives: false

	  cataloger:
	    enabled: true
	    scope: "squashed"

	file-classification:
	  cataloger:
	    enabled: true
	    scope: "squashed"

	file-contents:
	  cataloger:
	    enabled: false
	    scope: "squashed"

	  skip-files-above-size: 1048576

	  globs: ["**/**"]

	file-metadata:
	  cataloger:
	    enabled: true
	    scope: "squashed"

	  digests: ["sha256"]

	secrets:
	  cataloger:
	    enabled: true
	    scope: "all-layers"

	  reveal-values: false
	  skip-files-above-size: 1048576

	registry:
	  insecure-skip-tls-verify: false
	  insecure-use-http: false

	log:
	  structured: false
	  level: "error"
	  file: ""

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
			image: "anchore/grype:v0.84.0@sha256:23b79addd2542dfbe5bd8db89bd9b659382cdf89628d38f86ae0cd7d48cc615c"
			name:  "grype-scanner"
		}]
		workspaces: [{
			name: "grype-config"
			mountPath: "/var/grype-config"
		}]
	}
}
