region                              = "asia-south2"
project_id                          = "k8s-workshop-hari"
k8s_region                          = "asia-south2-a"
ip_range_pods                       = "pod-01-subnetwork-01-range"
ip_range_services                   = "svc-01-subnetwork-01-range"
subnetwork                          = "k8s-subnet-01"
network                             = "k8s-vpc"
compute_engine_service_account      = "terraform-sa@k8s-workshop-hari.iam.gserviceaccount.com"
cluster_service_account_name        = "gke-sa"
cluster_service_account_description = "gke-sa"
cloud_nat_name                      = "k8s-nat"
nat_router                          = "k8s-router"
env                                 = "dev"
min_ports_per_vm                    = "64"
zones                               = ["us-central1-a", "us-central1-b", "us-central1-c"]
zone                                = "us-central1-a"
regional                            = "false"
enable_vertical_pod_autoscaling     = "false"
cluster_name                        = "k8s"
default_max_pods_per_node           = "100"
enable_shielded_nodes               = "false"
network_name                        = "k8s-nw"
subnetwork_name                     = "k8s-sub"
subnetwork_range                    = "10.0.36.0/24"
pod_subnetwork_range                = "10.0.0.0/19"
svc_subnetwork_range                = "10.0.32.0/22"
name                                = "k8s"
