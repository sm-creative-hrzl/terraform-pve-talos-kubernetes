###############################################################################
# Talos cluster lifecycle
#
# Generates machine secrets/configs, applies them to every node, bootstraps
# etcd, and retrieves the kubeconfig + talosconfig. Depends on the VMs being
# created and reachable at their static IPs first.
###############################################################################

module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster_name     = var.cluster_name
  cluster_endpoint = local.talos_cluster_endpoint
  cluster_vip      = var.cluster_endpoint

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  install_disk       = var.install_disk
  vip_enabled        = var.talos_vip_enabled

  allow_scheduling_on_control_planes = var.allow_scheduling_on_control_planes

  pod_subnet     = var.cluster_network_cidr
  service_subnet = var.service_network_cidr

  control_plane_nodes = local.control_plane_nodes
  worker_nodes        = local.worker_nodes
  control_plane_ips   = local.control_plane_ips
  worker_ips          = local.worker_ips

  extra_machine_config_patches = var.extra_machine_config_patches

  # Ensure VMs exist before we try to talk to them.
  depends_on = [
    module.control_plane,
    module.worker,
  ]
}

# --- Persist credentials locally --------------------------------------------

resource "local_sensitive_file" "kubeconfig" {
  content         = module.talos_cluster.kubeconfig_raw
  filename        = var.kubeconfig_path
  file_permission = "0600"
}

resource "local_sensitive_file" "talosconfig" {
  content         = module.talos_cluster.talosconfig
  filename        = var.talosconfig_path
  file_permission = "0600"
}
