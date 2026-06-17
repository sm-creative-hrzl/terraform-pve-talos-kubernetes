###############################################################################
# pve-vm module — create a single Talos VM that boots from the Talos ISO.
#
# No template is required: each VM is built from scratch with an empty boot disk
# and the Talos nocloud ISO attached. It boots the ISO into maintenance mode,
# the talos-cluster module applies the machine config, and Talos installs itself
# to install_disk. On the next boot it starts from the now-provisioned disk.
#
# Networking: the static IP is injected via Proxmox cloud-init. Talos' nocloud
# platform consumes this metadata on first boot, so the node is reachable at a
# predictable address for `talosctl apply-config` with no DHCP guesswork.
###############################################################################

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  vm_id       = var.vmid
  node_name   = var.pve_node
  description = var.description
  tags        = var.tags

  # Talos is immutable; the VM should restart on host reboot.
  on_boot = true

  # The QEMU guest agent ships in Talos and reports IPs back to Proxmox.
  agent {
    enabled = true
    trim    = true
  }

  operating_system {
    type = "l26"
  }

  # Boot media: the Talos nocloud ISO, downloaded to Proxmox by the root module.
  cdrom {
    file_id   = var.iso_file_id
    interface = "ide3"
  }

  # First boot: the disk is empty, so the firmware falls through to the ISO
  # (Talos maintenance mode). After Talos installs to the disk, it boots from
  # the disk on every subsequent start.
  boot_order = [var.disk_interface, "ide3"]

  cpu {
    cores = var.cpu
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    vlan_id  = var.vlan_id
    firewall = false
  }

  initialization {
    datastore_id = var.cloudinit_datastore_id

    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.network_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }

  lifecycle {
    # Talos manages its own disk/boot once installed; avoid spurious diffs from
    # the cloud-init drive and disk metadata the guest mutates at runtime.
    ignore_changes = [
      initialization,
      disk[0].file_format,
    ]
  }
}
