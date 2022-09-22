package frsca

_IMAGE: name: "example-ibm"

frsca: pipeline: "example-ibm-tutorial": spec: {
	workspaces: [{
		name:        "git-source"
		description: "The git repo"
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
		name:        "pathToContext"
		description: "The path to the build context, used by Kaniko - within the workspace"
		default:     "src"
	}, {
		name:        "pathToYamlFile"
		description: "The path to the yaml file to deploy within the git source"
	}]
	tasks: [{
		name: "clone-repo"
		taskRef: name: "git-clone"
		workspaces: [{
			name:      "output"
			workspace: "git-source"
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
		name: "source-to-image"
		taskRef: name: "kaniko"
		runAfter: [
			"clone-repo",
		]
		workspaces: [{
			name:      "source"
			workspace: "git-source"
		}]
		params: [{
			name:  "CONTEXT"
			value: "$(params.pathToContext)"
		}, {
			name:  "IMAGE"
			value: "$(params.image)"
		}]
	}]
}

frsca: trigger: "example-ibm-tutorial": {
	pipelineRun: spec: {
		params: [{
			name:  "image"
			value: "\(_APP_IMAGE):$(tt.params.gitrevision)"
		}, {
			name:  "SOURCE_URL"
			value: "\(_GIT_ORG)/example-ibm-tutorial"
		}, {
			name:  "SOURCE_SUBPATH"
			value: "."
		}, {
			name: "SOURCE_REFERENCE"
			value: "$(tt.params.gitrevision)"
		}, {
			name:  "pathToContext"
			value: "src"
		}, {
			name:  "pathToYamlFile"
			value: "kubernetes/picalc.yaml"
		}]
		pipelineRef: name: "example-ibm-tutorial"
		serviceAccountName: "pipeline-account"
		workspaces: [{
			name: "git-source"
		}]
	}
}
