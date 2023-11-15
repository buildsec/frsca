// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1

package v1beta1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	corev1 "k8s.io/api/core/v1"
)

// Task represents a collection of sequential steps that are run as part of a
// Pipeline using a set of inputs and producing a set of outputs. Tasks execute
// when TaskRuns are created that provide the input parameters and resources and
// output resources the Task requires.
//
// Deprecated: Please use v1.Task instead.
#Task: {
	metav1.#TypeMeta

	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)

	// Spec holds the desired state of the Task from the client
	// +optional
	spec?: #TaskSpec @go(Spec)
}

// TaskSpec defines the desired state of Task.
#TaskSpec: {
	// Resources is a list input and output resource to run the task
	// Resources are represented in TaskRuns as bindings to instances of
	// PipelineResources.
	//
	// Deprecated: Unused, preserved only for backwards compatibility
	// +optional
	resources?: null | #TaskResources @go(Resources,*TaskResources)

	// Params is a list of input parameters required to run the task. Params
	// must be supplied as inputs in TaskRuns unless they declare a default
	// value.
	// +optional
	// +listType=atomic
	params?: #ParamSpecs @go(Params)

	// DisplayName is a user-facing name of the task that may be
	// used to populate a UI.
	// +optional
	displayName?: string @go(DisplayName)

	// Description is a user-facing description of the task that may be
	// used to populate a UI.
	// +optional
	description?: string @go(Description)

	// Steps are the steps of the build; each step is run sequentially with the
	// source mounted into /workspace.
	// +listType=atomic
	steps?: [...#Step] @go(Steps,[]Step)

	// Volumes is a collection of volumes that are available to mount into the
	// steps of the build.
	// +listType=atomic
	volumes?: [...corev1.#Volume] @go(Volumes,[]corev1.Volume)

	// StepTemplate can be used as the basis for all step containers within the
	// Task, so that the steps inherit settings on the base container.
	stepTemplate?: null | #StepTemplate @go(StepTemplate,*StepTemplate)

	// Sidecars are run alongside the Task's step containers. They begin before
	// the steps start and end after the steps complete.
	// +listType=atomic
	sidecars?: [...#Sidecar] @go(Sidecars,[]Sidecar)

	// Workspaces are the volumes that this Task requires.
	// +listType=atomic
	workspaces?: [...#WorkspaceDeclaration] @go(Workspaces,[]WorkspaceDeclaration)

	// Results are values that this Task can output
	// +listType=atomic
	results?: [...#TaskResult] @go(Results,[]TaskResult)
}

// TaskList contains a list of Task
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
#TaskList: {
	metav1.#TypeMeta

	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#Task] @go(Items,[]Task)
}
