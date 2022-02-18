package ssf

import "encoding/yaml"

appliables: [ for x in applySets for y in x {y}]

// Things that can be used with 'kubectl apply ...'
applySets: [
	clusterPolicy,
	configMap,
	secret,
	serviceAccount,
	role,
	clusterRole,
	clusterRoleBinding,
	roleBinding,
	persistentVolumeClaim,
	pipeline,
	task,
]

creatables: [ for x in createSets for y in x {y}]

// Things that can be used with 'kubectl create ...'
createSets: [
	pipelineRun,
]

#Print: {
	X1=in: [...]
	out: print: {
		kind: "print"
		text: yaml.MarshalStream(X1)
	}
}

command: {
	apply: task:  (#Print & {in: appliables}).out
	create: task: (#Print & {in: creatables}).out
}
