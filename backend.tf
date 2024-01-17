
terraform {
  required_version = ">= 1.5.7"
  backend "gcs" {
    bucket = "tfstate-k8s-hari"
    prefix = "terraform/state/vm/bastion"
    credentials = "k8s.json"
  }
}
