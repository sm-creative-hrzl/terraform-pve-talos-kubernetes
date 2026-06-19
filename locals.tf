###############################################################################
# Locals
#
# Builds the authoritative node maps consumed by every module. Node IPs are
# derived deterministically from node_network via cidrhost(), so scaling is
# purely a matter of changing the *_count variables.
###############################################################################

locals {
  network_prefix = tonumber(split("/", var.node_network)[1])

  # --- Control-plane node map ------------------------------------------------
  control_plane_nodes = {
    for i in range(var.control_plane_count) :
    "${var.cluster_name}-cp-${i + 1}" => {
      name       = "${var.cluster_name}-cp-${i + 1}"
      vmid       = var.control_plane_vmid_base + i
      ip_address = cidrhost(var.node_network, var.control_plane_ip_offset + i)
      cpu        = var.control_plane_cpu
      memory     = var.control_plane_memory
      disk_size  = var.control_plane_disk_size
      role       = "controlplane"
    }
  }

  # --- Worker node map -------------------------------------------------------
  worker_nodes = {
    for i in range(var.worker_count) :
    "${var.cluster_name}-worker-${i + 1}" => {
      name       = "${var.cluster_name}-worker-${i + 1}"
      vmid       = var.worker_vmid_base + i
      ip_address = cidrhost(var.node_network, var.worker_ip_offset + i)
      cpu        = var.worker_cpu
      memory     = var.worker_memory
      disk_size  = var.worker_disk_size
      role       = "worker"
    }
  }

  all_nodes = merge(local.control_plane_nodes, local.worker_nodes)

  control_plane_ips = [for n in local.control_plane_nodes : n.ip_address]
  worker_ips        = [for n in local.worker_nodes : n.ip_address]
  all_node_ips      = concat(local.control_plane_ips, local.worker_ips)

  # https endpoint Talos / kubeconfig use.
  talos_cluster_endpoint = "https://${var.cluster_endpoint}:6443"
}
