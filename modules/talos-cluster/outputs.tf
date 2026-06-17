###############################################################################
# talos-cluster module — outputs
###############################################################################

output "kubeconfig_raw" {
  description = "Raw kubeconfig YAML."
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Raw talosconfig YAML for talosctl."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "client_configuration" {
  description = "Talos client configuration object."
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
}

# --- Kubernetes client connection details (for provider wiring) -------------

output "kube_host" {
  description = "Kubernetes API server host URL."
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
}

output "kube_client_certificate" {
  description = "Base64-encoded client certificate."
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  sensitive   = true
}

output "kube_client_key" {
  description = "Base64-encoded client key."
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  sensitive   = true
}

output "kube_ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  sensitive   = true
}
