package workflows

import "json.schemastore.org/github"

workflows: [...{
	filename: string
	workflow: github.#Workflow
}]

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  ((github.#Workflow & {}).jobs & {x: _}).x
_#step: ((_#job & {steps:                   _}).steps & [_])[0]

workflows: [
	{
		filename: "docs.yaml"
		workflow: docs
	}, {
		filename: "install-ssf.yaml"
		workflow: CI
	},
]

_#baseWorkflow: github.#Workflow & {
	on: {
		pull_request: types: [
			"opened",
			"synchronize",
			"reopened",
		]
		push: branches: [ "main"]
	}
	jobs: [string]: "runs-on": "ubuntu-latest"
}

_#checkoutCode: _#step & {
	name: "Checkout code"
	uses: "actions/checkout@v2"
}
