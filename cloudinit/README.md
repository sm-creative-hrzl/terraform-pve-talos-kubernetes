# cloud-init

Talos Linux does **not** use traditional cloud-init the way a general-purpose
distro does. Instead it implements the `nocloud` platform and reads a small
subset of metadata (notably **network configuration**) from the cloud-init
drive that Proxmox attaches to the VM.

## How it is used here

The `pve-vm` module configures an `initialization {}` block on every VM:

```hcl
initialization {
  datastore_id = var.cloudinit_datastore_id
  ip_config {
    ipv4 {
      address = "<node-ip>/<prefix>"
      gateway = "<gateway>"
    }
  }
  dns { servers = [...] }
}
```

Proxmox renders this into a NoCloud network-config datasource. Talos consumes
it on first boot and brings the interface up with the **predictable static IP**
derived from `node_network` in `locals.tf`. This removes the DHCP chicken-and-egg
problem: Terraform already knows each node's address, so it can immediately run
`talos_machine_configuration_apply` against it.

## Requirements

- The Talos template must be built so its disk image supports the `nocloud`
  platform (the stock Talos `nocloud` image, or a Proxmox/`metal` image that
  reads the cloud-init drive). When in doubt, use the **nocloud** Talos image
  from the Image Factory: <https://factory.talos.dev>.
- The `cloudinit_datastore_id` must be a datastore that can hold the cloud-init
  CD-ROM image (most directory/LVM/ZFS stores work).

## Alternative: DHCP + reservations

If you prefer DHCP, drop the `ip_config` block and instead:

1. Create DHCP reservations on your router for each node MAC.
2. Set the node IPs in `locals.tf` to match those reservations.

The rest of the flow is unchanged.
