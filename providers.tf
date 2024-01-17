
provider "random" {
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gcloud"
      args        = ["auth", "application-default", "print-access-token"]
      env = {
        GOOGLE_APPLICATION_CREDENTIALS = "k8s.json"
      }
    }
  }
}
