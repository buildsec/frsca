package ssf

_image: {
	name: "hello-ssf"
}

pipeline: "build-and-deploy-pipeline": {
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

pipelineRun: "ssf-lab-pipelinerun-": spec: {
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

task: "kaniko": {
	metadata: {
		annotations: {
			"tekton.dev/categories":           "Image Build"
			"tekton.dev/pipelines.minVersion": "0.12.1"
			"tekton.dev/tags":                 "image-build"
		}
		labels: "app.kubernetes.io/version": "0.2"
	}
	spec: {
		description: """
			This Task builds source into a container image using Google's kaniko tool.
			Kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.
			"""

		params: [{
			description: "Name (reference) of the image to build."
			name:        "IMAGE"
		}, {
			default:     "./Dockerfile"
			description: "Path to the Dockerfile to build."
			name:        "DOCKERFILE"
		}, {
			default:     "./"
			description: "The build context used by Kaniko."
			name:        "CONTEXT"
		}, {
			default: ""
			name:    "EXTRA_ARGS"
		}]
		results: [{
			description: "Digest of the image just built."
			name:        "IMAGE_DIGEST"
		}, {
			description: "URL of the image just built."
			name:        "IMAGE_URL"
		}]
		steps: [{
			args: [
				"$(params.EXTRA_ARGS)",
				"--dockerfile=$(params.DOCKERFILE)",
				"--context=$(workspaces.source.path)/$(params.CONTEXT)",
				"--destination=$(params.IMAGE)",
				"--oci-layout-path=$(workspaces.source.path)/$(params.CONTEXT)/image-digest",
			]
			env: [{
				name:  "DOCKER_CONFIG"
				value: "/kaniko/.docker/"
			}]
			image: "icr.io/gitsecure/executor:v1.5.1@sha256:c812530c2ea981d3316c7544b180289abfbd9adf1dde6f1345692b8fb0a65cb0"
			name:  "build-and-push"
			securityContext: runAsUser: 0
			// volumeMounts: [{
			// 	mountPath: "/kaniko/.docker/"
			// 	name:      "registry-secret"
			// }]
			workingDir: "$(workspaces.source.path)"
		}, {
			args: [
				"-images=[{\"name\":\"$(params.IMAGE)\",\"type\":\"image\",\"url\":\"$(params.IMAGE)\",\"digest\":\"\",\"OutputImageDir\":\"$(workspaces.source.path)/$(params.CONTEXT)/image-digest\"}]",
				"-terminationMessagePath=$(params.CONTEXT)/image-digested",
			]
			command: [
				"/ko-app/imagedigestexporter",
			]
			image: "icr.io/gitsecure/imagedigestexporter:v0.16.2@sha256:542d437868a0168f0771d840233110fbf860b210b0e9becce5d75628c694b958"
			name:  "write-digest"
			securityContext: runAsUser: 0
			workingDir: "$(workspaces.source.path)"
		}, {
			image: "icr.io/gitsecure/jq:latest@sha256:3d349004b4332571a9a14acf8c26088c7d289cf6a6d69ada982001a8779d2bbf"
			name:  "digest-to-results"
			script: """
				cat $(params.CONTEXT)/image-digested | jq '.[0].value' -rj | tee /tekton/results/IMAGE_DIGEST

				"""

			workingDir: "$(workspaces.source.path)"
		}, {
			name:  "write-url"
			image: "icr.io/gitsecure/bash:latest@sha256:b69c5fe80a41b5c9053db41c81074dd894bbb47bf292e5763d053440eddaafdc"
			script: """
				set -e
				echo $(params.IMAGE) | tee $(results.IMAGE_URL.path)

				"""

			securityContext: runAsUser: 0
		}]
		volumes: [{
			name: "registry-secret"
			secret: secretName: "secret-dockerconfigjson"
		}]
		workspaces: [{
			name: "source"
		}]
	}
}

task: "deploy-using-kubectl": {
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

task: "git-clone": {
	metadata: {
		annotations: {
			"tekton.dev/categories":           "Git"
			"tekton.dev/displayName":          "git clone"
			"tekton.dev/pipelines.minVersion": "0.21.0"
			"tekton.dev/tags":                 "git"
		}
		labels: "app.kubernetes.io/version": "0.4"
	}
	spec: {
		description: """
			These Tasks are Git tasks to work with repositories used by other tasks in your Pipeline.
			The git-clone Task will clone a repo from the provided url into the output Workspace. By default the repo will be cloned into the root of your Workspace. You can clone into a subdirectory by setting this Task's subdirectory param. This Task also supports sparse checkouts. To perform a sparse checkout, pass a list of comma separated directory patterns to this Task's sparseCheckoutDirectories param.
			"""

		params: [{
			description: "Repository URL to clone from."
			name:        "url"
			type:        "string"
		}, {
			default:     ""
			description: "Revision to checkout. (branch, tag, sha, ref, etc...)"
			name:        "revision"
			type:        "string"
		}, {
			default:     ""
			description: "Refspec to fetch before checking out revision."
			name:        "refspec"
		}, {
			default:     "true"
			description: "Initialize and fetch git submodules."
			name:        "submodules"
			type:        "string"
		}, {
			default:     "1"
			description: "Perform a shallow clone, fetching only the most recent N commits."
			name:        "depth"
			type:        "string"
		}, {
			default:     "true"
			description: "Set the `http.sslVerify` global git config. Setting this to `false` is not advised unless you are sure that you trust your git remote."

			name: "sslVerify"
			type: "string"
		}, {
			default:     ""
			description: "Subdirectory inside the `output` Workspace to clone the repo into."
			name:        "subdirectory"
			type:        "string"
		}, {
			default:     ""
			description: "Define the directory patterns to match or exclude when performing a sparse checkout."

			name: "sparseCheckoutDirectories"
			type: "string"
		}, {
			default:     "true"
			description: "Clean out the contents of the destination directory if it already exists before cloning."

			name: "deleteExisting"
			type: "string"
		}, {
			default:     ""
			description: "HTTP proxy server for non-SSL requests."
			name:        "httpProxy"
			type:        "string"
		}, {
			default:     ""
			description: "HTTPS proxy server for SSL requests."
			name:        "httpsProxy"
			type:        "string"
		}, {
			default:     ""
			description: "Opt out of proxying HTTP/HTTPS requests."
			name:        "noProxy"
			type:        "string"
		}, {
			default:     "true"
			description: "Log the commands that are executed during `git-clone`'s operation."
			name:        "verbose"
			type:        "string"
		}, {
			default:     "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.21.0"
			description: "The image providing the git-init binary that this Task runs."
			name:        "gitInitImage"
			type:        "string"
		}, {
			default: "/tekton/home"
			description: """
				Absolute path to the user's home directory. Set this explicitly if you are running the image as a non-root user or have overridden
				the gitInitImage param with an image containing custom user configuration.

				"""

			name: "userHome"
			type: "string"
		}]
		results: [{
			description: "The precise commit SHA that was fetched by this Task."
			name:        "commit"
		}, {
			description: "The precise URL that was fetched by this Task."
			name:        "url"
		}]
		steps: [{
			env: [{
				name:  "HOME"
				value: "$(params.userHome)"
			}, {
				name:  "PARAM_URL"
				value: "$(params.url)"
			}, {
				name:  "PARAM_REVISION"
				value: "$(params.revision)"
			}, {
				name:  "PARAM_REFSPEC"
				value: "$(params.refspec)"
			}, {
				name:  "PARAM_SUBMODULES"
				value: "$(params.submodules)"
			}, {
				name:  "PARAM_DEPTH"
				value: "$(params.depth)"
			}, {
				name:  "PARAM_SSL_VERIFY"
				value: "$(params.sslVerify)"
			}, {
				name:  "PARAM_SUBDIRECTORY"
				value: "$(params.subdirectory)"
			}, {
				name:  "PARAM_DELETE_EXISTING"
				value: "$(params.deleteExisting)"
			}, {
				name:  "PARAM_HTTP_PROXY"
				value: "$(params.httpProxy)"
			}, {
				name:  "PARAM_HTTPS_PROXY"
				value: "$(params.httpsProxy)"
			}, {
				name:  "PARAM_NO_PROXY"
				value: "$(params.noProxy)"
			}, {
				name:  "PARAM_VERBOSE"
				value: "$(params.verbose)"
			}, {
				name:  "PARAM_SPARSE_CHECKOUT_DIRECTORIES"
				value: "$(params.sparseCheckoutDirectories)"
			}, {
				name:  "PARAM_USER_HOME"
				value: "$(params.userHome)"
			}, {
				name:  "WORKSPACE_OUTPUT_PATH"
				value: "$(workspaces.output.path)"
			}, {
				name:  "WORKSPACE_SSH_DIRECTORY_BOUND"
				value: "$(workspaces.ssh-directory.bound)"
			}, {
				name:  "WORKSPACE_SSH_DIRECTORY_PATH"
				value: "$(workspaces.ssh-directory.path)"
			}, {
				name:  "WORKSPACE_BASIC_AUTH_DIRECTORY_BOUND"
				value: "$(workspaces.basic-auth.bound)"
			}, {
				name:  "WORKSPACE_BASIC_AUTH_DIRECTORY_PATH"
				value: "$(workspaces.basic-auth.path)"
			}]
			image: "icr.io/gitsecure/git-init:v0.21.0@sha256:322e3502c1e6fba5f1869efb55cfd998a3679e073840d33eb0e3c482b5d5609b"
			name:  "clone"
			script: """
				#!/usr/bin/env sh
				set -eu

				if [ \"${PARAM_VERBOSE}\" = \"true\" ] ; then
				  set -x
				fi

				if [ \"${WORKSPACE_BASIC_AUTH_DIRECTORY_BOUND}\" = \"true\" ] ; then
				  cp \"${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.git-credentials\" \"${PARAM_USER_HOME}/.git-credentials\"
				  cp \"${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.gitconfig\" \"${PARAM_USER_HOME}/.gitconfig\"
				  chmod 400 \"${PARAM_USER_HOME}/.git-credentials\"
				  chmod 400 \"${PARAM_USER_HOME}/.gitconfig\"
				fi

				if [ \"${WORKSPACE_SSH_DIRECTORY_BOUND}\" = \"true\" ] ; then
				  cp -R \"${WORKSPACE_SSH_DIRECTORY_PATH}\" \"${PARAM_USER_HOME}\"/.ssh
				  chmod 700 \"${PARAM_USER_HOME}\"/.ssh
				  chmod -R 400 \"${PARAM_USER_HOME}\"/.ssh/*
				fi

				CHECKOUT_DIR=\"${WORKSPACE_OUTPUT_PATH}/${PARAM_SUBDIRECTORY}\"

				cleandir() {
				  # Delete any existing contents of the repo directory if it exists.
				  #
				  # We don't just \"rm -rf ${CHECKOUT_DIR}\" because ${CHECKOUT_DIR} might be \"/\"
				  # or the root of a mounted volume.
				  if [ -d \"${CHECKOUT_DIR}\" ] ; then
				    # Delete non-hidden files and directories
				    rm -rf \"${CHECKOUT_DIR:?}\"/*
				    # Delete files and directories starting with . but excluding ..
				    rm -rf \"${CHECKOUT_DIR}\"/.[!.]*
				    # Delete files and directories starting with .. plus any other character
				    rm -rf \"${CHECKOUT_DIR}\"/..?*
				  fi
				}

				if [ \"${PARAM_DELETE_EXISTING}\" = \"true\" ] ; then
				  cleandir
				fi

				test -z \"${PARAM_HTTP_PROXY}\" || export HTTP_PROXY=\"${PARAM_HTTP_PROXY}\"
				test -z \"${PARAM_HTTPS_PROXY}\" || export HTTPS_PROXY=\"${PARAM_HTTPS_PROXY}\"
				test -z \"${PARAM_NO_PROXY}\" || export NO_PROXY=\"${PARAM_NO_PROXY}\"

				/ko-app/git-init \\
				  -url=\"${PARAM_URL}\" \\
				  -revision=\"${PARAM_REVISION}\" \\
				  -refspec=\"${PARAM_REFSPEC}\" \\
				  -path=\"${CHECKOUT_DIR}\" \\
				  -sslVerify=\"${PARAM_SSL_VERIFY}\" \\
				  -submodules=\"${PARAM_SUBMODULES}\" \\
				  -depth=\"${PARAM_DEPTH}\" \\
				  -sparseCheckoutDirectories=\"${PARAM_SPARSE_CHECKOUT_DIRECTORIES}\"
				cd \"${CHECKOUT_DIR}\"
				RESULT_SHA=\"$(git rev-parse HEAD)\"
				EXIT_CODE=\"$?\"
				if [ \"${EXIT_CODE}\" != 0 ] ; then
				  exit \"${EXIT_CODE}\"
				fi
				printf \"%s\" \"${RESULT_SHA}\" > \"$(results.commit.path)\"
				printf \"%s\" \"${PARAM_URL}\" > \"$(results.url.path)\"

				"""
		}]

		workspaces: [{
			description: "The git repo will be cloned onto the volume backing this Workspace."
			name:        "output"
		}, {
			description: """
				A .ssh directory with private key, known_hosts, config, etc. Copied to
				the user's home before git commands are executed. Used to authenticate
				with the git remote when performing the clone. Binding a Secret to this
				Workspace is strongly recommended over other volume types.

				"""

			name:     "ssh-directory"
			optional: true
		}, {
			description: """
				A Workspace containing a .gitconfig and .git-credentials file. These
				will be copied to the user's home before any git commands are run. Any
				other files in this Workspace are ignored. It is strongly recommended
				to use ssh-directory over basic-auth whenever possible and to bind a
				Secret to this Workspace over other volume types.

				"""

			name:     "basic-auth"
			optional: true
		}]
	}
}

task: "grype-vulnerability-scan": {
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
			default:     "ssf-vulnerability-report.json"
			description: "filepath to store the vulnerability report"
			name:        "vulnerability-report-filepath"
		}]
		results: [{
			description: "status of syft task, possible value are-success|failure"
			name:        "status"
		}, {
			description: "filepath to store vulnerability report"
			name:        "vulnerability-report"
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
				"""
					#!/bin/sh
					if [ \"$PIPELINE_DEBUG\" == \"1\" ]; then
					  set -x +e
					fi
					imgRef=$(params.image-ref)@$(params.image-digest)
					echo \"running vulnerability scan on $imgRef\"
					grype $imgRef > vulnerability-report.txt
					cat vulnerability-report.txt
					okMsg=\"No vulnerabilities found\"

					if [ \"$okMsg\" == \"$(cat vulnerability-report.txt)\" ] ;then
					  exit 0
					else
					  exit 1
					fi

					""",
			]

			command: [
				"/bin/sh",
				"-c",
			]
			image: "icr.io/gitsecure/anchore-grype:0.23@sha256:0e948bb5e7534c2191d2877352e52a317dc91e52192e8723749bf7ff018168da"
			name:  "grype-scanner"
		}]
	}
}

task: "syft-bom-generator": {
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
			image: "icr.io/gitsecure/syft:v0.27.0@sha256:c03549c863ccc4c60e795d7299624bb7e686248c537adff4246b8031904c7743"
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
