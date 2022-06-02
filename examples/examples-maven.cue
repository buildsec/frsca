package frsca

import "github.com/buildsec/frsca/examples/pipelines/maven"

#ExampleMaven: e=#Example & {
	frsca: (maven & {"id": e.id, "sourceUrl": e.sourceUrl}).frsca
}
