package ssf

import (
	k8sCoreV1 "k8s.io/api/core/v1"
	k8sRbacV1 "k8s.io/api/rbac/v1"
	kyvernoV1 "github.com/kyverno/kyverno/api/kyverno/v1"
	pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
)

configMap: [Name=_]: k8sCoreV1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name: *Name | string
}

secret: [Name=_]: k8sCoreV1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: name: *Name | string
}

serviceAccount: [Name=_]: k8sCoreV1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: name: *Name | string
}

role: [Name=_]: k8sRbacV1.#Role & {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

roleBinding: [Name=_]: k8sRbacV1.#RoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: name: *Name | string
}

pipeline: [Name=_]: pipelineV1Beta1.#Pipeline & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: *Name | string
}

pipelineRun: [GeneratedName=_]: pipelineV1Beta1.#PipelineRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "PipelineRun"
	metadata: {
		generateName: *GeneratedName | string
		labels: "app.kubernetes.io/description": "PipelineRun"
	}
}

persistentVolumeClaim: [Name=_]: k8sCoreV1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: name: *Name | string
}

clusterPolicy: [Name=_]: kyvernoV1.#ClusterPolicy & {
	apiVersion: "kyverno.io/v1"
	kind:       "ClusterPolicy"
	metadata: name: *Name | string
}
