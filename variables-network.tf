###############################################################################
# Networking variables
###############################################################################

variable "node_network" {
  description = "CIDR of the LAN segment the nodes live on. Node IPs are derived from this with cidrhost()."
  type        = string
  default     = "10.10.20.0/24"

  validation {
    condition     = can(cidrhost(var.node_network, 0))
    error_message = "node_network must be a valid CIDR, e.g. 10.10.20.0/24."
  }
}

variable "gateway" {
  description = "Default gateway for the node network."
  type        = string
  default     = "10.10.20.1"
}

variable "dns_servers" {
  description = "DNS servers handed to the nodes."
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "network_bridge" {
  description = "Proxmox bridge interface the VM NICs attach to."
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "Optional VLAN tag for the VM NIC. Set to null to disable tagging."
  type        = number
  default     = null
}

variable "cluster_network_cidr" {
  description = "Pod network CIDR (Cilium IPAM)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_network_cidr" {
  description = "Kubernetes Service network CIDR."
  type        = string
  default     = "10.96.0.0/12"
}
