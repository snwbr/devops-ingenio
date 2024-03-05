resource "google_compute_address" "address" {
  project      = var.project
  name         = "${var.env}-traefik-lb"
  address_type = "EXTERNAL"
  region       = "us-central1"
}