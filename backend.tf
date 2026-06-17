###############################################################################
# State backend — MinIO (S3-compatible)
#
# Credentials are supplied via environment variables — never hardcoded:
#   AWS_ACCESS_KEY_ID     → GitHub Actions variable  : MINIO_ACCESS_KEY
#   AWS_SECRET_ACCESS_KEY → GitHub Actions secret    : MINIO_SECRET_KEY
#
# To migrate an existing local state:
#   terraform init -migrate-state
###############################################################################

terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "talos-k8s/terraform.tfstate"

    # MinIO requires path-style access and an explicit endpoint.
    # Terraform >= 1.6 uses the endpoints block instead of the legacy endpoint arg.
    endpoints = {
      s3 = "http://10.10.20.205:19000"
    }

    # Any non-empty string satisfies the region requirement for MinIO.
    region = "us-east-1"

    use_path_style = true

    # MinIO does not implement these AWS-specific API calls.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
