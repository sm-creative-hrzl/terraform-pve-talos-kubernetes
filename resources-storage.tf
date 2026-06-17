###############################################################################
# Storage-related resources
#
# Validates the storage configuration early so misconfiguration fails fast
# (before any VM is cloned) rather than mid-apply.
###############################################################################

resource "terraform_data" "storage_guard" {
  input = {
    vm_datastore        = var.vm_datastore_id
    cloudinit_datastore = var.cloudinit_datastore_id
    disk_interface      = var.disk_interface
  }

  lifecycle {
    precondition {
      condition     = length(trimspace(var.vm_datastore_id)) > 0
      error_message = "vm_datastore_id must not be empty (e.g. local-lvm, local-zfs, ceph)."
    }

    precondition {
      condition     = can(regex("^(scsi|virtio|sata|ide)[0-9]+$", var.disk_interface))
      error_message = "disk_interface must be a valid bus identifier such as scsi0, virtio0 or sata0."
    }

    # Keep install_disk and the bus consistent: scsi/sata/ide => /dev/sdX,
    # virtio => /dev/vdX. This is the single most common bring-up footgun.
    precondition {
      condition = (
        startswith(var.disk_interface, "virtio") ? startswith(var.install_disk, "/dev/vd") : startswith(var.install_disk, "/dev/sd")
      )
      error_message = "install_disk does not match disk_interface. Use /dev/sda for scsi/sata/ide, /dev/vda for virtio."
    }
  }
}
