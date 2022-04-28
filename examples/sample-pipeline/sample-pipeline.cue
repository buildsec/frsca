package ssf

_IMAGE: name: "hello-ssf"

ssf: pipeline: "build-and-deploy-pipeline": {
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
		}]
	}
}

ssf: pipelineRun: "ssf-lab-pipelinerun-": spec: {
	pipelineRef: name: "build-and-deploy-pipeline"
	params: [{
		name:  "gitUrl"
		value: "https://github.com/IBM/tekton-tutorial-openshift"
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
	}]
}

ssf: task: "deploy-using-kubectl": {
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

ssf: task: "syft-bom-generator": {
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
			default:     "ssf-sbom.json"
			description: "filepath to store the sbom artifacts"
			name:        "sbom-filepath"
		}]
		results: [{
			description: "status of syft task, possible value are-success|failure"
			name:        "status"
		}, {
			description: "filepath to store syft bom record"
			name:        "sbom-store"
		}]
		stepTemplate: {
			name: "PIPELINE_DEBUG"
			env: [{
				name:  "PIPELINE_DEBUG"
				value: "$(params.pipeline-debug)"
			}, {
				name:  "DOCKER_CONFIG"
				value: "/steps"
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
			volumeMounts: [{
				mountPath: "/steps"
				name:      "steps-volume"
			}]
		}, {
			image: "icr.io/gitsecure/bash:latest@sha256:b69c5fe80a41b5c9053db41c81074dd894bbb47bf292e5763d053440eddaafdc"
			name:  "print-sbom"
			script: """
				set -e
				cat $(workspaces.source.path)/$(params.sbom-filepath)

				"""

			securityContext: runAsUser: 0
			volumeMounts: [{
				mountPath: "/steps"
				name:      "steps-volume"
			}]
		}, {
			image: "icr.io/gitsecure/bash:latest@sha256:b69c5fe80a41b5c9053db41c81074dd894bbb47bf292e5763d053440eddaafdc"
			name:  "write-url"
			script: """
				set -e
				echo $(params.sbom-filepath) | tee $(results.sbom-store.path)

				"""

			securityContext: runAsUser: 0
		}]
		volumes: [{
			emptyDir: {}
			name: "steps-volume"
		}]
		workspaces: [{
			name: "source"
		}]
	}
}
