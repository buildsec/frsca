package frsca

_IMAGE: name: "hello-frsca"

frsca: pipeline: "build-and-deploy-pipeline": {
	spec: {
		params: [{
			description: "Git repository url"
			name:        "gitUrl"
		}, {
			default:     "src"
			description: "The path to the build context, used by Kaniko - within the workspace"
			name:        "pathToContext"
		}, {
			description: "The path to the yaml file to deploy within the git source"
			name:        "pathToYamlFile"
		}, {
			description: "Image name including repository"
			name:        "imageUrl"
		}, {
			default:     "latest"
			description: "Image tag"
			name:        "imageTag"
		}]
		tasks: [{
			name: "clone-repo"
			params: [{
				name:  "url"
				value: "$(params.gitUrl)"
			}, {
				name:  "subdirectory"
				value: "."
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
				value: "$(params.imageUrl):$(params.imageTag)"
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
				value: "$(params.imageUrl):$(params.imageTag)"
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
			}]
		}, {
			name: "vulnerability-scan"
			params: [{
				name:  "image-ref"
				value: "$(params.imageUrl):$(params.imageTag)"
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
				name:  "imageUrl"
				value: "$(params.imageUrl)"
			}, {
				name:  "imageTag"
				value: "$(params.imageTag)"
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
		}]
	}
}

frsca: pipelineRun: "frsca-lab-pipelinerun-": spec: {
	pipelineRef: name: "build-and-deploy-pipeline"
	params: [{
		name:  "gitUrl"
		value: "https://github.com/buildsec/example-sample-pipeline"
	}, {
		name:  "pathToYamlFile"
		value: "kubernetes/picalc.yaml"
	}, {
		name:  "imageUrl"
		value: _APP_IMAGE
	}, {
		name:  "imageTag"
		value: "1h"
	}]
	serviceAccountName: "pipeline-account"
	workspaces: [{
		name: "git-source"
	}, {
		name: "grype-config"
		configMap: {
			name: "grype-config-map"
		}
	}]
}

frsca: task: "deploy-using-kubectl": {
	spec: {
		params: [{
			description: "The path to the yaml file to deploy within the git source"
			name:        "pathToYamlFile"
		}, {
			description: "Image name including repository"
			name:        "imageUrl"
		}, {
			default:     "latest"
			description: "Image tag"
			name:        "imageTag"
		}, {
			description: "Digest of the image to be used."
			name:        "imageDigest"
		}]
		steps: [{
			args: [
				"-i",
				"-e",
				"s;__IMAGE__;$(params.imageUrl):$(params.imageTag);g",
				"-e",
				"s;__DIGEST__;$(params.imageDigest);g",
				"$(workspaces.git-source.path)/$(params.pathToYamlFile)",
			]
			command: [
				"sed",
			]
			image: "icr.io/gitsecure/alpine:latest@sha256:69704ef328d05a9f806b6b8502915e6a0a4faa4d72018dc42343f511490daf8a"
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
			image: "icr.io/gitsecure/k8s-kubectl:latest@sha256:00e810f695528eb20ce91ce11346ef2ba59f1ea4fafc0d0d44101e63991d1567"
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
				"json",
				"--file",
				"$(workspaces.source.path)/$(params.sbom-filepath)",
				"$(params.image-ref)",
			]
			image: "anchore/syft:v0.44.1@sha256:d5b44590062d4d9fc192455b5face4ebfd7879ec1540c939aa1766e5dcf4d5fc"
			name:  "syft-bom-generator"
		}, {
			image: "gcr.io/projectsigstore/cosign:v1.8.0@sha256:12b4d428529654c95a7550a936cbb5c6fe93a046ea7454676cb6fb0ce566d78c"
			name:  "attach-sbom"
			args: [
				"attach",
				"sbom",
				"--sbom", "$(workspaces.source.path)/$(params.sbom-filepath)",
				"--type", "syft",
				"$(params.image-ref)"
			]
		}]
		workspaces: [{
			name: "source"
		}]
	}
}
