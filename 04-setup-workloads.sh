#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'

# Deploy the application workloads
tanzu apps workload apply config-server --env "MANAGEMENT_WAVEFRONT_API-TOKEN=${WAVEFRONT_API_TOKEN}" --env "MANAGEMENT.WAVEFRONT.URI=https://vmwareprod.wavefront.com" -f tap/workload-config-server.yaml -n $TAP_DEV_NAMESPACE
tanzu apps workload apply gateway -f tap/workload-gateway.yaml -n $TAP_DEV_NAMESPACE
tanzu apps workload apply product-service -f tap/workload-product-service.yaml -n $TAP_DEV_NAMESPACE
tanzu apps workload apply order-service -f tap/workload-order-service.yaml -n $TAP_DEV_NAMESPACE
tanzu apps workload apply shipping-service -f tap/workload-shipping-service.yaml -n $TAP_DEV_NAMESPACE
tanzu apps workload apply frontend -f tap/workload-frontend.yaml -n $TAP_DEV_NAMESPACE

# Watch everything deploy
watch tanzu apps workload list

exit 0