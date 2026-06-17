###############################################################################
# pve-vm module — outputs
###############################################################################

output "vmid" {
  description = "Proxmox VMID of the created VM."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name."
  value       = proxmox_virtual_environment_vm.this.name
}

output "ip_address" {
  description = "Configured static IP address."
  value       = var.ip_address
}

output "mac_address" {
  description = "MAC address of the primary NIC."
  value       = try(proxmox_virtual_environment_vm.this.network_device[0].mac_address, null)
}
