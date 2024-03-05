#!/bin/bash
ENV="${1}"
ACTION="${2}"

terraform init -var-file=tfvars/$ENV.tfvars -backend-config="./backends/${ENV}.tf" -reconfigure
terraform $ACTION -var-file=tfvars/$ENV.tfvars "${@:3}"
