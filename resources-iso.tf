###############################################################################
# Talos boot media
#
# Download the Talos "nocloud" ISO to Proxmox once. Every node boots from it in
# maintenance mode, then the talos-cluster module installs Talos to install_disk.
# The nocloud image consumes the Proxmox cloud-init drive for static networking,
# so nodes come up reachable at predictable IPs with no DHCP and no pre-built
# template VM.
###############################################################################

resource "proxmox_virtual_environment_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.pve_node

  url       = local.talos_iso_url
  file_name = "talos-${var.talos_version}-nocloud-amd64.iso"

  # Avoid re-downloading on every apply once the image is present.
  overwrite = false
}
