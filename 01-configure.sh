#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_MASTER_DOMAIN='blah.cloud'
export TAP_DEV_NAMESPACE='dev'
export TAP_DEV_ENVIRONMENT='tap-next'
export TAP_AUTH_SERVER_NAME='authserver-1'
export TAP_AUTH_SERVER_SECRET_NAME='authserver-1-auth-server'

echo "Creating the folder that holds the configuration"
rm -rf ./generated/config-server-config/
mkdir ./generated/config-server-config

echo "Creating & copying the Microservices configuration files that will be served from Spring Cloud Config Server."
envsubst < tap/ops/config-server-git-config-templates/gateway.yaml > generated/config-server-config/gateway.yaml
envsubst < tap/ops/config-server-git-config-templates/order-service.yaml > generated/config-server-config/order-service.yaml
cp tap/ops/config-server-git-config-templates/product-service.yaml generated/config-server-config/
cp tap/ops/config-server-git-config-templates/shipping-service.yaml  generated/config-server-config

echo "Creating & configuring the Authorization Server configuration"
envsubst < tap/ops/auth-server-template.yaml > generated/config-server-config/auth-server.yaml

echo "Creating & configuring the Authorization Client configuration"
envsubst < tap/auth-client-template.yaml > generated/config-server-config/auth-client.yaml

echo "Copying the files to the Local GitHub repo folder."
\cp generated/config-server-config/* ../tap-demo-config-files
# # ^^ Don't forget to push these config files to GitHub! ^^^

echo "Committing & pushing the  configuration files."
cd ../tap-demo-config-files
git commit -am 'generated fresh configuration'
git push origin main
cd ../spring-cloud-demo-tap

echo "Finished setting up the configuration"
exit 0