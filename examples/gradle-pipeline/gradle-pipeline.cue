package frsca

_IMAGE: name: "example-gradle"

frsca: pipeline: "example-gradle": spec: {
	workspaces: [{
		name:     "pipeline-pvc"
		optional: false
	}]
	params: [{
		name:        "image"
		description: "reference of the image to build"
	}, {
		name:        "SOURCE_URL"
		type:        "string"
		description: "git repo"
	}, {
		name:        "SOURCE_SUBPATH"
		type:        "string"
		default:     "."
		description: "path within git repo"
	}, {
		name:        "SOURCE_REFERENCE"
		type:        "string"
		description: "git commit branch, or tag"
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
		default: "\(_GIT_ORG)/example-gradle"
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
			value: "$(params.SOURCE_URL)"
		}, {
			name:  "revision"
			value: "$(params.SOURCE_REFERENCE)"
		}, {
			name:  "subdirectory"
			value: "$(params.SOURCE_SUBPATH)"
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

frsca: trigger: "example-gradle": {
	pipelineRun: spec: {
		params: [{
			name:  "image"
			value: "\(_APP_IMAGE):$(tt.params.gitrevision)"
		}, {
			name:  "SOURCE_URL"
			value: "https://gitea-http.gitea:3000/frsca/example-gradle"
		}, {
			name:  "SOURCE_SUBPATH"
			value: "."
		}, {
			name: "SOURCE_REFERENCE"
			value: "$(tt.params.gitrevision)"
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
		pipelineRef: name: "example-gradle"
		timeout: "1h0m0s"
		workspaces: [{
			name: "pipeline-pvc"
		}]
	}
}
