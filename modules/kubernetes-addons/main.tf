###############################################################################
# kubernetes-addons module
#
# Install order matters: Cilium (CNI) must come up before anything else can
# schedule, so every other release depends on it.
###############################################################################

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.18"
    }
  }
}

# --- Cilium (CNI, kube-proxy replacement) -----------------------------------

resource "helm_release" "cilium" {
  count = var.enable_cilium ? 1 : 0

  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = var.cilium_version
  namespace  = "kube-system"

  # Cilium must be fully rolled out before dependent add-ons schedule.
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  values = [
    templatefile("${var.manifests_path}/cilium/values.yaml.tftpl", {
      k8s_service_host = var.cluster_vip
      pod_cidr         = var.pod_subnet
    })
  ]
}

# --- MetalLB ----------------------------------------------------------------

resource "helm_release" "metallb" {
  count = var.enable_metallb ? 1 : 0

  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = var.metallb_version
  namespace        = "metallb-system"
  create_namespace = true

  wait    = true
  timeout = 300

  depends_on = [helm_release.cilium]
}

# MetalLB pool + L2 advertisement (applied after the CRDs exist).
resource "kubectl_manifest" "metallb_pool" {
  count = var.enable_metallb ? 1 : 0

  yaml_body = templatefile("${var.manifests_path}/metallb/ipaddresspool.yaml.tftpl", {
    pool_start = var.metallb_pool_start
    pool_end   = var.metallb_pool_end
  })

  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb_l2" {
  count = var.enable_metallb ? 1 : 0

  yaml_body = file("${var.manifests_path}/metallb/l2advertisement.yaml")

  depends_on = [kubectl_manifest.metallb_pool]
}

# --- Traefik (ingress controller) -------------------------------------------

resource "helm_release" "traefik" {
  count = var.enable_traefik ? 1 : 0

  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = var.traefik_version
  namespace        = "traefik"
  create_namespace = true

  wait    = true
  timeout = 300

  values = [
    file("${var.manifests_path}/traefik/values.yaml")
  ]

  # Needs the CNI up, and a MetalLB pool to get an external IP.
  depends_on = [
    helm_release.cilium,
    kubectl_manifest.metallb_l2,
  ]
}

# --- cert-manager -----------------------------------------------------------

resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = "cert-manager"
  create_namespace = true

  wait    = true
  timeout = 300

  values = [
    file("${var.manifests_path}/cert-manager/values.yaml")
  ]

  depends_on = [helm_release.cilium]
}
