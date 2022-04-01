package ssf

_image: {
	name: "gradle-build-test-ssf"
}

pipeline: "pipeline-gradle-test": spec: {
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
		default: "https://github.com/che-samples/console-java-simple"
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
		name: "run-build-push"
		taskRef: name: "jib-gradle"
		runAfter: [
			"clone",
		]
		workspaces: [{
			name:      "source"
			workspace: "pipeline-pvc"
		}]
		params: [{
			name:  "IMAGE"
			value: "$(params.image)"
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
			"run-build-push",
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
pipelineRun: "pipelinerun-gradle-test-": {
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
		pipelineRef: name: "pipeline-gradle-test"
		timeout: "1h0m0s"
		workspaces: [{
			name: "pipeline-pvc"
		}]
	}
}
