variable "project" {
  type    = string
  default = "test-snwbr"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "env" {
  type = string
}

variable "credentials" {
  type    = string
  default = "../../terraform-sa.json"
}
