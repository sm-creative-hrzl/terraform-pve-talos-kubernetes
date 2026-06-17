###############################################################################
# Terraform & Provider version constraints
#
# Pinned to the latest stable major lines available at generation time.
# Bump the lower bounds when you intentionally adopt newer features.
###############################################################################

terraform {
  required_version = ">= 1.9"

  required_providers {
    # Modern, actively maintained Proxmox provider (preferred over Telmate).
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66"
    }

    # Talos Linux lifecycle: secrets, machine configs, bootstrap, kubeconfig.
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7"
    }

    # Helm is used to install the in-cluster add-ons (Cilium, MetalLB, etc.).
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15"
    }

    # Kubernetes provider for namespaces / raw objects.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }

    # kubectl provider for applying server-side CRs (MetalLB pools, etc.).
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.18"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}
