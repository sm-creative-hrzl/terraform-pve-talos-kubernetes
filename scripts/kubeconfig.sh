#!/usr/bin/env bash
###############################################################################
# kubeconfig.sh
#
# Writes the cluster kubeconfig from Terraform outputs to ./kubeconfig and
# prints the export line you need.
#
# Usage:
#   ./scripts/kubeconfig.sh [output-path]
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OUT="${1:-${REPO_ROOT}/kubeconfig}"

echo "==> Writing kubeconfig to ${OUT}"
terraform output -raw kubeconfig > "${OUT}"
chmod 600 "${OUT}"

echo "Done. Use it with:"
echo "  export KUBECONFIG=${OUT}"
echo "  kubectl get nodes"
