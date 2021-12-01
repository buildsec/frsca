package ssf

// generate a PVC for each pipelineRun
persistentVolumeClaim: {
	for pr in pipelineRun {
		"\(pr.metadata.generateName)source-ws-pvc": spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]
