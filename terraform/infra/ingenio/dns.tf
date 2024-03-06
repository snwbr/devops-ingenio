locals {
  snwbr_net_records = [
    {
      type      = "A"
      dns_entry = "${var.env != "dev" ? "" : "${var.env}."}snwbr.net."
      data      = [google_compute_global_address.address.address]
      ttl       = 300
    },
    {
      type      = "CNAME"
      dns_entry = "${var.env != "dev" ? "" : "${var.env}."}ingress.snwbr.net."
      data      = ["${var.env != "dev" ? "" : "${var.env}."}snwbr.net."]
      ttl       = 300
    }
  ]
}

resource "google_dns_managed_zone" "snwbr-net" {
  name        = var.zone_name
  dns_name    = var.domain
  description = "DNS zone for domain: ${var.domain}. Managed by Terraform"
  labels      = var.dns_labels
  dnssec_config {
    kind          = "dns#managedZoneDnsSecConfig"
    non_existence = "nsec3"
    state         = "on"

    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
      kind       = "dns#dnsKeySpec"
    }
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 1024
      key_type   = "zoneSigning"
      kind       = "dns#dnsKeySpec"
    }
  }
}

module "snwbr_net_records" {
  source  = "../../modules/dns_entry"
  project = var.project
  zone    = google_dns_managed_zone.snwbr-net.name
  data    = local.snwbr_net_records
}
