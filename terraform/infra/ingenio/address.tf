resource "google_compute_global_address" "address" {
  project      = var.project
  name         = "${var.env}-ingress-lb"
  address_type = "EXTERNAL"
}