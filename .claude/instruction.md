You are a senior Platform Engineer, Terraform expert, and Kubernetes architect.

Your task is to generate a complete Infrastructure-as-Code repository that provisions and manages a Talos-based Kubernetes cluster on a Proxmox VE (PVE) homelab environment.

# Goal

Create a production-quality Terraform codebase that:

1. Creates and manages Kubernetes nodes as Proxmox VMs.
2. Installs and configures Talos Linux automatically.
3. Bootstraps Kubernetes automatically.
4. Supports horizontal scaling of worker nodes by modifying only values in `terraform.tfvars`.
5. Supports recreation of the entire cluster from scratch.
6. Is fully GitOps-friendly.
7. Can be executed locally or through GitHub Actions.
8. Uses modular Terraform design.
9. Separates resources and variables by technology/provider.

The generated repository should be complete and immediately usable.

---

# Technical Requirements

## Terraform

Use:

* Terraform >= 1.9
* Official Terraform style guide
* Providers:

  * Telmate/Proxmox (or latest recommended Proxmox provider)
  * Talos provider
  * Kubernetes provider
  * Kubectl provider
  * Local provider
  * TLS provider

Generate:

```hcl
terraform {
  required_version = ">= 1.9"
}
```

---

# Repository Structure

Generate exactly this structure:

```text
terraform-k8s-proxmox/

├── providers.tf
├── versions.tf
├── backend.tf

├── variables-global.tf
├── locals.tf
├── outputs.tf

├── terraform.tfvars.example

├── resources-pve-vm.tf
├── variables-pve-vm.tf

├── resources-talos.tf
├── variables-talos.tf

├── resources-kubernetes.tf
├── variables-kubernetes.tf

├── resources-network.tf
├── variables-network.tf

├── resources-storage.tf
├── variables-storage.tf

├── data-sources.tf

├── cloudinit/
│   └── README.md

├── scripts/
│   ├── generate-talconfig.sh
│   ├── bootstrap-cluster.sh
│   └── kubeconfig.sh

├── modules/
│   ├── pve-vm/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── talos-cluster/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── kubernetes-addons/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf

├── manifests/
│   ├── cilium/
│   ├── metallb/
│   ├── ingress-nginx/
│   └── cert-manager/

├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       └── terraform-destroy.yml

└── README.md
```

---

# Proxmox Design

Assume:

* Existing Proxmox cluster
* Existing Talos template image
* Existing bridge network

Terraform should create:

## Control Plane

Default:

```hcl
control_plane_count = 3
```

VM specs:

```hcl
4 CPU
8GB RAM
50GB disk
```

---

## Workers

Default:

```hcl
worker_count = 3
```

VM specs:

```hcl
4 CPU
16GB RAM
100GB disk
```

---

Scaling requirement:

Changing:

```hcl
worker_count = 10
```

must automatically create additional workers.

Changing:

```hcl
worker_count = 2
```

must destroy excess workers cleanly.

Use:

```hcl
for_each
```

or

```hcl
count
```

appropriately.

---

# Networking

Support:

```hcl
cluster_network_cidr
service_network_cidr
```

defaults:

```hcl
10.244.0.0/16
10.96.0.0/12
```

Node IPs should be automatically calculated from:

```hcl
node_network
```

using:

```hcl
cidrhost()
```

---

# Talos Configuration

Terraform must:

1. Generate machine secrets.
2. Generate Talos machine configs.
3. Apply configs automatically.
4. Bootstrap cluster automatically.
5. Retrieve kubeconfig automatically.

Use Talos provider resources wherever possible.

Do not require manual talosctl steps after terraform apply.

---

# Kubernetes Configuration

After Talos bootstrap:

Automatically configure:

### Cilium

Install via Terraform.

Requirements:

* kube-proxy disabled
* native routing
* Hubble enabled

---

### MetalLB

Install via Terraform.

Provide configurable:

```hcl
metallb_pool_start
metallb_pool_end
```

---

### ingress-nginx

Deploy automatically.

---

### cert-manager

Deploy automatically.

---

# Input Variables Philosophy

IMPORTANT:

Only user-specific values belong inside:

```hcl
terraform.tfvars
```

Everything else should be opinionated defaults.

---

Expected tfvars:

```hcl
pve_api_url
pve_token_id
pve_token_secret

pve_node

template_name

network_bridge

cluster_name

cluster_endpoint

node_network

dns_servers

gateway

control_plane_count

worker_count

metallb_pool_start
metallb_pool_end
```

No other values should be mandatory.

---

# Example terraform.tfvars

Generate a fully documented example:

```hcl
cluster_name = "homelab"

pve_node = "pve01"

control_plane_count = 3
worker_count = 3

node_network = "192.168.10.0/24"

cluster_endpoint = "192.168.10.10"

metallb_pool_start = "192.168.10.200"
metallb_pool_end   = "192.168.10.220"
```

---

# GitHub Actions

Generate complete workflows.

## terraform-plan.yml

Triggers:

```yaml
pull_request
```

Runs:

```bash
terraform fmt
terraform validate
terraform plan
```

Stores plan artifact.

---

## terraform-apply.yml

Triggers:

```yaml
push:
  branches:
    - main
```

Runs:

```bash
terraform apply -auto-approve
```

Use GitHub Secrets.

---

## terraform-destroy.yml

Manual trigger only:

```yaml
workflow_dispatch
```

Requires confirmation variable:

```yaml
DESTROY_CLUSTER=true
```

Runs:

```bash
terraform destroy -auto-approve
```

---

# Security

Do NOT hardcode:

* passwords
* API tokens
* kubeconfig

Use:

```yaml
GitHub Secrets
```

and Terraform sensitive variables.

---

# Outputs

Generate:

```hcl
control_plane_ips
worker_ips
cluster_endpoint
kubeconfig_path
talosconfig_path
```

---

# README

Generate a complete README containing:

1. Architecture diagram (Mermaid)
2. Prerequisites
3. Talos image preparation
4. Proxmox requirements
5. GitHub setup
6. Local deployment
7. Scaling workers
8. Destroying cluster
9. Troubleshooting
10. Upgrade strategy

---

# Code Quality Requirements

Generate actual Terraform code.

Do not generate placeholders like:

```hcl
# TODO
```

Do not omit files.

Every file listed must contain working code.

All resources must be interconnected correctly.

The final output should be a complete repository tree followed by the contents of every file.

Assume the latest stable versions of Terraform providers available at generation time.

---

Additionally, before generating the codebase, provide a short architecture explanation and identify any assumptions that need to be adjusted for different Proxmox environments (storage pool names, VM template IDs, network bridges, etc.).
