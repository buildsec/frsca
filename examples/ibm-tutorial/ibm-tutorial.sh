#!/bin/bash
set -euo pipefail

# This IBM tutorial looks great:
#   https://developer.ibm.com/devpractices/devops/tutorials/build-and-deploy-a-docker-image-on-kubernetes-using-tekton-pipelines/#create-a-task-to-clone-the-git-repository
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml
kubectl apply -f tekton-resources/ibm-tutorial/pipeline-pvc.yaml
kubectl apply -f tekton-resources/ibm-tutorial/pipeline-account.yaml
kubectl apply -f tekton-resources/ibm-tutorial/build-and-deploy-pipeline.yaml
kubectl create -f tekton-resources/ibm-tutorial/pipeline-run.yaml
tkn pipelinerun describe --last
