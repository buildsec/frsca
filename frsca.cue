package frsca

import (
	k8sCoreV1 "k8s.io/api/core/v1"
	k8sRbacV1 "k8s.io/api/rbac/v1"
	kyvernoV1 "github.com/kyverno/kyverno/api/kyverno/v1"
	pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
	triggersV1Beta1 "github.com/tektoncd/triggers/pkg/apis/triggers/v1beta1"
)

// FRSCA Configuration
frscaConfig: {
    arch: string // untransformed architecture string
    archSed: string // transformed architecture string (e.g. x86_64 -> amd64)
    platform: string // untransformed platform string
    platformLower: string // lowercase platform string
	cosign: {
		imageBase: string | *"gcr.io/projectsigstore/cosign"
		versionNumber: string | *"1.12.0"
		imageDigest: string | *"sha256:880cc3ec8088fa59a43025d4f20961e8abc7c732e276a211cfb8b66793455dd0"
		releaseUrl: string | *"https://github.com/sigstore/cosign/releases/download/\(version)"
		checksumsFileName: string | *"cosign_checksums.txt"
		checksumsAsset: "\(releaseUrl)/\(checksumsFileName)"
		version: "v\(versionNumber)"
		imageUrl: "\(imageBase):\(version)@\(imageDigest)"
        _arch: archSed
        fileName: "cosign-\(platformLower)-\(_arch)"
        asset: "\(releaseUrl)/\(fileName)"
	}
	helm: {
		version: string | *"v3.7.1"
		releaseUrl: string | *"https://get.helm.sh"
        _arch: archSed
		dir: "\(platformLower)-\(_arch)"
        fileName: "helm-\(version)-\(dir).tar.gz"
        asset: "\(releaseUrl)/\(fileName)"
	}
	kubectl: {
		version: string | *"v1.24.3"
		releaseUrl: string | *"https://dl.k8s.io/release/\(version)"
        _arch: archSed
		asset: "\(releaseUrl)/bin/\(platformLower)/\(_arch)/kubectl"
		checksumUrl: "\(asset).sha256"
	}
	minikube: {
		version: string | *"v1.26.1"
		releaseUrl: string | *"https://github.com/kubernetes/minikube/releases/download/\(version)"
        _arch: archSed
		fileName: "minikube-\(platformLower)-\(_arch)"
		asset: "\(releaseUrl)/\(fileName)"
	}
	tektonCli: {
		versionNumber: string | *"0.23.1"
		version: "v\(versionNumber)"
		releaseUrl: string | *"https://github.com/tektoncd/cli/releases/download/\(version)"
		_arch: arch
		fileName: "tkn_\(versionNumber)_\(platform)_\(_arch).tar.gz"
		asset: "\(releaseUrl)/\(fileName)"
		checksums: "checksums.txt"
	}
} 

frsca: configMap?: [Name=_]: k8sCoreV1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name: *Name | string
}

frsca: secret?: [Name=_]: k8sCoreV1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: name: *Name | string
}

frsca: serviceAccount?: [Name=_]: k8sCoreV1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: name: *Name | string
}

frsca: role?: [Name=_]: k8sRbacV1.#Role & {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

frsca: clusterRole?: [Name=_]: k8sRbacV1.#ClusterRole & {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

frsca: roleBinding?: [Name=_]: k8sRbacV1.#RoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: name: *Name | string
}

frsca: clusterRoleBinding?: [Name=_]: k8sRbacV1.#ClusterRoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: name: *Name | string
}

frsca: task?: [Name=_]: pipelineV1Beta1.#Task & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Task"
	metadata: name: *Name | string
}

frsca: taskRun?: [Name=_]: pipelineV1Beta1.#TaskRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "TaskRun"
	metadata: name: *Name | string
}

frsca: pipeline?: [Name=_]: pipelineV1Beta1.#Pipeline & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: *Name | string
}

frsca: pipelineRun?: [GeneratedName=_]: pipelineV1Beta1.#PipelineRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "PipelineRun"
	metadata: {
		generateName: *GeneratedName | string
		labels: "app.kubernetes.io/description": "PipelineRun"
	}
}

frsca: triggerTemplate?: [Name=_]: triggersV1Beta1.#TriggerTemplate & {
	apiVersion: "triggers.tekton.dev/v1beta1"
	kind: "TriggerTemplate"
	metadata: name: *Name | string
}

frsca: triggerBinding?: [Name=_]: triggersV1Beta1.#TriggerBinding & {
	apiVersion: "triggers.tekton.dev/v1beta1"
	kind: "TriggerBinding"
	metadata: name: *Name | string
}

frsca: eventListener?: [Name=_]: triggersV1Beta1.#EventListener & {
	apiVersion: "triggers.tekton.dev/v1beta1"
	kind: "EventListener"
	metadata: name: *Name | string
	spec: {
		serviceAccountName: *"tekton-triggers-sa" | string
	}
}

frsca: persistentVolumeClaim?: [Name=_]: k8sCoreV1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: name: *Name | string
}

frsca: clusterPolicy?: [Name=_]: kyvernoV1.#ClusterPolicy & {
	apiVersion: "kyverno.io/v1"
	kind:       "ClusterPolicy"
	metadata: name: *Name | string
}

// Compensate for Kyverno ImageVerification bool defaults
frsca: clusterPolicy?: [_]: {
	spec: rules: [...{
		verifyImages: [...{
			mutateDigest: *true | bool
			verifyDigest: *true | bool
			required: *true | bool
		}]
	}]
}

// watch is used to add a tekton trigger to run a pipeline
frsca: trigger?: [Name=_]: {
	pipelineRun: pipelineV1Beta1.#PipelineRun & {
		apiVersion: "tekton.dev/v1beta1"
		kind:       "PipelineRun"
		metadata: {
			generateName: *"\(Name)-" | string
			labels: "app.kubernetes.io/description": "PipelineRun"
		}
	}
	let pr=pipelineRun
	triggerTemplate: triggersV1Beta1.#TriggerTemplate & {
		apiVersion: "triggers.tekton.dev/v1beta1"
		kind: "TriggerTemplate"
		metadata:	name: "\(Name)-triggertemplate"
		spec: {
			params: [{
				name: "gitrevision"
				description: *"The git revision" | string
				default: *"main" | string
			},...]
			resourcetemplates: [ pipelineV1Beta1.#PipelineRun & pr ]
		}
	}
	triggerBinding: triggersV1Beta1.#TriggerBinding & {
		apiVersion: "triggers.tekton.dev/v1beta1"
		kind: "TriggerBinding"
		metadata: name: "\(Name)-pipelinebinding"
		spec: params: [{
			name: "gitrevision"
			value: "$(body.head_commit.id)"
		}]
	}
	eventListener: triggersV1Beta1.#EventListener & {
		apiVersion: "triggers.tekton.dev/v1beta1"
		kind: "EventListener"
		metadata:	name: "\(Name)-listener"
		spec: {
			serviceAccountName: *"tekton-triggers-sa" | string
			triggers: [{
				bindings: [{ ref: "\(Name)-pipelinebinding" }]
				template:	ref: "\(Name)-triggertemplate"
			}]
		}
	}
}

// assemble the trigger into a trigger template, binding, and event listener
frsca: {
	if frsca.trigger != _|_ for name, w in frsca.trigger {
		triggerTemplate: "\(name)": w.triggerTemplate
		triggerBinding: "\(name)": w.triggerBinding
		eventListener: "\(name)": w.eventListener
	}
}
