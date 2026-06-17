###############################################################################
# Provider configuration
#
# The Kubernetes / Helm / kubectl providers are wired directly to the
# kubeconfig that the Talos module produces, so the entire stack comes up in a
# single `terraform apply` with no manual kubeconfig handling.
###############################################################################

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = "${var.pve_token_id}=${var.pve_token_secret}"
  insecure  = var.pve_tls_insecure

  # SSH is used by the provider for a handful of operations (e.g. uploading
  # snippets). Agent auth keeps credentials out of state.
  ssh {
    agent    = true
    username = var.pve_ssh_username
  }
}

provider "talos" {}

provider "local" {}

provider "tls" {}

provider "kubernetes" {
  host                   = module.talos_cluster.kube_host
  client_certificate     = base64decode(module.talos_cluster.kube_client_certificate)
  client_key             = base64decode(module.talos_cluster.kube_client_key)
  cluster_ca_certificate = base64decode(module.talos_cluster.kube_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.talos_cluster.kube_host
    client_certificate     = base64decode(module.talos_cluster.kube_client_certificate)
    client_key             = base64decode(module.talos_cluster.kube_client_key)
    cluster_ca_certificate = base64decode(module.talos_cluster.kube_ca_certificate)
  }
}

provider "kubectl" {
  host                   = module.talos_cluster.kube_host
  client_certificate     = base64decode(module.talos_cluster.kube_client_certificate)
  client_key             = base64decode(module.talos_cluster.kube_client_key)
  cluster_ca_certificate = base64decode(module.talos_cluster.kube_ca_certificate)
  load_config_file       = false
}
