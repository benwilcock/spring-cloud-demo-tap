#!/bin/bash

# Setup the files to serve from Spring Cloud config.
ytt -f tap/ops/config-server-git-config-templates/gateway.yaml -v namespace=$DEV_NAMESPACE > generated/config-server-config/gateway.yaml
ytt -f tap/ops/config-server-git-config-templates/order-service.yaml -v namespace=$DEV_NAMESPACE > generated/config-server-config/order-service.yaml
cp tap/ops/config-server-git-config-templates/product-service.yaml generated/config-server-config/
cp tap/ops/config-server-git-config-templates/shipping-service.yaml  generated/config-server-config

# Setup the Auth server
ytt -f tap/ops/auth-server-template.yaml -v dev_namespace=$DEV_NAMESPACE -v issuer_uri=http://authserver-1-${DEV_NAMESPACE}.tap.blah.cloud | kubectl apply -f -

kubectl create secret generic configserver-secret \
--from-literal=git-url=https://github.com/benwilcock/tap-demo-config-files.git \
--from-literal=username=benwilcock \
--from-literal=password=$TAP_DEMO_CONFIG_SVR_GITHUB_ACCESS_TOKEN \
-n $DEV_NAMESPACE

kubectl apply -f tap/ops/config-server.yaml -n $DEV_NAMESPACE
ytt -f tap/auth-client-template.yaml -v gateway_url=http://gateway-${DEV_NAMESPACE}.tap.blah.cloud | kubectl apply -n $DEV_NAMESPACE -f -

# Remove everything
# tanzu apps workload delete gateway -y
# tansu apps workload delete frontend -y
# tanzu apps workload delete product-service -y
# tanzu apps workload delete shipping-service -y
# tanzu apps workload delete order-service -y

# Deploy everything
# tanzu apps workload apply product-service -f tap/workload-product-service.yaml -n $DEV_NAMESPACE -y
# tanzu apps workload apply order-service -f tap/workload-order-service.yaml -n $DEV_NAMESPACE -y
# tanzu apps workload apply shipping-service -f tap/workload-shipping-service.yaml -n $DEV_NAMESPACE -y
# tanzu apps workload apply gateway -f tap/workload-gateway.yaml -y
# tanzu apps workload apply frontend -f tap/workload-frontend.yaml -n $DEV_NAMESPACE -y

# watch tanzu apps workload list

# kubectl run mycurlpod --image=curlimages/curl -i --tty -- sh
# curl http://configserver/gateway/main
# kubectl delete pod mycurlpod