###############################################################################
# Root outputs
###############################################################################

output "control_plane_ips" {
  description = "IP addresses of the control-plane nodes."
  value       = local.control_plane_ips
}

output "worker_ips" {
  description = "IP addresses of the worker nodes."
  value       = local.worker_ips
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (VIP)."
  value       = var.cluster_endpoint
}

output "kubeconfig_path" {
  description = "Local path to the generated kubeconfig."
  value       = local_sensitive_file.kubeconfig.filename
}

output "talosconfig_path" {
  description = "Local path to the generated talosconfig."
  value       = local_sensitive_file.talosconfig.filename
}

output "node_inventory" {
  description = "Map of node name => IP address."
  value       = { for k, n in local.all_nodes : n.name => n.ip_address }
}

output "kubeconfig" {
  description = "Raw kubeconfig contents."
  value       = module.talos_cluster.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Raw talosconfig contents."
  value       = module.talos_cluster.talosconfig
  sensitive   = true
}
