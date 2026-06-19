###############################################################################
# Talos Linux variables
###############################################################################

variable "talos_version" {
  description = "Talos Linux version (machine image / config schema)."
  type        = string
  default     = "v1.9.2"
}

variable "kubernetes_version" {
  description = "Kubernetes version Talos installs."
  type        = string
  default     = "v1.32.0"
}

variable "install_disk" {
  description = "Disk Talos installs onto. scsi0 presents as /dev/sda; virtio-blk presents as /dev/vda."
  type        = string
  default     = "/dev/sda"
}

variable "talos_vip_enabled" {
  description = "Enable the Talos shared control-plane VIP at cluster_endpoint (recommended for HA)."
  type        = bool
  default     = true
}

variable "allow_scheduling_on_control_planes" {
  description = "Allow workloads to schedule on control-plane nodes (useful for single-node / tiny clusters)."
  type        = bool
  default     = false
}

variable "kubeconfig_path" {
  description = "Local path where the generated kubeconfig is written."
  type        = string
  default     = "./kubeconfig"
}

variable "talosconfig_path" {
  description = "Local path where the generated talosconfig is written."
  type        = string
  default     = "./talosconfig"
}

variable "extra_machine_config_patches" {
  description = "Extra raw Talos machine-config patch documents (YAML strings) applied to every node."
  type        = list(string)
  default     = []
}
