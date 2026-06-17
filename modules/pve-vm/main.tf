###############################################################################
# pve-vm module — create a single Talos VM by cloning the Talos template.
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

  clone {
    vm_id = var.template_id
    full  = true
  }

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
