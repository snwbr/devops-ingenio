resource "google_compute_address" "address" {
  project      = var.project
  name         = "${var.env}-traefik-lb"
  address_type = "EXTERNAL"
  region       = "us-central1"
}
resource "google_compute_global_address" "address" {
  project      = var.project
  name         = "${var.env}-ingress-lb"
  address_type = "EXTERNAL"
}