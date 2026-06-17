#!/usr/bin/env bash
###############################################################################
# generate-talconfig.sh
#
# Writes the talosconfig from Terraform outputs to ./talosconfig so you can use
# talosctl directly for day-2 operations (upgrades, dashboards, etc.).
#
# Usage:
#   ./scripts/generate-talconfig.sh [output-path]
#
# Then, e.g.:
#   talosctl --talosconfig ./talosconfig -n <node-ip> dashboard
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OUT="${1:-${REPO_ROOT}/talosconfig}"

echo "==> Writing talosconfig to ${OUT}"
terraform output -raw talosconfig > "${OUT}"
chmod 600 "${OUT}"

echo "Done. Example usage:"
echo "  talosctl --talosconfig ${OUT} -e <cp-ip> -n <cp-ip> health"
echo "  talosctl --talosconfig ${OUT} -n <node-ip> dashboard"
