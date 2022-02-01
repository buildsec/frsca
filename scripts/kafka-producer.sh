#!/bin/bash
set -euo pipefail

# Define variables.
POD_NAME=kafka-producer

# Look for an existing producer.
SELECTED=$(kubectl get pods --selector=run=$POD_NAME --output=jsonpath={.items..metadata.name})

# And create it only if needed,
if [ -z "$SELECTED" ]; then
  kubectl run $POD_NAME \
    --restart='Never' \
    --image docker.io/bitnami/kafka:3.1.0-debian-10-r0 \
    --namespace default \
    --command -- sleep infinity
  sleep 5
fi


# Read the events.
kubectl exec $POD_NAME \
  --namespace default -- kafka-console-producer.sh \
    --broker-list kafka-0.kafka-headless.default.svc.cluster.local:9092 \
    --topic test
