package frsca

import (
	k8sCoreV1 "k8s.io/api/core/v1"
	k8sRbacV1 "k8s.io/api/rbac/v1"
	pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
	triggersV1Beta1 "github.com/tektoncd/triggers/pkg/apis/triggers/v1beta1"
)

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

frsca: clusterPolicy?: [Name=_]: {
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
