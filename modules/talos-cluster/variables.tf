###############################################################################
# talos-cluster module — input variables
###############################################################################

variable "cluster_name" {
  description = "Talos/Kubernetes cluster name."
  type        = string
}

variable "cluster_endpoint" {
  description = "Full https control-plane endpoint URL, e.g. https://192.168.10.10:6443."
  type        = string
}

variable "cluster_vip" {
  description = "Bare VIP address (no scheme/port) used for the Talos shared control-plane VIP."
  type        = string
}

variable "talos_version" {
  description = "Talos version."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "install_disk" {
  description = "Disk Talos installs onto."
  type        = string
}

variable "vip_enabled" {
  description = "Enable the shared control-plane VIP."
  type        = bool
  default     = true
}

variable "allow_scheduling_on_control_planes" {
  description = "Allow workloads on control-plane nodes."
  type        = bool
  default     = false
}

variable "pod_subnet" {
  description = "Pod network CIDR."
  type        = string
}

variable "service_subnet" {
  description = "Service network CIDR."
  type        = string
}

variable "control_plane_nodes" {
  description = "Map of control-plane node objects (name, ip_address, ...)."
  type        = any
}

variable "worker_nodes" {
  description = "Map of worker node objects."
  type        = any
}

variable "control_plane_ips" {
  description = "List of control-plane node IPs."
  type        = list(string)
}

variable "worker_ips" {
  description = "List of worker node IPs."
  type        = list(string)
}

variable "extra_machine_config_patches" {
  description = "Additional raw YAML machine-config patches applied to all nodes."
  type        = list(string)
  default     = []
}
