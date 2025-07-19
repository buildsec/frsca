module: "github.com/buildsec/frsca@v0"
language: {
	version: "v0.13.2"
}
deps: {
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.5.0"
		default: true
	}
	"cue.dev/x/kyverno@v0": {
		v:       "v0.4.0"
		default: true
	}
}
