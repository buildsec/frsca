package frsca

_IMAGE: name: "go-build-test-frsca"

frsca: pipeline: "pipeline-go-test": spec: {
	workspaces: [{
		name:     "pipeline-pvc"
		optional: false
	}]
	params: [{
		name:        "image"
		description: "reference of the image to build"
	}, {
		name:        "ARGS"
		type:        "array"
		description: "The Arguments to be passed to Trivy command for file system scan"
	}, {
		name:        "IMAGEARGS"
		type:        "array"
		description: "The Arguments to be passed to Trivy command for image scan"
	}, {
		name:    "package"
		type:    "string"
		default: "https://github.com/chmouel/go-rest-api-test"
	}]
	results: [{
		name:        "commit-sha"
		description: "the sha of the commit that was used"
		value:       "$(tasks.clone.results.commit)"
	}]
	description: "Test Pipeline for Trivy"
	tasks: [{
		name: "clone"
		taskRef: name: "git-clone"
		workspaces: [{
			name:      "output"
			workspace: "pipeline-pvc"
		}]
		params: [{
			name:  "url"
			value: "$(params.package)"
		}, {
			name:  "subdirectory"
			value: ""
		}, {
			name:  "deleteExisting"
			value: "true"
		}]
	}, {
		name: "run-test"
		taskRef: name: "golang-test"
		runAfter: [
			"clone",
		]
		workspaces: [{
			name:      "source"
			workspace: "pipeline-pvc"
		}]
		params: [{
			name:  "package"
			value: "$(params.package)"
		}, {
			name:  "GOARCH"
			value: ""
		}]
	}, {
		name: "run-build"
		taskRef: name: "golang-build"
		runAfter: [
			"clone",
		]
		workspaces: [{
			name:      "source"
			workspace: "pipeline-pvc"
		}]
		params: [{
			name:  "package"
			value: "$(params.package)"
		}, {
			name:  "packages"
			value: "./"
		}]
	}, {
		name: "kaniko"
		taskRef: name: "kaniko"
		runAfter: [
			"trivy-scan-local-fs",
		]
		workspaces: [{
			name:      "source"
			workspace: "pipeline-pvc"
		}]
		params: [{
			name:  "IMAGE"
			value: "$(params.image)"
		}, {
			name: "EXTRA_ARGS"
			value: [
				"--skip-tls-verify",
			]
		}]
	}, {
		name: "trivy-scan-local-fs"
		taskRef: {
			name: "trivy-scanner"
			kind: "Task"
		}
		runAfter: [
			"clone",
		]
		params: [{
			name: "ARGS"
			value: ["$(params.ARGS[*])"]
		}, {
			name:  "IMAGE_PATH"
			value: "."
		}]
		workspaces: [{
			name:      "manifest-dir"
			workspace: "pipeline-pvc"
		}]
	}, {
		name: "trivy-scan-image"
		taskRef: {
			name: "trivy-scanner"
			kind: "Task"
		}
		runAfter: [
			"kaniko",
		]
		params: [{
			name: "ARGS"
			value: ["$(params.IMAGEARGS[*])"]
		}, {
			name:  "IMAGE_PATH"
			value: "$(params.image)"
		}]
		workspaces: [{
			name:      "manifest-dir"
			workspace: "pipeline-pvc"
		}]
	}]
}
frsca: pipelineRun: "pipelinerun-go-test-": {
	spec: {
		params: [{
			name:  "image"
			value: _APP_IMAGE
		}, {
			name: "ARGS"
			value: [
				"fs",
				"--exit-code",
				"1",
			]
		}, {
			name: "IMAGEARGS"
			value: [
				"image",
				"--exit-code",
				"0",
			]
		}]
		pipelineRef: name: "pipeline-go-test"
		timeout: "1h0m0s"
		workspaces: [{
			name: "pipeline-pvc"
		}]
	}
}
