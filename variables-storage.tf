###############################################################################
# Storage variables
###############################################################################

variable "vm_datastore_id" {
  description = "Proxmox datastore for VM boot disks (e.g. local-lvm, local-zfs, ceph)."
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_datastore_id" {
  description = "Proxmox datastore that holds the cloud-init drive. Usually a directory/zfs store such as local-lvm."
  type        = string
  default     = "local-lvm"
}

variable "disk_interface" {
  description = "Disk bus/interface for the VM boot disk. Keep in sync with install_disk (scsi0 => /dev/sda)."
  type        = string
  default     = "scsi0"
}

variable "iso_datastore_id" {
  description = "Proxmox datastore that holds the downloaded Talos ISO. Must support 'iso' content (e.g. local), not block storage like local-lvm."
  type        = string
  default     = "local"
}
