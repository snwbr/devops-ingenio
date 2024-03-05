#!/bin/bash
set -x

env=$1
if [[ -z $env ]]; then
  echo "Provide an environment for the stack installation. Exiting..."
  exit 1
fi

common="common"
services="services"
apps="apps/${env}"
kustomize="./kustomize"
if [[ ! -f "kustomize" ]]; then
  if [[ ! -f "../kustomize" ]]; then
    echo "Unable to identify K8s folders. Run this script from k8s or from k8s/scripts folders."
    exit 1
  fi
  common="../$common"
  services="../$services"
  apps="../$apps"
  kustomize="../$kustomize"
fi
$kustomize build $common | kubectl apply -f -
helm upgrade --install --version v23.2.0 \
    --namespace=services \
    --values=$services/traefik/helm_values.yaml \
    traefik traefik/traefik
sleep 10

kubectl ns services
$kustomize build $services | kubectl apply -f -
sleep 90
kubeseal -f $services/traefik/base/ignore.basic-auth-secret.yaml -oyaml > $services/traefik/base/basic-auth-secret.yaml

## rerunning services as sometimes cert-manager can take a while to register the CRDs
$kustomize build $services | kubectl apply -f -
$kustomize build $apps | kubectl apply -f -

#kubeseal -f services/traefik/base/ignore.basic-auth-secret.yaml -oyaml > services/traefik/base/basic-auth-secret.yaml
