package maven

id: string
sourceUrl: string

_id: id
_sourceUrl: sourceUrl
_runName: "\(id)-run-"
_workspace: "\(_runName)ws"
_pvc: "\(_runName)source-ws-pvc"
_mavenSettings: "maven-settings"

frsca: pipelineRun: "\(_runName)": {
    apiVersion: "tekton.dev/v1beta1"
    kind: "PipelineRun"
    metadata: generateName: _runName
    spec: {
        pipelineRef: name: _id
        workspaces: [{
            name: _workspace
            persistentVolumeClaim: claimName: _pvc
        },{
            name: _mavenSettings
            emptyDir: {}
        }]
    }
}

frsca: pipeline: "\(_id)": {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: _id
	spec: {
		workspaces: [{
			name: _workspace
		}, {
			name: _mavenSettings
		}]
		tasks: [{
			name: "fetch-repository"
			taskRef: name: "git-clone"
			workspaces: [{
				name:      "output"
				workspace: "\(id)-run-ws"
			}]
			params: [{
				name:  "url"
				value: _sourceUrl
			}, {
				name:  "subdirectory"
				value: ""
			}, {
				name:  "deleteExisting"
				value: "true"
			}]
		}, {
			name: "maven-run"
			taskRef: name: "maven"
			runAfter: [
				"fetch-repository",
			]
			params: [{
				name: "GOALS"
				value: [
					"--no-transfer-progress",
					"-DskipTests",
					"clean",
					"package",
				]
			}]
			workspaces: [{
				name:      _mavenSettings
				workspace: _mavenSettings
			}, {
				name:      "source"
				workspace: _workspace
			}]
		}]
	}
}
