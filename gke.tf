module "service_account" {
  source      = "./modules/gke-service-account"
  name        = var.cluster_service_account_name
  project     = var.project_id
  description = var.cluster_service_account_description
}

# create VPC
resource "google_compute_network" "vpc" {
  name                    = var.network
  auto_create_subnetworks = false

}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnetwork_range
}



# Create GKE cluster with 2 nodes in our custom VPC/Subnet
resource "google_container_cluster" "primary" {
  name                     = var.name
  location                 = var.k8s_region
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true ## create the smallest possible default node pool and immediately delete it.
  initial_node_count       = 1

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pod_subnetwork_range
    services_ipv4_cidr_block = var.svc_subnetwork_range
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.7/32"
      display_name = "net1"
    }

  }
  depends_on = [module.service_account]
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
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
 depends_on = [module.service_account]
}



## Create bastion host .

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
  name         = "bastion-host-1"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = google_compute_address.my_internal_ip_addr.address
  }
  metadata = {
    ssh-keys = "rk8s:${file("bastion.txt")}"
  }
  depends_on = [module.service_account]
}


## Creare Firewall to access bastion host via iap


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


# nodes to master firewall
resource "google_compute_firewall" "default" {
  name    = "nodetomaster-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
  
  source_service_accounts = [module.service_account.email]
  depends_on = [module.service_account]
}

## Create IAP SSH permissions for your test instance

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = module.service_account.email
}

# create cloud router for nat gateway
resource "google_compute_router" "router" {
  name    = var.nat_router_name
  project = var.project_id
  network = google_compute_network.vpc.name
  region  = var.region
  depends_on = [google_compute_network.vpc]
}

## Create Nat Gateway with module

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  name       = var.cloud_nat_name
  project_id = var.project_id
  region     = var.region
  router     = google_compute_router.router.name
  depends_on = [google_compute_router.router]
}
