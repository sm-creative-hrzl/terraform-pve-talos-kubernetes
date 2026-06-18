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
      version = "~> 0.109"
    }

    # Talos Linux lifecycle: secrets, machine configs, bootstrap, kubeconfig.
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11"
    }

    # Helm is used to install the in-cluster add-ons (Cilium, MetalLB, etc.).
    # v3 changed the kubernetes {} block to a kubernetes = {} attribute.
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    # Kubernetes provider for namespaces / raw objects.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }

    # kubectl provider for applying server-side CRs (MetalLB pools, etc.).
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3"
    }
  }
}
