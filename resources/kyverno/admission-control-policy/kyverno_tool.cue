package kyverno

import "encoding/json"

all: [ for x in [ImageClusterPolicy, AttestationClusterPolicy, configMap] for y in x {y}]

command: {
	apply: task: print: {
		kind: "print"
		text: json.MarshalStream(all)
	}
}
