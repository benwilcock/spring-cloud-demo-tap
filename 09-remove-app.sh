#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'
export DRY_RUN='server' # setting 'none' will cause the command to actually run for realz!

echo "Removing all the Tanzu workloads"
tanzu apps workload delete gateway -y
tanzu apps workload delete frontend -y
tanzu apps workload delete product-service -y
tanzu apps workload delete shipping-service -y
tanzu apps workload delete order-service -y
tanzu apps workload delete config-server -y

echo "Removing all the manually created resources from Kubernetes"
# kubectl delete -n $TAP_DEV_NAMESPACE -f tap/ops/config-server.yaml --dry-run=$DRY_RUN
# kubectl delete secret configserver-secret -n $TAP_DEV_NAMESPACE --dry-run=$DRY_RUN
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-server.yaml --dry-run=$DRY_RUN
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-client.yaml --dry-run=$DRY_RUN
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/observability.yaml --dry-run=$DRY_RUN

echo "The workloads, config server, observability, and authorization server have been removed."
exit 0