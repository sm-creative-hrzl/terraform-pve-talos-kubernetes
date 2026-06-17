###############################################################################
# In-cluster add-ons
#
# Installs Cilium (CNI), MetalLB, Traefik and cert-manager once the
# cluster is bootstrapped and the kubeconfig is available.
###############################################################################

module "kubernetes_addons" {
  source = "./modules/kubernetes-addons"

  manifests_path = "${path.root}/manifests"

  cluster_vip    = var.cluster_endpoint
  pod_subnet     = var.cluster_network_cidr
  service_subnet = var.service_network_cidr

  enable_cilium       = var.enable_cilium
  enable_metallb      = var.enable_metallb
  enable_traefik      = var.enable_traefik
  enable_cert_manager = var.enable_cert_manager

  cilium_version       = var.cilium_version
  metallb_version      = var.metallb_version
  traefik_version      = var.traefik_version
  cert_manager_version = var.cert_manager_version

  metallb_pool_start = var.metallb_pool_start
  metallb_pool_end   = var.metallb_pool_end

  # The cluster (and its kubeconfig) must exist before add-ons install.
  depends_on = [module.talos_cluster]
}
