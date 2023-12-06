// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1

package v1beta1

import (
	"k8s.io/apimachinery/pkg/runtime"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runv1beta1 "github.com/tektoncd/pipeline/pkg/apis/run/v1beta1"
)

// EmbeddedCustomRunSpec allows custom task definitions to be embedded
#EmbeddedCustomRunSpec: {
	runtime.#TypeMeta

	// +optional
	metadata?: #PipelineTaskMetadata @go(Metadata)

	// Spec is a specification of a custom task
	// +optional
	spec?: runtime.#RawExtension @go(Spec)
}

// CustomRunSpec defines the desired state of CustomRun
#CustomRunSpec: {
	// +optional
	customRef?: null | #TaskRef @go(CustomRef,*TaskRef)

	// Spec is a specification of a custom task
	// +optional
	customSpec?: null | #EmbeddedCustomRunSpec @go(CustomSpec,*EmbeddedCustomRunSpec)

	// +optional
	// +listType=atomic
	params?: [...#Param] @go(Params,[]Param)

	// Used for cancelling a customrun (and maybe more later on)
	// +optional
	status?: #CustomRunSpecStatus @go(Status)

	// Status message for cancellation.
	// +optional
	statusMessage?: #CustomRunSpecStatusMessage @go(StatusMessage)

	// Used for propagating retries count to custom tasks
	// +optional
	retries?: int @go(Retries)

	// +optional
	serviceAccountName?: string @go(ServiceAccountName)

	// Time after which the custom-task times out.
	// Refer Go's ParseDuration documentation for expected format: https://golang.org/pkg/time/#ParseDuration
	// +optional
	timeout?: null | metav1.#Duration @go(Timeout,*metav1.Duration)

	// Workspaces is a list of WorkspaceBindings from volumes to workspaces.
	// +optional
	// +listType=atomic
	workspaces?: [...#WorkspaceBinding] @go(Workspaces,[]WorkspaceBinding)
}

// CustomRunSpecStatus defines the taskrun spec status the user can provide
#CustomRunSpecStatus: string // #enumCustomRunSpecStatus

#enumCustomRunSpecStatus:
	#CustomRunSpecStatusCancelled

// CustomRunSpecStatusCancelled indicates that the user wants to cancel the run,
// if not already cancelled or terminated
#CustomRunSpecStatusCancelled: #CustomRunSpecStatus & "RunCancelled"

// CustomRunSpecStatusMessage defines human readable status messages for the TaskRun.
#CustomRunSpecStatusMessage: string // #enumCustomRunSpecStatusMessage

#enumCustomRunSpecStatusMessage:
	#CustomRunCancelledByPipelineMsg |
	#CustomRunCancelledByPipelineTimeoutMsg

// CustomRunCancelledByPipelineMsg indicates that the PipelineRun of which part this CustomRun was
// has been cancelled.
#CustomRunCancelledByPipelineMsg: #CustomRunSpecStatusMessage & "CustomRun cancelled as the PipelineRun it belongs to has been cancelled."

// CustomRunCancelledByPipelineTimeoutMsg indicates that the Run was cancelled because the PipelineRun running it timed out.
#CustomRunCancelledByPipelineTimeoutMsg: #CustomRunSpecStatusMessage & "CustomRun cancelled as the PipelineRun it belongs to has timed out."

// CustomRunReasonCancelled must be used in the Condition Reason to indicate that a CustomRun was cancelled.
#CustomRunReasonCancelled: "CustomRunCancelled"

// CustomRunReasonTimedOut must be used in the Condition Reason to indicate that a CustomRun was timed out.
#CustomRunReasonTimedOut: "CustomRunTimedOut"

// CustomRunReasonWorkspaceNotSupported can be used in the Condition Reason to indicate that the
// CustomRun contains a workspace which is not supported by this custom task.
#CustomRunReasonWorkspaceNotSupported: "CustomRunWorkspaceNotSupported"

// CustomRunStatus defines the observed state of CustomRun.
#CustomRunStatus: runv1beta1.#CustomRunStatus

// CustomRunStatusFields holds the fields of CustomRun's status.  This is defined
// separately and inlined so that other types can readily consume these fields
// via duck typing.
#CustomRunStatusFields: runv1beta1.#CustomRunStatusFields

// CustomRunResult used to describe the results of a task
#CustomRunResult: runv1beta1.#CustomRunResult

// CustomRun represents a single execution of a Custom Task.
//
// +k8s:openapi-gen=true
#CustomRun: {
	metav1.#TypeMeta

	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)

	// +optional
	spec?: #CustomRunSpec @go(Spec)

	// +optional
	status?: runv1beta1.#CustomRunStatus @go(Status)
}

// CustomRunList contains a list of CustomRun
#CustomRunList: {
	metav1.#TypeMeta

	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#CustomRun] @go(Items,[]CustomRun)
}
