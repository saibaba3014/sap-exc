# create VPC
resource "google_compute_network" "vpc" {
  name                    = "k8s-vpc-2"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "k8s-subnet-2"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"
}


# Create GKE cluster with 2 nodes in our custom VPC/Subnet
resource "google_container_cluster" "primary" {
  name                     = "k8s-cluster"
  location                 = var.k8s_region
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true                ## create the smallest possible default node pool and immediately delete it.
  initial_node_count       = 1

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes   = true
    master_ipv4_cidr_block = "10.13.0.0/28"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.11.0.0/21"
    services_ipv4_cidr_block = "10.12.0.0/21"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.7/32"
      display_name = "net1"
    }

  }
}

# Create managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.k8s_region
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "dev"
    }

    machine_type = "n1-standard-1"
    preemptible  = true
    #service_account = google_service_account.mysa.email

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}



## Create jump host . We will allow this jump host to access GKE cluster. the ip of this jump host is already authorized to allowin the GKE cluster

resource "google_compute_address" "my_internal_ip_addr" {
  project      = var.project_id
  address_type = "INTERNAL"
  region       = var.region
  subnetwork   = google_compute_subnetwork.subnet.name
  name         = "k8s-ip-1"
  address      = "10.0.0.7"
  description  = "An internal IP address for my jump host"
}

resource "google_compute_instance" "default" {
  project      = var.project_id
  zone         = var.k8s_region
  name         = "jump-host-1"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip         = google_compute_address.my_internal_ip_addr.address
  }
  metadata = {
    ssh-keys = "rk8s:${file("bastion.txt")}"
  }
}


## Creare Firewall to access jump hist via iap


resource "google_compute_firewall" "rules" {
  project = var.project_id
  name    = "allow-ssh-1"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}



## Create IAP SSH permissions for your test instance

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:terraform-sa@k8s-workshop-hari.iam.gserviceaccount.com"
}

# create cloud router for nat gateway
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "nat-router-1"
  network = google_compute_network.vpc.name
  region  = var.region
}

## Create Nat Gateway with module

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id =  var.project_id
  region     = var.region
  router     = google_compute_router.router.name
  name       = "nat-config-1"

}