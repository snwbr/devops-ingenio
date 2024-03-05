locals {
  whitelisted_ranges = ["35.235.240.0/20"]
}

data "google_iam_policy" "iap_tunnel_resource_accessor" {
  binding {
    role    = "roles/iap.tunnelResourceAccessor"
    members = var.iap_members
  }
}

// Creating this rule to allow IAP TCP forwarding, basically to use SSH through IAP to connect to nodes with private IP.
// This range specified in 'local.whitelisted_ranges' contains all IP addresses that IAP uses for TCP forwarding.
// https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "gke_ssh_rules" {
  project = var.project
  name    = "${var.env}-gke-allow-ssh"
  network = module.vpc.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = local.whitelisted_ranges
}

resource "google_iap_tunnel_iam_policy" "policy" {
  project     = var.project
  policy_data = data.google_iam_policy.iap_tunnel_resource_accessor.policy_data
}
