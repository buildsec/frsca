kubectl apply -f admission-control-verify-image.yaml
kubectl apply -f gatekeeper-signing-checker-resources.yaml
kubectl apply -f gatekeeper-signing-checker.yaml
kubectl apply -f gatekeeper-constraints-template.yaml
sleep 5; # Needed because of eventual consistentcy between the template and the actual constraints
kubectl apply -f gatekeeper-constraints.yaml
kubectl apply -f kaniko-with-cosign.yaml
kubectl apply -f pipeline.yaml
kubectl create -f pipeline-run.yaml
