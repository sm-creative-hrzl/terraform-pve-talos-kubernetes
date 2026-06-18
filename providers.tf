###############################################################################
# Provider configuration
#
# The Kubernetes / Helm / kubectl providers are wired directly to the
# kubeconfig that the Talos module produces, so the entire stack comes up in a
# single `terraform apply` with no manual kubeconfig handling.
###############################################################################

terraform {
  required_version = "~> 1.15"
  backend "s3" {
    bucket = "terraform-state"
    key    = "talos-k8s/terraform.tfstate"

    # MinIO requires path-style access and an explicit endpoint.
    # Terraform >= 1.6 uses the endpoints block instead of the legacy endpoint arg.
    endpoints = {
      s3 = "http://10.10.20.205:19000"
    }

    # Any non-empty string satisfies the region requirement for MinIO.
    region = "pve-nzxt"

    use_path_style = true

    # MinIO does not implement these AWS-specific API calls.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true

    # MinIO has no STS/IAM, so the backend cannot look up an AWS account ID.
    # Without this it falls back to STS:GetCallerIdentity and iam:ListRoles,
    # both of which MinIO rejects with 403 InvalidClientTokenId.
    skip_requesting_account_id = true
  }
  required_providers {
    # Modern, actively maintained Proxmox provider (preferred over Telmate).
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.100"
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
  kubernetes = {
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
