// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1

// Copyright 2022 The Tekton Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
package v1

import (
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Step runs a subcomponent of a Task
#Step: {
	// Name of the Step specified as a DNS_LABEL.
	// Each Step in a Task must have a unique name.
	name: string @go(Name) @protobuf(1,bytes,opt)

	// Docker image name.
	// More info: https://kubernetes.io/docs/concepts/containers/images
	// +optional
	image?: string @go(Image) @protobuf(2,bytes,opt)

	// Entrypoint array. Not executed within a shell.
	// The image's ENTRYPOINT is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	command?: [...string] @go(Command,[]string) @protobuf(3,bytes,rep)

	// Arguments to the entrypoint.
	// The image's CMD is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	args?: [...string] @go(Args,[]string) @protobuf(4,bytes,rep)

	// Step's working directory.
	// If not specified, the container runtime's default will be used, which
	// might be configured in the container image.
	// Cannot be updated.
	// +optional
	workingDir?: string @go(WorkingDir) @protobuf(5,bytes,opt)

	// List of sources to populate environment variables in the Step.
	// The keys defined within a source must be a C_IDENTIFIER. All invalid keys
	// will be reported as an event when the Step is starting. When a key exists in multiple
	// sources, the value associated with the last source will take precedence.
	// Values defined by an Env with a duplicate key will take precedence.
	// Cannot be updated.
	// +optional
	// +listType=atomic
	envFrom?: [...corev1.#EnvFromSource] @go(EnvFrom,[]corev1.EnvFromSource) @protobuf(19,bytes,rep)

	// List of environment variables to set in the Step.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=name
	// +patchStrategy=merge
	// +listType=atomic
	env?: [...corev1.#EnvVar] @go(Env,[]corev1.EnvVar) @protobuf(7,bytes,rep)

	// ComputeResources required by this Step.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
	// +optional
	computeResources?: corev1.#ResourceRequirements @go(ComputeResources) @protobuf(8,bytes,opt)

	// Volumes to mount into the Step's filesystem.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=mountPath
	// +patchStrategy=merge
	// +listType=atomic
	volumeMounts?: [...corev1.#VolumeMount] @go(VolumeMounts,[]corev1.VolumeMount) @protobuf(9,bytes,rep)

	// volumeDevices is the list of block devices to be used by the Step.
	// +patchMergeKey=devicePath
	// +patchStrategy=merge
	// +optional
	// +listType=atomic
	volumeDevices?: [...corev1.#VolumeDevice] @go(VolumeDevices,[]corev1.VolumeDevice) @protobuf(21,bytes,rep)

	// Image pull policy.
	// One of Always, Never, IfNotPresent.
	// Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
	// +optional
	imagePullPolicy?: corev1.#PullPolicy @go(ImagePullPolicy) @protobuf(14,bytes,opt,casttype=PullPolicy)

	// SecurityContext defines the security options the Step should be run with.
	// If set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	// +optional
	securityContext?: null | corev1.#SecurityContext @go(SecurityContext,*corev1.SecurityContext) @protobuf(15,bytes,opt)

	// Script is the contents of an executable file to execute.
	//
	// If Script is not empty, the Step cannot have an Command and the Args will be passed to the Script.
	// +optional
	script?: string @go(Script)

	// Timeout is the time after which the step times out. Defaults to never.
	// Refer to Go's ParseDuration documentation for expected format: https://golang.org/pkg/time/#ParseDuration
	// +optional
	timeout?: null | metav1.#Duration @go(Timeout,*metav1.Duration)

	// This is an alpha field. You must set the "enable-api-fields" feature flag to "alpha"
	// for this field to be supported.
	//
	// Workspaces is a list of workspaces from the Task that this Step wants
	// exclusive access to. Adding a workspace to this list means that any
	// other Step or Sidecar that does not also request this Workspace will
	// not have access to it.
	// +optional
	// +listType=atomic
	workspaces?: [...#WorkspaceUsage] @go(Workspaces,[]WorkspaceUsage)

	// OnError defines the exiting behavior of a container on error
	// can be set to [ continue | stopAndFail ]
	onError?: #OnErrorType @go(OnError)

	// Stores configuration for the stdout stream of the step.
	// +optional
	stdoutConfig?: null | #StepOutputConfig @go(StdoutConfig,*StepOutputConfig)

	// Stores configuration for the stderr stream of the step.
	// +optional
	stderrConfig?: null | #StepOutputConfig @go(StderrConfig,*StepOutputConfig)

	// Contains the reference to an existing StepAction.
	//+optional
	ref?: null | #Ref @go(Ref,*Ref)

	// Params declares parameters passed to this step action.
	// +optional
	// +listType=atomic
	params?: #Params @go(Params)

	// Results declares StepResults produced by the Step.
	//
	// This is field is at an ALPHA stability level and gated by "enable-step-actions" feature flag.
	//
	// It can be used in an inlined Step when used to store Results to $(step.results.resultName.path).
	// It cannot be used when referencing StepActions using [v1.Step.Ref].
	// The Results declared by the StepActions will be stored here instead.
	// +optional
	// +listType=atomic
	results?: [...#StepResult] @go(Results,[]StepResult)

	// When is a list of when expressions that need to be true for the task to run
	// +optional
	when?: #WhenExpressions @go(When,StepWhenExpressions)
}

// Ref can be used to refer to a specific instance of a StepAction.
#Ref: {
	// Name of the referenced step
	name?: string @go(Name)

	// ResolverRef allows referencing a StepAction in a remote location
	// like a git repo.
	// +optional
	ResolverRef?: #ResolverRef
}

// OnErrorType defines a list of supported exiting behavior of a container on error
#OnErrorType: string // #enumOnErrorType

#enumOnErrorType:
	#StopAndFail |
	#Continue

// StopAndFail indicates exit the taskRun if the container exits with non-zero exit code
#StopAndFail: #OnErrorType & "stopAndFail"

// Continue indicates continue executing the rest of the steps irrespective of the container exit code
#Continue: #OnErrorType & "continue"

// StepOutputConfig stores configuration for a step output stream.
#StepOutputConfig: {
	// Path to duplicate stdout stream to on container's local filesystem.
	// +optional
	path?: string @go(Path)
}

// StepTemplate is a template for a Step
#StepTemplate: {
	// Image reference name.
	// More info: https://kubernetes.io/docs/concepts/containers/images
	// +optional
	image?: string @go(Image) @protobuf(2,bytes,opt)

	// Entrypoint array. Not executed within a shell.
	// The image's ENTRYPOINT is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the Step's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	command?: [...string] @go(Command,[]string) @protobuf(3,bytes,rep)

	// Arguments to the entrypoint.
	// The image's CMD is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the Step's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	args?: [...string] @go(Args,[]string) @protobuf(4,bytes,rep)

	// Step's working directory.
	// If not specified, the container runtime's default will be used, which
	// might be configured in the container image.
	// Cannot be updated.
	// +optional
	workingDir?: string @go(WorkingDir) @protobuf(5,bytes,opt)

	// List of sources to populate environment variables in the Step.
	// The keys defined within a source must be a C_IDENTIFIER. All invalid keys
	// will be reported as an event when the Step is starting. When a key exists in multiple
	// sources, the value associated with the last source will take precedence.
	// Values defined by an Env with a duplicate key will take precedence.
	// Cannot be updated.
	// +optional
	// +listType=atomic
	envFrom?: [...corev1.#EnvFromSource] @go(EnvFrom,[]corev1.EnvFromSource) @protobuf(19,bytes,rep)

	// List of environment variables to set in the Step.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=name
	// +patchStrategy=merge
	// +listType=atomic
	env?: [...corev1.#EnvVar] @go(Env,[]corev1.EnvVar) @protobuf(7,bytes,rep)

	// ComputeResources required by this Step.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
	// +optional
	computeResources?: corev1.#ResourceRequirements @go(ComputeResources) @protobuf(8,bytes,opt)

	// Volumes to mount into the Step's filesystem.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=mountPath
	// +patchStrategy=merge
	// +listType=atomic
	volumeMounts?: [...corev1.#VolumeMount] @go(VolumeMounts,[]corev1.VolumeMount) @protobuf(9,bytes,rep)

	// volumeDevices is the list of block devices to be used by the Step.
	// +patchMergeKey=devicePath
	// +patchStrategy=merge
	// +optional
	// +listType=atomic
	volumeDevices?: [...corev1.#VolumeDevice] @go(VolumeDevices,[]corev1.VolumeDevice) @protobuf(21,bytes,rep)

	// Image pull policy.
	// One of Always, Never, IfNotPresent.
	// Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
	// +optional
	imagePullPolicy?: corev1.#PullPolicy @go(ImagePullPolicy) @protobuf(14,bytes,opt,casttype=PullPolicy)

	// SecurityContext defines the security options the Step should be run with.
	// If set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	// +optional
	securityContext?: null | corev1.#SecurityContext @go(SecurityContext,*corev1.SecurityContext) @protobuf(15,bytes,opt)
}

// Sidecar has nearly the same data structure as Step but does not have the ability to timeout.
#Sidecar: {
	// Name of the Sidecar specified as a DNS_LABEL.
	// Each Sidecar in a Task must have a unique name (DNS_LABEL).
	// Cannot be updated.
	name: string @go(Name) @protobuf(1,bytes,opt)

	// Image reference name.
	// More info: https://kubernetes.io/docs/concepts/containers/images
	// +optional
	image?: string @go(Image) @protobuf(2,bytes,opt)

	// Entrypoint array. Not executed within a shell.
	// The image's ENTRYPOINT is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the Sidecar's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	command?: [...string] @go(Command,[]string) @protobuf(3,bytes,rep)

	// Arguments to the entrypoint.
	// The image's CMD is used if this is not provided.
	// Variable references $(VAR_NAME) are expanded using the Sidecar's environment. If a variable
	// cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
	// to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
	// produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
	// of whether the variable exists or not. Cannot be updated.
	// More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
	// +optional
	// +listType=atomic
	args?: [...string] @go(Args,[]string) @protobuf(4,bytes,rep)

	// Sidecar's working directory.
	// If not specified, the container runtime's default will be used, which
	// might be configured in the container image.
	// Cannot be updated.
	// +optional
	workingDir?: string @go(WorkingDir) @protobuf(5,bytes,opt)

	// List of ports to expose from the Sidecar. Exposing a port here gives
	// the system additional information about the network connections a
	// container uses, but is primarily informational. Not specifying a port here
	// DOES NOT prevent that port from being exposed. Any port which is
	// listening on the default "0.0.0.0" address inside a container will be
	// accessible from the network.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=containerPort
	// +patchStrategy=merge
	// +listType=map
	// +listMapKey=containerPort
	// +listMapKey=protocol
	ports?: [...corev1.#ContainerPort] @go(Ports,[]corev1.ContainerPort) @protobuf(6,bytes,rep)

	// List of sources to populate environment variables in the Sidecar.
	// The keys defined within a source must be a C_IDENTIFIER. All invalid keys
	// will be reported as an event when the container is starting. When a key exists in multiple
	// sources, the value associated with the last source will take precedence.
	// Values defined by an Env with a duplicate key will take precedence.
	// Cannot be updated.
	// +optional
	// +listType=atomic
	envFrom?: [...corev1.#EnvFromSource] @go(EnvFrom,[]corev1.EnvFromSource) @protobuf(19,bytes,rep)

	// List of environment variables to set in the Sidecar.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=name
	// +patchStrategy=merge
	// +listType=atomic
	env?: [...corev1.#EnvVar] @go(Env,[]corev1.EnvVar) @protobuf(7,bytes,rep)

	// ComputeResources required by this Sidecar.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
	// +optional
	computeResources?: corev1.#ResourceRequirements @go(ComputeResources) @protobuf(8,bytes,opt)

	// Volumes to mount into the Sidecar's filesystem.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=mountPath
	// +patchStrategy=merge
	// +listType=atomic
	volumeMounts?: [...corev1.#VolumeMount] @go(VolumeMounts,[]corev1.VolumeMount) @protobuf(9,bytes,rep)

	// volumeDevices is the list of block devices to be used by the Sidecar.
	// +patchMergeKey=devicePath
	// +patchStrategy=merge
	// +optional
	// +listType=atomic
	volumeDevices?: [...corev1.#VolumeDevice] @go(VolumeDevices,[]corev1.VolumeDevice) @protobuf(21,bytes,rep)

	// Periodic probe of Sidecar liveness.
	// Container will be restarted if the probe fails.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	// +optional
	livenessProbe?: null | corev1.#Probe @go(LivenessProbe,*corev1.Probe) @protobuf(10,bytes,opt)

	// Periodic probe of Sidecar service readiness.
	// Container will be removed from service endpoints if the probe fails.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	// +optional
	readinessProbe?: null | corev1.#Probe @go(ReadinessProbe,*corev1.Probe) @protobuf(11,bytes,opt)

	// StartupProbe indicates that the Pod the Sidecar is running in has successfully initialized.
	// If specified, no other probes are executed until this completes successfully.
	// If this probe fails, the Pod will be restarted, just as if the livenessProbe failed.
	// This can be used to provide different probe parameters at the beginning of a Pod's lifecycle,
	// when it might take a long time to load data or warm a cache, than during steady-state operation.
	// This cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	// +optional
	startupProbe?: null | corev1.#Probe @go(StartupProbe,*corev1.Probe) @protobuf(22,bytes,opt)

	// Actions that the management system should take in response to Sidecar lifecycle events.
	// Cannot be updated.
	// +optional
	lifecycle?: null | corev1.#Lifecycle @go(Lifecycle,*corev1.Lifecycle) @protobuf(12,bytes,opt)

	// Optional: Path at which the file to which the Sidecar's termination message
	// will be written is mounted into the Sidecar's filesystem.
	// Message written is intended to be brief final status, such as an assertion failure message.
	// Will be truncated by the node if greater than 4096 bytes. The total message length across
	// all containers will be limited to 12kb.
	// Defaults to /dev/termination-log.
	// Cannot be updated.
	// +optional
	terminationMessagePath?: string @go(TerminationMessagePath) @protobuf(13,bytes,opt)

	// Indicate how the termination message should be populated. File will use the contents of
	// terminationMessagePath to populate the Sidecar status message on both success and failure.
	// FallbackToLogsOnError will use the last chunk of Sidecar log output if the termination
	// message file is empty and the Sidecar exited with an error.
	// The log output is limited to 2048 bytes or 80 lines, whichever is smaller.
	// Defaults to File.
	// Cannot be updated.
	// +optional
	terminationMessagePolicy?: corev1.#TerminationMessagePolicy @go(TerminationMessagePolicy) @protobuf(20,bytes,opt,casttype=TerminationMessagePolicy)

	// Image pull policy.
	// One of Always, Never, IfNotPresent.
	// Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
	// +optional
	imagePullPolicy?: corev1.#PullPolicy @go(ImagePullPolicy) @protobuf(14,bytes,opt,casttype=PullPolicy)

	// SecurityContext defines the security options the Sidecar should be run with.
	// If set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	// +optional
	securityContext?: null | corev1.#SecurityContext @go(SecurityContext,*corev1.SecurityContext) @protobuf(15,bytes,opt)

	// Whether this Sidecar should allocate a buffer for stdin in the container runtime. If this
	// is not set, reads from stdin in the Sidecar will always result in EOF.
	// Default is false.
	// +optional
	stdin?: bool @go(Stdin) @protobuf(16,varint,opt)

	// Whether the container runtime should close the stdin channel after it has been opened by
	// a single attach. When stdin is true the stdin stream will remain open across multiple attach
	// sessions. If stdinOnce is set to true, stdin is opened on Sidecar start, is empty until the
	// first client attaches to stdin, and then remains open and accepts data until the client disconnects,
	// at which time stdin is closed and remains closed until the Sidecar is restarted. If this
	// flag is false, a container processes that reads from stdin will never receive an EOF.
	// Default is false
	// +optional
	stdinOnce?: bool @go(StdinOnce) @protobuf(17,varint,opt)

	// Whether this Sidecar should allocate a TTY for itself, also requires 'stdin' to be true.
	// Default is false.
	// +optional
	tty?: bool @go(TTY) @protobuf(18,varint,opt)

	// Script is the contents of an executable file to execute.
	//
	// If Script is not empty, the Step cannot have an Command or Args.
	// +optional
	script?: string @go(Script)

	// This is an alpha field. You must set the "enable-api-fields" feature flag to "alpha"
	// for this field to be supported.
	//
	// Workspaces is a list of workspaces from the Task that this Sidecar wants
	// exclusive access to. Adding a workspace to this list means that any
	// other Step or Sidecar that does not also request this Workspace will
	// not have access to it.
	// +optional
	// +listType=atomic
	workspaces?: [...#WorkspaceUsage] @go(Workspaces,[]WorkspaceUsage)

	// RestartPolicy refers to kubernetes RestartPolicy. It can only be set for an
	// initContainer and must have it's policy set to "Always". It is currently
	// left optional to help support Kubernetes versions prior to 1.29 when this feature
	// was introduced.
	// +optional
	restartPolicy?: null | corev1.#ContainerRestartPolicy @go(RestartPolicy,*corev1.ContainerRestartPolicy)
}
