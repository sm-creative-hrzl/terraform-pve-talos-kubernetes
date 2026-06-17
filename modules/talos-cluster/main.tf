###############################################################################
# talos-cluster module
#
# Full Talos lifecycle with zero manual talosctl steps:
#   secrets -> machine configs -> apply (per node) -> bootstrap -> kubeconfig
###############################################################################

terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7"
    }
  }
}

locals {
  # Shared across control-plane and worker nodes. Cilium replaces kube-proxy,
  # so the CNI is set to "none" and the proxy is disabled here.
  common_config_patch = {
    machine = {
      install = {
        disk = var.install_disk
      }
      certSANs = [var.cluster_vip]
      kubelet = {
        extraArgs = {
          "rotate-server-certificates" = "true"
        }
      }
    }
    cluster = {
      network = {
        cni            = { name = "none" }
        podSubnets     = [var.pod_subnet]
        serviceSubnets = [var.service_subnet]
      }
      proxy = { disabled = true }
    }
  }

  # Control-plane only: VIP for HA API access + scheduling policy + extra SANs.
  controlplane_config_patch = {
    machine = {
      network = var.vip_enabled ? {
        interfaces = [
          {
            deviceSelector = { physical = true }
            dhcp           = false
            vip            = { ip = var.cluster_vip }
          }
        ]
      } : {}
    }
    cluster = {
      allowSchedulingOnControlPlanes = var.allow_scheduling_on_control_planes
      apiServer = {
        certSANs = [var.cluster_vip]
      }
    }
  }

  common_patches       = concat([yamlencode(local.common_config_patch)], var.extra_machine_config_patches)
  controlplane_patches = concat(local.common_patches, [yamlencode(local.controlplane_config_patch)])
}

# --- Secrets ----------------------------------------------------------------

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# --- Machine configurations -------------------------------------------------

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches     = local.controlplane_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches     = local.common_patches
}

# --- Client (talosctl) configuration ----------------------------------------

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = var.control_plane_ips
  nodes                = concat(var.control_plane_ips, var.worker_ips)
}

# --- Apply configs to every node --------------------------------------------

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.control_plane_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip_address
  endpoint                    = each.value.ip_address

  # Per-node hostname.
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.name
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = var.worker_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
  endpoint                    = each.value.ip_address

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.name
        }
      }
    })
  ]
}

# --- Bootstrap etcd (run exactly once, on the first control-plane node) ------

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  node                 = var.control_plane_ips[0]
  endpoint             = var.control_plane_ips[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

# --- Wait for the cluster to be healthy -------------------------------------

data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker,
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = var.control_plane_ips
  worker_nodes         = var.worker_ips
  endpoints            = var.control_plane_ips

  timeouts = {
    read = "10m"
  }
}

# --- Retrieve kubeconfig -----------------------------------------------------

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  node                 = var.control_plane_ips[0]
  endpoint             = var.control_plane_ips[0]
  client_configuration = talos_machine_secrets.this.client_configuration

  timeouts = {
    read = "5m"
  }
}
