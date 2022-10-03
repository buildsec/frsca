package frsca

_IMAGE: name: "example-sample"

frsca: pipeline: "example-sample-pipeline": spec: {
	params: [{
		name:        "image"
		description: "reference of the image to build"
	}, {
		name:        "imageRepo"
		description: "reference of the image repository"
	}, {
		name:        "imageTag"
		description: "image tag"
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
	}, {
		description: "The path to the yaml file to deploy within the git source"
		name:        "pathToYamlFile"
	}]
	tasks: [{
		name: "clone-repo"
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
		taskRef: name: "git-clone"
		workspaces: [{
			name:      "output"
			workspace: "git-source"
		}]
	}, {
		name: "build-and-push-image"
		params: [{
			name:  "CONTEXT"
			value: "$(params.pathToContext)"
		}, {
			name:  "IMAGE"
			value: "$(params.image)"
		}]
		runAfter: [
			"clone-repo",
		]
		taskRef: name: "kaniko"
		workspaces: [{
			name:      "source"
			workspace: "git-source"
		}]
	}, {
		name: "generate-bom"
		params: [{
			name:  "image-ref"
			value: "$(params.image)"
		}, {
			name:  "image-digest"
			value: "$(tasks.build-and-push-image.results.IMAGE_DIGEST)"
		}]
		runAfter: [
			"build-and-push-image",
		]
		taskRef: name: "syft-bom-generator"
		workspaces: [{
			name:      "source"
			workspace: "git-source"
		}, {
			name: "syft-config"
			workspace: "syft-config"
		}]
	}, {
		name: "vulnerability-scan"
		params: [{
			name:  "image-ref"
			value: "$(params.image)"
		}, {
			name:  "image-digest"
			value: "$(tasks.build-and-push-image.results.IMAGE_DIGEST)"
		}]
		runAfter: [
			"build-and-push-image",
		]
		taskRef: name: "grype-vulnerability-scan"
		workspaces: [{
			name:      "grype-config"
			workspace: "grype-config"
		}]
	}, {
		name: "deploy-to-cluster"
		params: [{
			name:  "pathToYamlFile"
			value: "$(params.pathToYamlFile)"
		}, {
			name:  "image"
			value: "$(params.image)"
		}, {
			name:  "imageDigest"
			value: "$(tasks.build-and-push-image.results.IMAGE_DIGEST)"
		}]
		runAfter: [
			"vulnerability-scan",
		]
		taskRef: name: "deploy-using-kubectl"
		workspaces: [{
			name:      "git-source"
			workspace: "git-source"
		}]
	}]
	workspaces: [{
		description: "The git repo"
		name:        "git-source"
	}, {
		name: "grype-config"
	}, {
		name: "syft-config"
	}]
}

frsca: trigger: "example-sample-pipeline": {
	pipelineRun: spec: {
		pipelineRef: name: "example-sample-pipeline"
		params: [{
			name:  "image"
			value: "\(_APP_IMAGE):$(tt.params.gitrevision)"
		}, {
			name:  "imageRepo"
			value: _APP_IMAGE
		}, {
			name:  "imageTag"
			value: "$(tt.params.gitrevision)"
		}, {
			name:  "SOURCE_URL"
			value: "\(_GIT_ORG)/example-sample-pipeline"
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
		serviceAccountName: "pipeline-account"
		workspaces: [{
			name: "git-source"
		}, {
			name: "grype-config"
			configMap: {
				name: "grype-config-map"
			}
		}, {
			name: "syft-config"
			configMap: {
				name: "syft-config-map"
			}
		}]
	}
}

frsca: task: "deploy-using-kubectl": {
	spec: {
		params: [{
			description: "The path to the yaml file to deploy within the git source"
			name:        "pathToYamlFile"
		}, {
			description: "Image name including repository and tag"
			name:        "image"
		}, {
			description: "Digest of the image to be used."
			name:        "imageDigest"
		}]
		steps: [{
			args: [
				"-i",
				"-e",
				"s;__IMAGE__;$(params.image);g",
				"-e",
				"s;__DIGEST__;$(params.imageDigest);g",
				"-e",
				"s;registry.registry/;localhost:5000/;g",
				"$(workspaces.git-source.path)/$(params.pathToYamlFile)",
			]
			command: [
				"sed",
			]
			image: "docker.io/library/alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad"
			name:  "update-yaml"
		}, {
			args: [
				"apply",
				"-n",
				"prod",
				"-f",
				"$(workspaces.git-source.path)/$(params.pathToYamlFile)",
			]
			command: [
				"kubectl",
			]
			image: "docker.io/lachlanevenson/k8s-kubectl:v1.24.3@sha256:7b0568820851c1a1072379add4954aa25c9bf616d39f1f72887a6e7bb64df254"
			name:  "run-kubectl"
		}]
		workspaces: [{
			description: "The git repo"
			name:        "git-source"
		}]
	}
}

frsca: task: "syft-bom-generator": {
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
			default:     "frsca-sbom.json"
			description: "filepath to store the sbom artifacts"
			name:        "sbom-filepath"
		}]
		results: [{
			description: "status of syft task, possible value are-success|failure"
			name:        "status"
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
				"-o",
				"spdx-json",
				"--config",
				"/var/syft-config/.syft.yaml",
				"--file",
				"$(workspaces.source.path)/$(params.sbom-filepath)",
				"$(params.image-ref)",
			]
			image: "anchore/syft:v0.58.0@sha256:b764278a9a45f3493b78b8708a4d68447807397fe8c8f59bf21f18c9bee4be94"
			name:  "syft-bom-generator"
		}, {
			image: frscaConfig.cosign.imageUrl
			name:  "attach-sbom"
			args: [
				"attach",
				"sbom",
				"--sbom", "$(workspaces.source.path)/$(params.sbom-filepath)",
				"--type", "spdx",
				"$(params.image-ref)"
			]
		}]
		workspaces: [{
			name: "source"
		}, {
			name: "syft-config"
			mountPath: "/var/syft-config/.syft.yaml"
		}]
	}
}
