_REPOSITORY: string @tag(repository)

apiVersion: "tekton.dev/v1beta1"
kind:       "PipelineRun"
metadata: {
	generateName: "cache-image-pipelinerun-"
	labels: "app.kubernetes.io/description": "PipelineRun"
}
spec: {
	pipelineRef: name: "buildpacks"
	params: [{
		name:  "BUILDER_IMAGE"
		value: "docker.io/cnbs/sample-builder:bionic@sha256:6c03dd604503b59820fd15adbc65c0a077a47e31d404a3dcad190f3179e920b5"
	}, {
		name:  "TRUST_BUILDER"
		value: "true"
	}, {
		name:  "APP_IMAGE"
		value: "\(_REPOSITORY)/slsapoc"
	}, {
		name:  "SOURCE_URL"
		value: "https://github.com/buildpacks/samples"
	}, {
		name:  "SOURCE_SUBPATH"
		value: "apps/ruby-bundler"
	}, {
		name:  "CACHE_IMAGE"
		value: "\(_REPOSITORY)/slsapoc-cache"
	}]
	workspaces: [{
		name:    "source-ws"
		subPath: "source"
		persistentVolumeClaim: claimName: "cache-image-ws-pvc"
	}, {
		// NOTE: Pipeline hangs if optional cache workspace is missing so we provide an empty directory
		name: "cache-ws"
		emptyDir: {}
	}]
}
