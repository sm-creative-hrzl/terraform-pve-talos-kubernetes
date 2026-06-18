###############################################################################
# Proxmox VE connection + VM sizing variables
###############################################################################

# --- Connection -------------------------------------------------------------

variable "pve_api_url" {
  description = "Proxmox VE API endpoint, e.g. https://pve01.example.com:8006/"
  type        = string
}

variable "pve_token_id" {
  description = "Proxmox API token ID, e.g. root@pam!terraform"
  type        = string
  sensitive   = true
}

variable "pve_token_secret" {
  description = "Proxmox API token secret (UUID)."
  type        = string
  sensitive   = true
}

variable "pve_node" {
  description = "Name of the Proxmox node on which to create the VMs."
  type        = string
}

variable "pve_tls_insecure" {
  description = "Skip TLS verification against the Proxmox API (homelabs often use self-signed certs)."
  type        = bool
  default     = true
}

variable "pve_ssh_username" {
  description = "SSH username the Proxmox provider uses for snippet uploads and host-side operations."
  type        = string
  default     = "root"
}

# --- Counts -----------------------------------------------------------------

variable "control_plane_count" {
  description = "Number of control-plane nodes. Use an odd number (1, 3, 5) for etcd quorum."
  type        = number
  default     = 3

  validation {
    condition     = var.control_plane_count >= 1 && var.control_plane_count % 2 == 1
    error_message = "control_plane_count must be a positive odd number for a healthy etcd quorum."
  }
}

variable "worker_count" {
  description = "Number of worker nodes. Change this value alone to scale the cluster up or down."
  type        = number
  default     = 3

  validation {
    condition     = var.worker_count >= 0
    error_message = "worker_count must be zero or greater."
  }
}

# --- Control-plane VM specs --------------------------------------------------

variable "control_plane_cpu" {
  description = "vCPU cores per control-plane node."
  type        = number
  default     = 2
}

variable "control_plane_memory" {
  description = "Memory (MiB) per control-plane node."
  type        = number
  default     = 2048
}

variable "control_plane_disk_size" {
  description = "Boot disk size (GiB) per control-plane node."
  type        = number
  default     = 32
}

# --- Worker VM specs ---------------------------------------------------------

variable "worker_cpu" {
  description = "vCPU cores per worker node."
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory (MiB) per worker node."
  type        = number
  default     = 2048
}

variable "worker_disk_size" {
  description = "Boot disk size (GiB) per worker node."
  type        = number
  default     = 50
}

# --- VMID / IP allocation ----------------------------------------------------

variable "control_plane_vmid_base" {
  description = "Starting Proxmox VMID for control-plane nodes (incremented per node)."
  type        = number
  default     = 8000
}

variable "worker_vmid_base" {
  description = "Starting Proxmox VMID for worker nodes (incremented per node)."
  type        = number
  default     = 9000
}

variable "control_plane_ip_offset" {
  description = "Host offset within node_network for the first control-plane node (e.g. 20 -> x.x.x.20)."
  type        = number
  default     = 230
}

variable "worker_ip_offset" {
  description = "Host offset within node_network for the first worker node (e.g. 30 -> x.x.x.30)."
  type        = number
  default     = 240
}
