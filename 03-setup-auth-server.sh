#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'

# Spin up the Auth server using the config created above
kubectl apply -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-server.yaml
kubectl apply -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-client.yaml

