#!/usr/bin/env bash
set -euo pipefail

if [ -z "$TASKRUN" ]; then
      echo "TASKRUN is empty, please set it."
      exit 1
else
      echo "Starting validation for TaskRun $TASKRUN..."
fi

TASKRUN_UID=$(kubectl get taskrun "$TASKRUN" -o=json | jq -r '.metadata.uid')
TASKRUN_JSON="$TASKRUN.json"
kubectl get taskrun "$TASKRUN" -o=json | jq > "$TASKRUN_JSON"
jq \
  -r ".metadata.annotations[\"chains.tekton.dev/payload-taskrun-$TASKRUN_UID\"]" \
  "$TASKRUN_JSON"  \
  | base64 --decode > payload.json
jq \
  -r ".metadata.annotations[\"chains.tekton.dev/signature-taskrun-$TASKRUN_UID\"]" \
  "$TASKRUN_JSON" > signature.pub

echo "Verifying signature with cosign..."
cosign verify-blob -key cosign.pub -signature ./signature.pub ./payload.json
