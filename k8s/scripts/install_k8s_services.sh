#!/bin/bash
set -x

env=$1
if [[ -z $env ]]; then
  echo "Provide an environment for the stack installation. Exiting..."
  exit 1
fi

common="common"
services="services"
kustomize="./kustomize"
if [[ ! -f "kustomize" ]]; then
  if [[ ! -f "../kustomize" ]]; then
    echo "Unable to identify K8s folders. Run this script from k8s or from k8s/scripts folders."
    exit 1
  fi
  common="../$common"
  services="../$services"
  kustomize="../$kustomize"
fi
$kustomize build $common | kubectl apply -f -

$kustomize build $services | kubectl apply -f -

## waiting as sometimes cert-manager can take a while to register the CRDs
sleep 3

helm upgrade --install --set env=$env --values=../charts/hello-world/values.yaml hello-world ../charts/hello-world
