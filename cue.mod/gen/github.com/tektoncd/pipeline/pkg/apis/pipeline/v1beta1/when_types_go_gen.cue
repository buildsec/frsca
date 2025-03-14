// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1

package v1beta1

import "k8s.io/apimachinery/pkg/selection"

// WhenExpression allows a PipelineTask to declare expressions to be evaluated before the Task is run
// to determine whether the Task should be executed or skipped
#WhenExpression: {
	// Input is the string for guard checking which can be a static input or an output from a parent Task
	input?: string @go(Input)

	// Operator that represents an Input's relationship to the values
	operator?: selection.#Operator @go(Operator)

	// Values is an array of strings, which is compared against the input, for guard checking
	// It must be non-empty
	// +listType=atomic
	values?: [...string] @go(Values,[]string)

	// CEL is a string of Common Language Expression, which can be used to conditionally execute
	// the task based on the result of the expression evaluation
	// More info about CEL syntax: https://github.com/google/cel-spec/blob/master/doc/langdef.md
	// +optional
	cel?: string @go(CEL)
}

// WhenExpressions are used to specify whether a Task should be executed or skipped
// All of them need to evaluate to True for a guarded Task to be executed.
#WhenExpressions: [...#WhenExpression]

#StepWhenExpressions: #WhenExpressions
