module "gke_nat" {
  source      = "../../modules/network/nat"
  project     = var.project
  region      = var.region
  name        = "${var.env}-gke-nat"
  vpc_network = module.vpc.vpc_id
}
