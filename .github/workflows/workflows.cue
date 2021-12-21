package workflows

import "json.schemastore.org/github"

workflows: [...{
	filename: string
	workflow: github.#Workflow
}]

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
