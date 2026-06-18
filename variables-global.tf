###############################################################################
# Global variables
#
# Cluster identity and the control-plane endpoint that every layer references.
###############################################################################

variable "cluster_name" {
  description = "Name of the Kubernetes cluster. Used as a prefix for VM names and Talos cluster identity."
  type        = string
  default     = "homelab"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name))
    error_message = "cluster_name must be a valid DNS label (lowercase alphanumerics and hyphens)."
  }
}

variable "cluster_endpoint" {
  description = <<-EOT
    The Kubernetes API control-plane endpoint IP. With HA enabled this is the
    Talos shared VIP and MUST be a free address on node_network, distinct from
    every node IP and outside the MetalLB pool range.
  EOT
  type        = string
}

variable "common_tags" {
  description = "Tags applied to all created Proxmox VMs for easy identification/filtering."
  type        = list(string)
  default     = ["terraform", "talos", "kubernetes"]
}
