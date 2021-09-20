kubectl apply -f admission-control-verify-image.yaml
kubectl apply -f kaniko-with-cosign.yaml
kubectl apply -f pipeline.yaml
kubectl create -f pipeline-run.yaml
