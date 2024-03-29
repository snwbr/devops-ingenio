#!/bin/bash

set -xe

ssh_key="${1}"
if [[ ! -f "$ssh_key" ]]; then
  ssh_key="$HOME/.ssh/id_rsa"
fi
if [[ ! -z "$KUBECONFIG" ]]; then
  kubectl_location=$KUBECONFIG
fi

zone="${ZONE}" # us-central1-c
region="${REGION}" # us-central1
local_port="${PORT}"

server=$(kubectl config view --minify | grep server | awk '{print $2}')
local_tunnel_url="https://kubernetes.default:${local_port}"
kubectl_location="$HOME/.kube/config" 
cluster_name=$(kubectl config view --minify | grep name | head -n 1 | awk '{print $2}' | awk -F_ '{print $NF}')
if [ -n "${zone}" ]
then
  server_ip=$(gcloud container clusters describe ${cluster_name} --format="value(endpoint)" --zone $zone)
else
  server_ip=$(gcloud container clusters describe ${cluster_name} --format="value(endpoint)" --region $region)
fi
node_info=$(gcloud compute instances list | grep $cluster_name | head -n 1)
tunnel_node=$(echo "${node_info}" | awk '{print $1}')
tunnel_zone=$(echo "${node_info}" | awk '{print $2}')

mv $kubectl_location "${kubectl_location}-bk"
sed -u "s~${server}~${local_tunnel_url}~g;w $kubectl_location" "${kubectl_location}-bk"

cat /etc/hosts | grep kubernetes.default || echo "127.0.0.1 kubernetes kubernetes.default" | sudo tee -a /etc/hosts

gcloud compute ssh \
--zone $tunnel_zone \
$tunnel_node \
--ssh-key-file=$ssh_key \
--tunnel-through-iap \
--ssh-flag="-L ${local_port}:${server_ip}:443 -f -N"
