#!/usr/bin/env bash
set -euo pipefail

if [ -z "$TASKRUN" ]; then
      echo "TASKRUN is empty, please set it."
      exit 1
else
      echo "Starting validation for TaskRun $TASKRUN..."
fi

TASKRUN_UID=$(kubectl get taskrun "$TASKRUN" -o=json | jq -r '.metadata.uid')
kubectl get taskrun "$TASKRUN" -o=json | jq -r ".metadata.annotations[\"chains.tekton.dev/signature-taskrun-$TASKRUN_UID\"]" | base64 --decode > signature.pub

echo "Verifying signature with cosign..."
cosign verify-blob --key k8s://tekton-chains/signing-secrets --signature ./signature.pub ./signature.pub
