package frsca

frsca: pipeline: "example-maven": spec: {
	workspaces: [{
		name:        "git-source"
		description: "The git repo"
	}, {
		name:        "maven-settings"
		description: "maven-settings"
	}]
	params: [{
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
		name: "maven-run"
		taskRef: name: "maven"
		runAfter: [
			"clone-repo",
		]
		workspaces: [{
			name:      "source"
			workspace: "git-source"
		}, {
			name:      "maven-settings"
			workspace: "maven-settings"
		}]
		params: [{
			name:  "GOALS"
			value: [
				"--no-transfer-progress",
				"-DskipTests",
				"clean",
				"package"
			]
		}]
	}]
}

frsca: trigger: "example-maven": {
	pipelineRun: spec: {
		pipelineRef: name: "example-maven"
		params: [{
			name:  "SOURCE_URL"
			value: "\(_GIT_ORG)/example-maven"
		}, {
			name:  "SOURCE_SUBPATH"
			value: "."
		}, {
			name: "SOURCE_REFERENCE"
			value: "$(tt.params.gitrevision)"
		}]
		workspaces: [{
			name: "git-source"
		}, {
			name: "maven-settings"
			emptyDir: {}
		}]
	}
}
