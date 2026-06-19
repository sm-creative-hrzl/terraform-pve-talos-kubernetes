###############################################################################
# Proxmox VM provisioning
#
# Control-plane and worker VMs are created from the same module via for_each
# over the node maps in locals.tf. Scaling worker_count up/down adds/removes
# map entries, which cleanly adds/destroys the corresponding VMs.
###############################################################################

module "control_plane" {
  source   = "github.com/sm-creative-hrzl/pve-vm-module//pve-vm?ref=v1.0.0"
  for_each = local.control_plane_nodes

  pve_node    = var.pve_node
  name        = each.value.name
  vmid        = each.value.vmid
  description = "Talos ${each.value.role} node — managed by Terraform"
  tags        = concat(var.common_tags, ["controlplane"])

  iso_datastore_id = var.iso_datastore_id
  talos_version    = var.talos_version

  cpu       = each.value.cpu
  memory    = each.value.memory
  disk_size = each.value.disk_size

  datastore_id           = var.vm_datastore_id
  cloudinit_datastore_id = var.cloudinit_datastore_id
  disk_interface         = var.disk_interface

  network_bridge = var.network_bridge
  vlan_id        = var.vlan_id
  ip_address     = each.value.ip_address
  network_prefix = local.network_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
}

module "worker" {
  source   = "github.com/sm-creative-hrzl/pve-vm-module//pve-vm?ref=v1.0.0"
  for_each = local.worker_nodes

  pve_node    = var.pve_node
  name        = each.value.name
  vmid        = each.value.vmid
  description = "Talos ${each.value.role} node — managed by Terraform"
  tags        = concat(var.common_tags, ["worker"])

  iso_datastore_id = var.iso_datastore_id
  talos_version    = var.talos_version

  cpu       = each.value.cpu
  memory    = each.value.memory
  disk_size = each.value.disk_size

  datastore_id           = var.vm_datastore_id
  cloudinit_datastore_id = var.cloudinit_datastore_id
  disk_interface         = var.disk_interface

  network_bridge = var.network_bridge
  vlan_id        = var.vlan_id
  ip_address     = each.value.ip_address
  network_prefix = local.network_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
}
