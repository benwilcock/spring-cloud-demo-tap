#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export MASTER_DOMAIN=<domain name> # e.g. "blah.cloud"
export DEV_NAMESPACE=<dev-namespace> # e.g. "dev"
export DEV_ENVIRONMENT=<dev-environment> # e.g. "tap-next"
export AUTH_SERVER_SECRET_NAME=<auth-server-secret-name> # e.g. "authserver-1-auth-server"

# Create & copy the Microservices config files to serve from Spring Cloud config.
ytt -f tap/ops/config-server-git-config-templates/gateway.yaml -v namespace=${DEV_NAMESPACE} > generated/config-server-config/gateway.yaml
ytt -f tap/ops/config-server-git-config-templates/order-service.yaml -v namespace=${DEV_NAMESPACE} > generated/config-server-config/order-service.yaml
cp tap/ops/config-server-git-config-templates/product-service.yaml generated/config-server-config/
cp tap/ops/config-server-git-config-templates/shipping-service.yaml  generated/config-server-config

# Create & configure the Auth Server configuration files
ytt -f tap/ops/auth-server-template.yaml -v dev_namespace=$DEV_NAMESPACE -v issuer_uri=https://authserver-1-${DEV_NAMESPACE}.${DEV_ENVIRONMENT}.${MASTER_DOMAIN} -v tls_secret_name=${AUTH_SERVER_SECRET_NAME} > generated/config-server-config/auth-server.yaml

# Create & configure the Auth Client configuration files
ytt -f tap/auth-client-template.yaml -v gateway_url=https://gateway-${DEV_NAMESPACE}.${DEV_ENVIRONMENT}.${MASTER_DOMAIN} > generated/config-server-config/auth-client.yaml

# vv Don't forget to push these config files to GitHub! vvv
cp generated/config-server-config ../tap-demo-config-files
# ^^ Don't forget to push these config files to GitHub! ^^^

# Create config settings required by the Spring Cloud Config Server
kubectl create secret generic configserver-secret \
--from-literal=git-url=https://github.com/benwilcock/tap-demo-config-files.git \
--from-literal=git-default-label=main \
--from-literal=username=benwilcock \
--from-literal=password=$TAP_DEMO_CONFIG_SVR_GITHUB_ACCESS_TOKEN \
-n $DEV_NAMESPACE

# Spin up the Config server in K8s serving the config above
kubectl apply -f tap/ops/config-server.yaml -n $DEV_NAMESPACE

# Spin up the Auth server using the config created above
kubectl apply -n $DEV_NAMESPACE -f generated/config-server-config/auth-server.yaml
kubectl apply -n $DEV_NAMESPACE -f generated/config-server-config/auth-client.yaml

# Deploy the application workloads
tanzu apps workload apply product-service -f tap/workload-product-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply order-service -f tap/workload-order-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply shipping-service -f tap/workload-shipping-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply gateway -f tap/workload-gateway.yaml -y && \
tanzu apps workload apply frontend -f tap/workload-frontend.yaml -n $DEV_NAMESPACE -y

# Watch everything
watch tanzu apps workload list

# Troubleshooting using a Curl POD
# kubectl run mycurlpod --image=curlimages/curl -i --tty -- sh
# curl http://configserver/gateway/main
# kubectl delete pod mycurlpod


# Remove all the workloads
#tanzu apps workload delete gateway -y
#tanzu apps workload delete frontend -y
#tanzu apps workload delete product-service -y
#tanzu apps workload delete shipping-service -y
#tanzu apps workload delete order-service -y