package ssf

import (
	k8sCoreV1 "k8s.io/api/core/v1"
	k8sRbacV1 "k8s.io/api/rbac/v1"
	kyvernoV1 "github.com/kyverno/kyverno/api/kyverno/v1"
	pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
)

ssf: configMap?: [Name=_]: k8sCoreV1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name: *Name | string
}

ssf: secret?: [Name=_]: k8sCoreV1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: name: *Name | string
}

ssf: serviceAccount?: [Name=_]: k8sCoreV1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: name: *Name | string
}

ssf: role?: [Name=_]: k8sRbacV1.#Role & {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

ssf: clusterRole?: [Name=_]: k8sRbacV1.#ClusterRole & {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

ssf: roleBinding?: [Name=_]: k8sRbacV1.#RoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: name: *Name | string
}

ssf: clusterRoleBinding?: [Name=_]: k8sRbacV1.#ClusterRoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: name: *Name | string
}

ssf: task?: [Name=_]: pipelineV1Beta1.#Task & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Task"
	metadata: name: *Name | string
}

ssf: taskRun?: [Name=_]: pipelineV1Beta1.#TaskRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "TaskRun"
	metadata: name: *Name | string
}

ssf: pipeline?: [Name=_]: pipelineV1Beta1.#Pipeline & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: *Name | string
}

ssf: pipelineRun?: [GeneratedName=_]: pipelineV1Beta1.#PipelineRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "PipelineRun"
	metadata: {
		generateName: *GeneratedName | string
		labels: "app.kubernetes.io/description": "PipelineRun"
	}
}

ssf: persistentVolumeClaim?: [Name=_]: k8sCoreV1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: name: *Name | string
}

ssf: clusterPolicy?: [Name=_]: kyvernoV1.#ClusterPolicy & {
	apiVersion: "kyverno.io/v1"
	kind:       "ClusterPolicy"
	metadata: name: *Name | string
}
