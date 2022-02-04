package ssf

import (
	"ssf.org/example/go"
)

_image: {
	name: "go-build-test-ssf"
}

(go.GenPipeline & {in: go.#Pipeline & {
	sourceUrl: "https://github.com/chmouel/go-rest-api-test"
	buildName: "pipeline-go-test"
	runPrefix: "pipelinerun-go-test-"
	image: _APP_IMAGE
}}).out
