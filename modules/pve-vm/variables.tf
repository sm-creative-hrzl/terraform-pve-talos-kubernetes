###############################################################################
# pve-vm module — input variables
###############################################################################

variable "pve_node" {
  description = "Proxmox node to create the VM on."
  type        = string
}

variable "name" {
  description = "VM name / hostname."
  type        = string
}

variable "vmid" {
  description = "Proxmox VMID."
  type        = number
}

variable "description" {
  description = "Human-readable VM description."
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "Tags applied to the VM."
  type        = list(string)
  default     = []
}

variable "iso_file_id" {
  description = "Proxmox file ID of the Talos ISO to boot from (e.g. local:iso/talos-v1.9.2-nocloud-amd64.iso)."
  type        = string
}

variable "cpu" {
  description = "vCPU cores."
  type        = number
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
}

variable "disk_size" {
  description = "Boot disk size in GiB."
  type        = number
}

variable "datastore_id" {
  description = "Datastore for the boot disk."
  type        = string
}

variable "cloudinit_datastore_id" {
  description = "Datastore for the cloud-init drive."
  type        = string
}

variable "disk_interface" {
  description = "Disk bus/interface (e.g. scsi0)."
  type        = string
  default     = "scsi0"
}

variable "network_bridge" {
  description = "Bridge the NIC attaches to."
  type        = string
}

variable "vlan_id" {
  description = "Optional VLAN tag."
  type        = number
  default     = null
}

variable "ip_address" {
  description = "Static IPv4 address for the node."
  type        = string
}

variable "network_prefix" {
  description = "Network prefix length (e.g. 24)."
  type        = number
}

variable "gateway" {
  description = "Default gateway."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers."
  type        = list(string)
}

variable "cpu_type" {
  description = "QEMU CPU type. 'host' gives best performance; use a stable model for live migration."
  type        = string
  default     = "host"
}
