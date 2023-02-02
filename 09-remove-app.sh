#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'

echo "Removing all the Tanzu workloads"
tanzu apps workload delete gateway -y
tanzu apps workload delete frontend -y
tanzu apps workload delete product-service
tanzu apps workload delete shipping-service -y
tanzu apps workload delete order-service -y

echo "Removing all the manually created resources from Kubernetes"
kubectl delete secret configserver-secret -n $TAP_DEV_NAMESPACE
kubectl delete -f tap/ops/config-server.yaml -n $TAP_DEV_NAMESPACE
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-server.yaml
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/config-server-config/auth-client.yaml
kubectl delete -n $TAP_DEV_NAMESPACE -f generated/observability.yaml

echo "The workloads, config server, observability, and authorization server have been removed."
exit 0