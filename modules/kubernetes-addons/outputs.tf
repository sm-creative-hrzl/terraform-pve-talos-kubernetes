###############################################################################
# kubernetes-addons module — outputs
###############################################################################

output "installed_addons" {
  description = "Map of add-on => installed flag."
  value = {
    cilium       = var.enable_cilium
    metallb      = var.enable_metallb
    traefik      = var.enable_traefik
    cert_manager = var.enable_cert_manager
  }
}

output "metallb_pool" {
  description = "Configured MetalLB address range."
  value       = var.enable_metallb ? "${var.metallb_pool_start} - ${var.metallb_pool_end}" : null
}
