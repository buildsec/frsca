kubectl apply -f admission-control-verify-image.yaml
kubectl apply -f gatekeeper-signing-checker-resources.yaml
kubectl apply -f gatekeeper-signing-checker.yaml
kubectl apply -f gatekeeper-constraints-template.yaml
kubectl apply -f gatekeeper-constraints.yaml
kubectl apply -f kaniko-with-cosign.yaml
kubectl apply -f pipeline.yaml
kubectl create -f pipeline-run.yaml
