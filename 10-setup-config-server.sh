#!/bin/bash

# These are the commands we've been using to run the full app on GKE
# Updated for TAP 1.4 on 30/01/2023

tanzu apps workload apply config-server \
--env "MANAGEMENT_WAVEFRONT_API-TOKEN=${WAVEFRONT_API_TOKEN}" \
--env "MANAGEMENT.WAVEFRONT.URI=https://vmwareprod.wavefront.com" \
--tail \
-f tap/workload-config-server.yaml

exit 0