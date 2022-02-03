package ssf

_image: {
	name: "slsa"
}

_CACHE_IMAGE: *"\(_APP_IMAGE)-cache" | string @tag(cacheImage)

pipelineRun: "cache-image-pipelinerun-": spec: {
	pipelineRef: name: "buildpacks"
	params: [{
		name:  "BUILDER_IMAGE"
		value: "docker.io/cnbs/sample-builder:bionic@sha256:6c03dd604503b59820fd15adbc65c0a077a47e31d404a3dcad190f3179e920b5"
	}, {
		name:  "TRUST_BUILDER"
		value: "true"
	}, {
		name:  "APP_IMAGE"
		value: _APP_IMAGE
	}, {
		name:  "SOURCE_URL"
		value: "https://github.com/buildpacks/samples"
	}, {
		name:  "SOURCE_SUBPATH"
		value: "apps/ruby-bundler"
	}, {
		name:  "CACHE_IMAGE"
		value: _CACHE_IMAGE
	}]
	workspaces: [{
		name:    "source-ws"
		subPath: "source"
	}, {
		// NOTE: Pipeline hangs if optional cache workspace is missing so we provide an empty directory
		name: "cache-ws"
		emptyDir: {}
	}]
}
