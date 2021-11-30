#!/bin/bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# This IBM tutorial looks great:
#   https://developer.ibm.com/devpractices/devops/tutorials/build-and-deploy-a-docker-image-on-kubernetes-using-tekton-pipelines/#create-a-task-to-clone-the-git-repository
kubectl apply -f "${GIT_ROOT}"/platform/vendor/tekton/catalog/main/task/git-clone/0.4/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/chains/main/examples/kaniko/kaniko.yaml
kubectl apply -f "$GIT_ROOT"/examples/ibm-tutorial/pipeline-pvc.yaml
kubectl apply -f "$GIT_ROOT"/examples/ibm-tutorial/pipeline-account.yaml
kubectl apply -f "$GIT_ROOT"/examples/ibm-tutorial/build-and-deploy-pipeline.yaml
kubectl create -f "$GIT_ROOT"/examples/ibm-tutorial/pipeline-run.yaml
tkn pipelinerun describe --last
