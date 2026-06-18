###############################################################################
# Kubernetes add-on variables (Cilium, MetalLB, Traefik, cert-manager)
###############################################################################

# --- Toggles ----------------------------------------------------------------

variable "enable_cilium" {
  description = "Install Cilium CNI (required — Talos is configured with cni=none and kube-proxy disabled)."
  type        = bool
  default     = true
}

variable "enable_metallb" {
  description = "Install MetalLB for bare-metal LoadBalancer services."
  type        = bool
  default     = true
}

variable "enable_traefik" {
  description = "Install the Traefik ingress controller."
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Install cert-manager."
  type        = bool
  default     = true
}

# --- Chart versions ---------------------------------------------------------

variable "cilium_version" {
  description = "Cilium Helm chart version."
  type        = string
  default     = "1.16.5"
}

variable "metallb_version" {
  description = "MetalLB Helm chart version."
  type        = string
  default     = "0.14.9"
}

variable "traefik_version" {
  description = "Traefik Helm chart version."
  type        = string
  default     = "33.2.1"
}

variable "cert_manager_version" {
  description = "cert-manager Helm chart version."
  type        = string
  default     = "v1.16.2"
}

# --- MetalLB address pool ----------------------------------------------------

variable "metallb_pool_start" {
  description = "First address of the MetalLB LoadBalancer pool. Must be outside the node IP range."
  type        = string
  default     = "10.10.20.200"
}

variable "metallb_pool_end" {
  description = "Last address of the MetalLB LoadBalancer pool."
  type        = string
  default     = "10.10.20.220"
}
