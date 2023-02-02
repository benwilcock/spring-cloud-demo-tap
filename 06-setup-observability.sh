#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

echo "Configuring the observability secret & resource claim."
kubectl apply -f generated/observability.yaml -n $DEV_NAMESPACE
