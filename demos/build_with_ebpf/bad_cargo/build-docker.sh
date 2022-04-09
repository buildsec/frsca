#!/bin/bash

NAME=$1
IMAGE=buildsec/rust:latest
docker build . -f "$NAME.Dockerfile" -t $IMAGE
