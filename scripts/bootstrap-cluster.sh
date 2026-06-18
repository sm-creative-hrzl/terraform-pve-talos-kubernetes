#!/usr/bin/env bash
###############################################################################
# bootstrap-cluster.sh
#
# One-shot helper that stands up the entire cluster from scratch:
#   terraform init -> validate -> plan -> apply
#
# Usage:
#   ./scripts/bootstrap-cluster.sh [--auto-approve]
#
# Requires: terraform >= 1.9, a populated terraform.tfvars, and (for secrets)
# the TF_VAR_pve_token_id / TF_VAR_pve_token_secret env vars.
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

AUTO_APPROVE=""
if [[ "${1:-}" == "--auto-approve" ]]; then
  AUTO_APPROVE="-auto-approve"
fi

if [[ ! -f terraform.tfvars ]]; then
  echo "ERROR: terraform.tfvars not found. Copy terraform.tfvars.example and edit it." >&2
  exit 1
fi

echo "==> terraform init"
terraform init -input=false

echo "==> terraform fmt (advisory, non-blocking)"
# Intentionally non-fatal: a formatting nit shouldn't stop a bring-up. The
# trailing `|| true` makes that explicit under `set -e`.
terraform fmt -recursive -check ||
  echo "NOTE: formatting issues found; run 'terraform fmt -recursive' to fix." >&2 || true

echo "==> terraform validate"
terraform validate

echo "==> terraform plan"
terraform plan -input=false -out=tfplan

echo "==> terraform apply"
# Applying a saved plan file is already non-interactive, so honour
# --auto-approve ourselves: without it, confirm before touching infrastructure.
if [[ -z "${AUTO_APPROVE}" ]]; then
  read -r -p "Apply the plan above? [y/N] " reply
  if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
    echo "Aborted. Saved plan left at ./tfplan." >&2
    exit 1
  fi
fi
terraform apply -input=false tfplan

echo
echo "==> Cluster bootstrapped. Fetching credentials..."
"${REPO_ROOT}/scripts/kubeconfig.sh"
"${REPO_ROOT}/scripts/generate-talconfig.sh"

echo
echo "Done. Try:"
echo "  export KUBECONFIG=${REPO_ROOT}/kubeconfig"
echo "  kubectl get nodes -o wide"
