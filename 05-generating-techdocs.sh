#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

export TAP_DEV_NAMESPACE='dev'
export AWS_ACCESS_KEY_ID=<aws-access-id>
export AWS_SECRET_ACCESS_KEY=<aws-secret-access-key>
export AWS_REGION=<aws-region>
export AWS_BUCKET_NAME=<aws-bucket-name>

# Generate Backstage TechDocs
# See https://backstage.io/docs/features/techdocs/using-cloud-storage#configuring-aws-s3-bucket-with-techdocs 

cd tap/catalog 
npx @techdocs/cli generate --source-dir . --output-dir ./site
array=( Component/gateway Component/order-service Component/product-service Component/frontend Component/shipping-service Resource/authserver-1 Resource/configserver Resource/gemfire-1 Resource/observability Resource/postgres-1 Resource/rmq-1 Location/sc-architecture-location System/sc-architecture-system)
for i in "${array[@]}"
do
npx @techdocs/cli publish --publisher-type awsS3 --storage-name $AWS_BUCKET_NAME --entity default/$i --directory ./site
done
cd ../..