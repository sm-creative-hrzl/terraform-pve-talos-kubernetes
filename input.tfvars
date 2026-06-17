###############################################################################
# input.tfvars — template values
#
# A ready-to-edit variable file with placeholder values. Fill in the items
# marked REPLACE-ME for your environment, then apply with:
#
#   terraform apply -var-file=input.tfvars
#
# SECURITY: do NOT commit real tokens. Prefer environment variables for secrets:
#   export TF_VAR_pve_token_id="root@pam!terraform"
#   export TF_VAR_pve_token_secret="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
###############################################################################

# --- Proxmox connection ------------------------------------------------------
# pve_api_url      = "https://10.10.20.21:8006/" # TF_VAR_PVE_API_URL
# pve_token_id     = "root@pam!terraform" # better: TF_VAR_pve_token_id
# pve_token_secret = "REPLACE-ME"         # better: TF_VAR_pve_token_secret

pve_node = "pve-nzxt"

# --- Talos template ----------------------------------------------------------
template_name = "talos-template"

# --- Networking --------------------------------------------------------------
network_bridge = "vmbr0"

node_network = "10.10.20.0/24"
gateway      = "10.10.20.1"
dns_servers  = ["10.10.20.1", "1.1.1.1"]

# Shared control-plane VIP — must be free and outside the MetalLB pool.
cluster_endpoint = "10.10.20.108"

# --- Cluster identity & sizing ----------------------------------------------
cluster_name = "homelab"

control_plane_count = 3
worker_count        = 3

# --- MetalLB LoadBalancer pool ----------------------------------------------
metallb_pool_start = "10.10.20.200"
metallb_pool_end   = "10.10.20.220"

###############################################################################
# Optional overrides — defaults are usually fine. Uncomment to tune.
###############################################################################
# vm_datastore_id    = "local-lvm"
# install_disk       = "/dev/sda"
# talos_version      = "v1.9.2"
# kubernetes_version = "v1.32.0"
# worker_cpu         = 4
# worker_memory      = 16384
# worker_disk_size   = 100

# --- Add-on toggles / versions ----------------------------------------------
# enable_cilium       = true
# enable_metallb      = true
# enable_traefik      = true
# enable_cert_manager = true
# traefik_version     = "33.2.1"
