###############################################################################
# kubernetes-addons module — input variables
###############################################################################

variable "manifests_path" {
  description = "Path to the repo's manifests/ directory holding Helm value templates."
  type        = string
}

variable "cluster_vip" {
  description = "Control-plane VIP (used as Cilium's k8sServiceHost)."
  type        = string
}

variable "pod_subnet" {
  description = "Pod network CIDR (Cilium native routing)."
  type        = string
}

variable "service_subnet" {
  description = "Service network CIDR."
  type        = string
}

# --- Toggles ----------------------------------------------------------------

variable "enable_cilium" {
  type    = bool
  default = true
}

variable "enable_metallb" {
  type    = bool
  default = true
}

variable "enable_traefik" {
  type    = bool
  default = true
}

variable "enable_cert_manager" {
  type    = bool
  default = true
}

# --- Versions ---------------------------------------------------------------

variable "cilium_version" {
  type = string
}

variable "metallb_version" {
  type = string
}

variable "traefik_version" {
  type = string
}

variable "cert_manager_version" {
  type = string
}

# --- MetalLB pool -----------------------------------------------------------

variable "metallb_pool_start" {
  type = string
}

variable "metallb_pool_end" {
  type = string
}
