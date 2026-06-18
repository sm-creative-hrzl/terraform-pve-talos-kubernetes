###############################################################################
# Network-derived resources
#
# Validates the IP plan and renders a hosts-style inventory of the computed
# node addresses for convenience (ssh/known-hosts, documentation, etc.).
###############################################################################

# Guard: make sure the chosen offsets/counts actually fit inside node_network
# and that the VIP does not collide with a node IP.
resource "terraform_data" "network_guard" {
  lifecycle {
    precondition {
      condition     = !contains(local.all_node_ips, var.cluster_endpoint)
      error_message = "cluster_endpoint (VIP ${var.cluster_endpoint}) collides with a node IP. Pick a free address."
    }

    precondition {
      # An IP is inside node_network iff masking it to the subnet prefix yields
      # the same network address as node_network itself. cidrhost() masks any
      # host bits, so cidrhost("<ip>/<prefix>", 0) is that IP's network base.
      condition = alltrue([
        for ip in local.all_node_ips :
        cidrhost("${ip}/${local.network_prefix}", 0) == cidrhost(var.node_network, 0)
      ])
      error_message = "One or more derived node IPs fall outside node_network. Reduce counts/offsets or widen the subnet."
    }
  }
}

# Render a simple /etc/hosts fragment describing the allocation.
resource "local_file" "node_inventory" {
  filename = "${path.root}/node-inventory.hosts"
  content = join("\n", concat(
    ["# Managed by Terraform — Talos/Kubernetes node inventory",
    "${var.cluster_endpoint}\t${var.cluster_name}-vip ${var.cluster_name}-api"],
    [for k, n in local.all_nodes : "${n.ip_address}\t${n.name}"],
  ))
  file_permission = "0644"
}
