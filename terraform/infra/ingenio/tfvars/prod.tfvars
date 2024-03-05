## Project Variables
project = "test-snwbr"
region  = "us-central1"
env     = "prod"

## Service accounts
sa_gke_create = true

## Networking
gke_master_ipv4_cidr_block = "10.10.0.0/28"
gke_cidr_range             = "10.20.0.0/16"

gke_secondary_ip_range = [
  {
    secondary_ip_range_name = "pod"
    secondary_ip_range_cidr = "10.40.0.0/16"
  },
  {
    secondary_ip_range_name = "svc"
    secondary_ip_range_cidr = "10.60.0.0/16"
  }
]

## GKE
gke_create                 = true
zone                       = "us-central1-c"
cluster_initial_node_count = 2
cluster_name               = "ingenio-challenge"
gke_version                = "1.27.8-gke.1067004"
machine_type               = "e2-small"
gke_tags                   = []

## IAP
iap_members = [
  "user:dperezr1290@gmail.com",
  "serviceAccount:terraform-sa@test-snwbr.iam.gserviceaccount.com"
]

## DNS
zone_name = "snwbr-net"
domain    = "snwbr.net."
dns_labels = {
  tfmanaged = "true"
}