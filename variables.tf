 variable "region" {
  type    = string
  default = "us-central1"
}
variable "k8s_region" {
  type    = string
  default = "us-central1-a"
}

variable "project_id" {
  type    = string
  default = "k8s-project-hari"
}
variable "name" {
  type    = string
}

variable "network_name" {
  description = "the name of the network"
  type    = string
}

variable "subnetwork_name" {
  description = "name for the subnetwork"
  type        = string
}

variable "subnetwork_range" {
  description = "CIDR for subnetwork nodes"
  type        = string
}

variable "pod_subnetwork_range" {
  description = "CIDR for pod subnetwork nodes"
  type        = string
}

variable "svc_subnetwork_range" {
  description = "CIDR for pod subnetwork nodes"
  type        = string
}

variable "subnetwork" {
   type = string
   description = "CIDR for subnetwor"
}


variable "cluster_name_suffix" {
  description = "A suffix to append to the default cluster name"
  default     = ""
}


variable "network" {
  description = "The VPC network to host the cluster in"
}
variable "cloud_nat_name" {
  description = "Defaults to 'cloud-nat-RANDOM_SUFFIX'. Changing this forces a new NAT to be created."
  default     = "rsc-prod-nat"
}

variable "nat_ips" {
  description = "List of self_links of external IPs. Changing this forces a new NAT to be created."
  type        = list(string)
  default     = []
}

variable "nat_router" {
  description = "The name of the router in which this NAT will be configured. Changing this forces a new NAT to be created."
  default     = ""
}

variable "router_asn" {
  description = "Router ASN, only if router is not passed in and is created by the module."
  default     = "64514"
}


variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
}

variable "compute_engine_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_service_account_name"{

}
variable "cluster_service_account_description" {

}

variable "env" {
  description = "the name of the network"
  type        = string
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Defaults to ALL_SUBNETWORKS_ALL_IP_RANGES. How NAT should be configured per Subnetwork. Valid values include: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS. Changing this forces a new NAT to be created."
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
variable "firewall_source_range" {
  default = ["0.0.0.0/0"]
}


variable "tcp_established_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set. Changing this forces a new NAT to be created."
  default     = "1200"
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  default     = "30"
}

variable "udp_idle_timeout_sec" {
  description = "Timeout (in seconds) for UDP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  default     = "30"
}

variable "icmp_idle_timeout_sec" {
  description = "Timeout (in seconds) for ICMP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  default     = "30"
}
variable "min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from this NAT config. Defaults to 64 if not set. Changing this forces a new NAT to be created."
}


variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
}
variable "cluster_autoscaling" {
  type = object({
    enabled       = bool
    min_cpu_cores = number
    max_cpu_cores = number
    min_memory_gb = number
    max_memory_gb = number
    gpu_resources = list(object({ resource_type = string, minimum = number, maximum = number }))
  })
  default = {
    enabled       = false
    max_cpu_cores = 20
    min_cpu_cores = 10
    max_memory_gb = 40
    min_memory_gb = 20
    gpu_resources = []
  }
  description = "Cluster autoscaling configuration. See [more details](https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.locations.clusters#clusterautoscaling)"
}


variable "cluster_name" {
  type    = string
}
variable "enable_vertical_pod_autoscaling" {
  type        = bool
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it"
}
variable "enable_intranode_visibility" {
  type        = bool
  description = "Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network"
  default     = false
}
variable "enable_kubernetes_alpha" {
  type        = bool
  description = "Whether to enable Kubernetes Alpha features for this cluster. Note that when this option is enabled, the cluster cannot be upgraded and will be automatically deleted after 30 days."
  default     = false
}
variable "enable_tpu" {
  type        = bool
  description = "Enable Cloud TPU resources in the cluster. WARNING: changing this after cluster creation is destructive!"
  default     = false
}
variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  default     = "05:00"
}
variable "enable_shielded_nodes" {
  type        = bool
  description = "Enable Shielded Nodes features on all nodes in this cluster"
  default     = true
}
variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
}
