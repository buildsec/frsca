// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go knative.dev/pkg/apis/duck/v1

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	batchv1 "k8s.io/api/batch/v1"
)

// CronJob is a wrapper around CronJob resource, which supports our interfaces
// for webhooks
#CronJob: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta   @go(ObjectMeta)
	spec?:     batchv1.#CronJobSpec @go(Spec)
}

// CronJobList is a list of CronJob resources
#CronJobList: {
	metav1.#TypeMeta
	metadata: metav1.#ListMeta @go(ListMeta)
	items: [...#CronJob] @go(Items,[]CronJob)
}
