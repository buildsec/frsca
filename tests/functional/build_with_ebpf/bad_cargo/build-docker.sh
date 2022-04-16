#!/bin/bash

NAME=$1
IMAGE=ghcr.io/mlieberman85/rust:latest
docker build . -f "$NAME.Dockerfile" -t $IMAGE
docker push $IMAGE
