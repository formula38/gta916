#!/usr/bin/env bash
set -euo pipefail

# Local scaffold helper for GTA916 homelab layout.
# This script does not download artifacts automatically because artifact URLs rotate.

BASE_DIR="${1:-$HOME/gta916}"
SERVER_DIR="${BASE_DIR}/server"
TXDATA_DIR="${BASE_DIR}/txData"
PROFILE="default"

echo "Preparing GTA916 homelab layout at: ${BASE_DIR}"
mkdir -p "${SERVER_DIR}" "${TXDATA_DIR}/${PROFILE}"

echo "Creating placeholder files if missing..."
touch "${TXDATA_DIR}/${PROFILE}/server.cfg"

cat <<'EOF'
Next steps:
1) Download latest recommended Linux FXServer artifact from official runtime listing.
2) Extract artifact contents into:
   ${SERVER_DIR}
3) Copy template config from repo:
   ops/homelab/server.cfg.template -> ${TXDATA_DIR}/${PROFILE}/server.cfg
4) Fill local secrets:
   - sv_licenseKey
   - database connection string (if needed)
5) Start server from artifact directory:
   ./run.sh +set serverProfile default
6) Open txAdmin:
   http://localhost:40120
EOF

echo "Scaffold complete."
