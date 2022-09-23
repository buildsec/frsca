package frsca

_IMAGE: name: "example-buildpacks"

_CACHE_IMAGE: *"\(_APP_IMAGE)-cache" | string @tag(cacheImage)

frsca: trigger: "example-buildpacks": {
	pipelineRun: spec: {
		pipelineRef: name: "buildpacks"
		params: [{
			name:  "BUILDER_IMAGE"
			value: "docker.io/cnbs/sample-builder:bionic@sha256:6c03dd604503b59820fd15adbc65c0a077a47e31d404a3dcad190f3179e920b5"
		}, {
			name:  "TRUST_BUILDER"
			value: "true"
		}, {
			name:  "APP_IMAGE"
			value: "\(_APP_IMAGE):$(tt.params.gitrevision)"
		}, {
			name:  "imageUrl"
			value: _APP_IMAGE
		}, {
			name:  "imageTag"
			value: "$(tt.params.gitrevision)"
		}, {
			name:  "SOURCE_URL"
			value: "\(_GIT_ORG)/example-buildpacks"
		}, {
			name:  "SOURCE_SUBPATH"
			value: "apps/ruby-bundler"
		}, {
			name: "SOURCE_REFERENCE"
			value: "$(tt.params.gitrevision)"
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
}
