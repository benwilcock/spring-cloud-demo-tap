#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_MASTER_DOMAIN='blah.cloud'
export TAP_DEV_NAMESPACE='dev'
export TAP_DEV_ENVIRONMENT='tap-next'
export TAP_AUTH_SERVER_NAME='authserver-1'
export TAP_AUTH_SERVER_SECRET_NAME='authserver-1-auth-server'

# Create & copy the Microservices configuration files that will be served from Spring Cloud Config Server.
mkdir generated/config-server-config
envsubst < tap/ops/config-server-git-config-templates/gateway.yaml > generated/config-server-config/gateway.yaml
envsubst < tap/ops/config-server-git-config-templates/order-service.yaml > generated/config-server-config/order-service.yaml
cp tap/ops/config-server-git-config-templates/product-service.yaml generated/config-server-config/
cp tap/ops/config-server-git-config-templates/shipping-service.yaml  generated/config-server-config

# Create & configure the Authorization Server configuration files
envsubst < tap/ops/auth-server-template.yaml > generated/config-server-config/auth-server.yaml

# Create & configure the Authorization Client configuration files
envsubst < tap/auth-client-template.yaml > generated/config-server-config/auth-client.yaml

# vv Don't forget to push these config files to GitHub! vvv
\cp generated/config-server-config/* ../tap-demo-config-files
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

# Set the Angular app config with the right endpoint
# sed -i '' "s/https:\/\/authserver-1-dev-space.tap.blah.cloud/https:\/\/authserver-1-${DEV_NAMESPACE}.${DEV_ENVIRONMENT}.${MASTER_DOMAIN}/g" frontend/src/environments/environment.prod.ts

# In frontend/src/environments/environment.prod.ts
# check the 'issuer' setting has the correct URL as per the example below.

# export const environment = {
#   production: true,
#   baseHref: '/frontend/',
#   authConfig: {
#     requireHttps: true,
#     issuer: 'https://authserver-1-dev.tap-next.blah.cloud',
#     clientId: 'dev_client-registration'
#   },
#   endpoints: {
#     orders: window.location.origin + '/services/order-service/api/v1/orders',
#     products: window.location.origin +  '/services/product-service/api/v1/products'
#   }
# };

# Deploy the application workloads
tanzu apps workload apply product-service -f tap/workload-product-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply order-service -f tap/workload-order-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply shipping-service -f tap/workload-shipping-service.yaml -n $DEV_NAMESPACE -y && \
tanzu apps workload apply gateway -f tap/workload-gateway.yaml -y && \
tanzu apps workload apply frontend -f tap/workload-frontend.yaml -n $DEV_NAMESPACE -y

# Watch everything deploy
watch tanzu apps workload list

# Generate Backstage TechDocs
# See https://backstage.io/docs/features/techdocs/using-cloud-storage#configuring-aws-s3-bucket-with-techdocs 

export AWS_ACCESS_KEY_ID=<aws-access-id>
export AWS_SECRET_ACCESS_KEY=<aws-secret-access-key>
export AWS_REGION=<aws-region>
export AWS_BUCKET_NAME=<aws-bucket-name>

cd tap/catalog 
npx @techdocs/cli generate --source-dir . --output-dir ./site
# array=( Component/gateway Component/order-service Component/product-service Component/frontend Component/shipping-service Resource/authserver-1 Resource/configserver Resource/gemfire-1 Resource/observability Resource/postgres-1 Resource/rmq-1 Location/sc-architecture-location System/sc-architecture-system)
# for i in "${array[@]}"
# do
# npx @techdocs/cli publish --publisher-type awsS3 --storage-name $AWS_BUCKET_NAME --entity default/$i --directory ./site
# done
cd ../..

# Troubleshooting using a Curl POD
# kubectl run mycurlpod --image=curlimages/curl -i --tty -- sh
# curl http://configserver/gateway/main
# kubectl delete pod mycurlpod

# Remove all the workloads
tanzu apps workload delete gateway -y && \
tanzu apps workload delete frontend -y && \
tanzu apps workload delete product-service -y && \
tanzu apps workload delete shipping-service -y && \
tanzu apps workload delete order-service -y