#!/bin/bash

# Configure the files to serve from Spring Cloud config.
ytt -f tap/ops/config-server-git-config-templates/gateway.yaml -v namespace=$DEV_NAMESPACE > generated/config-server-config/gateway.yaml
ytt -f tap/ops/config-server-git-config-templates/order-service.yaml -v namespace=$DEV_NAMESPACE > generated/config-server-config/order-service.yaml
cp tap/ops/config-server-git-config-templates/product-service.yaml generated/config-server-config/
cp tap/ops/config-server-git-config-templates/shipping-service.yaml  generated/config-server-config

# Configure the Auth server files
ytt -f tap/ops/auth-server-template.yaml -v dev_namespace=$DEV_NAMESPACE -v issuer_uri=https://authserver-1-${DEV_NAMESPACE}.${DEV_ENVIRONMENT}.blah.cloud > generated/config-server-config/auth-server.yaml
ytt -f tap/auth-client-template.yaml -v gateway_url=https://gateway-${DEV_NAMESPACE}.${DEV_ENVIRONMENT}.blah.cloud > generated/config-server-config/auth-client.yaml

# Spin up the Auth server using the config above
kubectl apply -n $DEV_NAMESPACE -f generated/config-server-config/auth-server.yaml
kubectl apply -n $DEV_NAMESPACE -f generated/config-server-config/auth-client.yaml

# Create config used by the Config server
kubectl create secret generic configserver-secret \
--from-literal=git-url=https://github.com/benwilcock/tap-demo-config-files.git \
--from-literal=git-default-label=main \
--from-literal=username=benwilcock \
--from-literal=password=$TAP_DEMO_CONFIG_SVR_GITHUB_ACCESS_TOKEN \
-n $DEV_NAMESPACE

# Spin up the Config server container
kubectl apply -f tap/ops/config-server.yaml -n $DEV_NAMESPACE


# Deploy everything
tanzu apps workload apply product-service -f tap/workload-product-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply order-service -f tap/workload-order-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply shipping-service -f tap/workload-shipping-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply gateway -f tap/workload-gateway.yaml -y && \
tanzu apps workload apply frontend -f tap/workload-frontend.yaml -n $DEV_NAMESPACE -y

# Watch everything
watch tanzu apps workload list

# kubectl run mycurlpod --image=curlimages/curl -i --tty -- sh
# curl http://configserver/gateway/main
# kubectl delete pod mycurlpod


# Remove everything
#tanzu apps workload delete gateway -y
#tanzu apps workload delete frontend -y
#tanzu apps workload delete product-service -y
#tanzu apps workload delete shipping-service -y
#tanzu apps workload delete order-service -y