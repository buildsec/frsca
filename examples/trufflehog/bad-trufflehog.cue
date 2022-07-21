package frsca

frsca: pipelineRun: "bad-hog-pipelinerun-": spec: {
	pipelineSpec: {
		description: """
			trufflehog-find-creds takes a git repository and uses
			the open source tool called trufflehog to find keys that were accidentally
			committed to the git repo.

			"""
		tasks: [{
			name: "trufflehog"
			taskSpec: {
				results: [{
					name:        "OUTPUT"
					description: "Exit Code from trufflehog"
				}]
				steps: [{
					name:  "run-trufflehog"
					image: "madhuakula/k8s-goat-build-code"
					script: """
						#!/bin/sh
						trufflehog . > output.txt
						cat output.txt | tee \"$(results.OUTPUT.path)\"
						"""
				}]
			}
		}]
	}
}
