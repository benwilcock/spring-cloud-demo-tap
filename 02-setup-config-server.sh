#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'

# Create config settings required by the Spring Cloud Config Server
kubectl create secret generic configserver-secret \
--from-literal=git-url=https://github.com/benwilcock/tap-demo-config-files.git \
--from-literal=git-default-label=main \
--from-literal=username=benwilcock \
--from-literal=password=$TAP_DEMO_CONFIG_SVR_GITHUB_ACCESS_TOKEN \
-n $TAP_DEV_NAMESPACE

# Spin up the Config server in K8s serving the config above
kubectl apply -f tap/ops/config-server.yaml -n $DEV_NAMESPACE

