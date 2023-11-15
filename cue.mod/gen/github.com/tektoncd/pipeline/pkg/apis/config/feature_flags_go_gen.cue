// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/config

package config

// StableAPIFields is the value used for "enable-api-fields" when only stable APIs should be usable.
#StableAPIFields: "stable"

// AlphaAPIFields is the value used for "enable-api-fields" when alpha APIs should be usable as well.
#AlphaAPIFields: "alpha"

// BetaAPIFields is the value used for "enable-api-fields" when beta APIs should be usable as well.
#BetaAPIFields: "beta"

// FailNoMatchPolicy is the value used for "trusted-resources-verification-no-match-policy" to fail TaskRun or PipelineRun
// when no matching policies are found
#FailNoMatchPolicy: "fail"

// WarnNoMatchPolicy is the value used for "trusted-resources-verification-no-match-policy" to log warning and skip verification
// when no matching policies are found
#WarnNoMatchPolicy: "warn"

// IgnoreNoMatchPolicy is the value used for "trusted-resources-verification-no-match-policy" to skip verification
// when no matching policies are found
#IgnoreNoMatchPolicy: "ignore"

// CoscheduleWorkspaces is the value used for "coschedule" to coschedule PipelineRun Pods sharing the same PVC workspaces to the same node
#CoscheduleWorkspaces: "workspaces"

// CoschedulePipelineRuns is the value used for "coschedule" to coschedule all PipelineRun Pods to the same node
#CoschedulePipelineRuns: "pipelineruns"

// CoscheduleIsolatePipelineRun is the value used for "coschedule" to coschedule all PipelineRun Pods to the same node, and only allows one PipelineRun to run on a node at a time
#CoscheduleIsolatePipelineRun: "isolate-pipelinerun"

// CoscheduleDisabled is the value used for "coschedule" to disabled PipelineRun Pods coschedule
#CoscheduleDisabled: "disabled"

// ResultExtractionMethodTerminationMessage is the value used for "results-from" as a way to extract results from tasks using kubernetes termination message.
#ResultExtractionMethodTerminationMessage: "termination-message"

// ResultExtractionMethodSidecarLogs is the value used for "results-from" as a way to extract results from tasks using sidecar logs.
#ResultExtractionMethodSidecarLogs: "sidecar-logs"

// DefaultDisableAffinityAssistant is the default value for "disable-affinity-assistant".
#DefaultDisableAffinityAssistant: false

// DefaultDisableCredsInit is the default value for "disable-creds-init".
#DefaultDisableCredsInit: false

// DefaultRunningInEnvWithInjectedSidecars is the default value for "running-in-environment-with-injected-sidecars".
#DefaultRunningInEnvWithInjectedSidecars: true

// DefaultAwaitSidecarReadiness is the default value for "await-sidecar-readiness".
#DefaultAwaitSidecarReadiness: true

// DefaultRequireGitSSHSecretKnownHosts is the default value for "require-git-ssh-secret-known-hosts".
#DefaultRequireGitSSHSecretKnownHosts: false

// DefaultEnableTektonOciBundles is the default value for "enable-tekton-oci-bundles".
#DefaultEnableTektonOciBundles: false

// DefaultEnableAPIFields is the default value for "enable-api-fields".
#DefaultEnableAPIFields: "beta"

// DefaultSendCloudEventsForRuns is the default value for "send-cloudevents-for-runs".
#DefaultSendCloudEventsForRuns: false

// EnforceNonfalsifiabilityWithSpire is the value used for  "enable-nonfalsifiability" when SPIRE is used to enable non-falsifiability.
#EnforceNonfalsifiabilityWithSpire: "spire"

// EnforceNonfalsifiabilityNone is the value used for  "enable-nonfalsifiability" when non-falsifiability is not enabled.
#EnforceNonfalsifiabilityNone: "none"

// DefaultEnforceNonfalsifiability is the default value for "enforce-nonfalsifiability".
#DefaultEnforceNonfalsifiability: "none"

// DefaultNoMatchPolicyConfig is the default value for "trusted-resources-verification-no-match-policy".
#DefaultNoMatchPolicyConfig: "ignore"

// DefaultEnableProvenanceInStatus is the default value for "enable-provenance-status".
#DefaultEnableProvenanceInStatus: true

// DefaultResultExtractionMethod is the default value for ResultExtractionMethod
#DefaultResultExtractionMethod: "termination-message"

// DefaultMaxResultSize is the default value in bytes for the size of a result
#DefaultMaxResultSize: 4096

// DefaultSetSecurityContext is the default value for "set-security-context"
#DefaultSetSecurityContext: false

// DefaultCoschedule is the default value for coschedule
#DefaultCoschedule:                    "workspaces"
_#disableAffinityAssistantKey:         "disable-affinity-assistant"
_#disableCredsInitKey:                 "disable-creds-init"
_#runningInEnvWithInjectedSidecarsKey: "running-in-environment-with-injected-sidecars"
_#awaitSidecarReadinessKey:            "await-sidecar-readiness"
_#requireGitSSHSecretKnownHostsKey:    "require-git-ssh-secret-known-hosts"
_#enableTektonOCIBundles:              "enable-tekton-oci-bundles"
_#enableAPIFields:                     "enable-api-fields"
_#sendCloudEventsForRuns:              "send-cloudevents-for-runs"
_#enforceNonfalsifiability:            "enforce-nonfalsifiability"
_#verificationNoMatchPolicy:           "trusted-resources-verification-no-match-policy"
_#enableProvenanceInStatus:            "enable-provenance-in-status"
_#resultExtractionMethod:              "results-from"
_#maxResultSize:                       "max-result-size"
_#setSecurityContextKey:               "set-security-context"
_#coscheduleKey:                       "coschedule"

// FeatureFlags holds the features configurations
// +k8s:deepcopy-gen=true
//
//nolint:musttag
#FeatureFlags: {
	DisableAffinityAssistant:         bool
	DisableCredsInit:                 bool
	RunningInEnvWithInjectedSidecars: bool
	RequireGitSSHSecretKnownHosts:    bool
	EnableTektonOCIBundles:           bool
	ScopeWhenExpressionsToTask:       bool
	EnableAPIFields:                  string
	SendCloudEventsForRuns:           bool
	AwaitSidecarReadiness:            bool
	EnforceNonfalsifiability:         string

	// VerificationNoMatchPolicy is the feature flag for "trusted-resources-verification-no-match-policy"
	// VerificationNoMatchPolicy can be set to "ignore", "warn" and "fail" values.
	// ignore: skip trusted resources verification when no matching verification policies found
	// warn: skip trusted resources verification when no matching verification policies found and log a warning
	// fail: fail the taskrun or pipelines run if no matching verification policies found
	VerificationNoMatchPolicy: string
	EnableProvenanceInStatus:  bool
	ResultExtractionMethod:    string
	MaxResultSize:             int
	SetSecurityContext:        bool
	Coschedule:                string
}
