###############################################################################
# State backend
#
# Defaults to a local backend so the repo is usable out-of-the-box. For team /
# GitOps usage, switch to a remote backend (commented examples below) and run
# `terraform init -migrate-state`.
###############################################################################

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  # ---------------------------------------------------------------------------
  # Example: S3-compatible backend (AWS S3, MinIO, Garage, ...)
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "homelab-terraform-state"
  #   key            = "talos-k8s/terraform.tfstate"
  #   region         = "us-east-1"
  #   endpoints      = { s3 = "https://minio.example.com" }
  #   use_path_style = true
  #   encrypt        = true
  # }
  #
  # ---------------------------------------------------------------------------
  # Example: Terraform / HCP / Scalr style cloud backend
  # ---------------------------------------------------------------------------
  # cloud {
  #   organization = "my-org"
  #   workspaces { name = "talos-homelab" }
  # }
}
