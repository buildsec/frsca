## Admission Controller and key validation

* Generate your own keys, and replace the public keys in admission-control-verify-image.yaml for gcr.io and ttl.sh

`kubectl apply -f admission_control_verify_image.yaml`

## Kaniko builder with cosign

`kubectl apply -f kaniko-with-cosign.yaml`

## Pipeline

`kubectl apply -f pipeline.yaml`

## Pipeline Run
Note: This uses create vs apply due to name generation

`kubectl create -f pipeline-run.yaml`
