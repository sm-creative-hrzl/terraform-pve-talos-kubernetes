###############################################################################
# Data sources
###############################################################################

# Resolve the Talos template by name so users supply a human-friendly
# template_name instead of hunting for the numeric VMID. The result feeds
# local.template_vm_id (see locals.tf), which falls back to var.template_id.
data "proxmox_virtual_environment_vms" "template" {
  node_name = var.pve_node

  filter {
    name   = "name"
    values = [var.template_name]
  }

  filter {
    name   = "template"
    values = ["true"]
  }
}
