package workflows

docs: _#baseWorkflow & {
	name: "docs"
	on: {
		pull_request: {
			paths: [
				".github/**",
				"docs/**",
			]
		}
	}

	jobs: docs: steps: [{
		uses: "actions/checkout@v2"
	}, {
		name: "build"
		uses: "shalzz/zola-deploy-action@v0.14.1"
		env: {
			BUILD_DIR:  "docs"
			BUILD_ONLY: true
		}
	}, {
		name: "Deploy"
		if:   "github.ref == 'refs/heads/main'"
		uses: "peaceiris/actions-gh-pages@v3"
		with: {
			github_token: "${{ secrets.GITHUB_TOKEN }}"
			publish_dir:  "./docs/public"
		}
	}]
}
