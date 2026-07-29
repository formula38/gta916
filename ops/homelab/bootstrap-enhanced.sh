#!/usr/bin/env bash
set -euo pipefail

# GTA916 homelab bootstrap for FiveM for GTAV ENHANCED (early access).
#
# Enhanced ships a new server component called "Cfx Server". It is published
# on the official Server Download page (not the legacy artifacts listing),
# and the Linux archive is named cfx-server_linux_x64.tar.xz instead of
# fx.tar.xz. txAdmin is still embedded, so the flow matches the legacy one.
#
# This creates a PARALLEL runtime next to the legacy one:
#   ~/gta916/server-enhanced/   - Cfx Server binaries
#   ~/gta916/txData-enhanced/   - txAdmin data (own profile, own PIN setup)
# The legacy server/ and txData/ folders are left untouched as a fallback.
#
# Usage: ./bootstrap-enhanced.sh [base_dir]
#   base_dir defaults to ~/gta916

BASE_DIR="${1:-$HOME/gta916}"
SERVER_DIR="${BASE_DIR}/server-enhanced"
TXDATA_DIR="${BASE_DIR}/txData-enhanced"
DOWNLOAD_PAGE="https://docs.fivem.net/docs/server-download/"

echo "Preparing GTA916 ENHANCED runtime at: ${BASE_DIR}"

# Same rule as legacy: never pre-create the profile folder itself, txAdmin
# creates it on first boot (E5110 otherwise).
mkdir -p "${SERVER_DIR}" "${TXDATA_DIR}"

if [ -f "${SERVER_DIR}/run.sh" ]; then
  echo "Cfx Server already present in ${SERVER_DIR}, skipping download."
else
  echo "Finding current Enhanced Linux build from ${DOWNLOAD_PAGE} ..."
  # The download page embeds the direct downloads.cfx-services.net URL for
  # the current early-access build.
  artifact_url="$(curl -fsSL "${DOWNLOAD_PAGE}" \
    | grep -o 'https://[^"'\'' ]*cfx-server_linux_x64\.tar\.xz' | head -1 || true)"

  if [ -z "${artifact_url}" ]; then
    echo "Could not auto-detect the Enhanced server build." >&2
    echo "Open ${DOWNLOAD_PAGE}, switch Platform to 'FiveM for GTAV Enhanced'," >&2
    echo "download cfx-server_linux_x64.tar.xz and extract it into ${SERVER_DIR}" >&2
    exit 1
  fi

  echo "Downloading ${artifact_url} ..."
  # Resumable download: abort if speed drops below 10 KB/s for 30s (CDN
  # stalls happen), then retry and continue from where it left off.
  curl -fSL --retry 10 --retry-delay 3 --retry-all-errors \
    --speed-limit 10240 --speed-time 30 --continue-at - \
    "${artifact_url}" -o "${BASE_DIR}/cfx-server_linux_x64.tar.xz"
  tar -xf "${BASE_DIR}/cfx-server_linux_x64.tar.xz" -C "${SERVER_DIR}"
  echo "${artifact_url}" > "${SERVER_DIR}/ARTIFACT_SOURCE"

  if [ ! -f "${SERVER_DIR}/run.sh" ]; then
    echo "WARNING: run.sh not found after extraction - archive layout may have changed:" >&2
    ls -la "${SERVER_DIR}" >&2
    exit 1
  fi
  echo "Extracted Cfx Server (Enhanced) into ${SERVER_DIR}"
fi

cat <<EOF

Next steps (Enhanced):
1) Stop the legacy server if it is running (same 30120/40120 ports).
2) First boot (txAdmin creates the profile and prints a registration PIN):
   ./ops/homelab/start-server-enhanced.sh ${BASE_DIR}
3) Open http://localhost:40120, enter the PIN, link your Cfx.re account.
4) Wire repo configs + resources into the Enhanced profile:
   ./ops/homelab/wire-profile.sh ${BASE_DIR} default txData-enhanced
5) Fill real secrets in ${TXDATA_DIR}/default/server.cfg.local
6) Restart and run docs/setup/private-smoke-tests.md.

See docs/setup/gtav-enhanced.md for early-access caveats and client setup.
EOF

echo "Enhanced scaffold complete."
