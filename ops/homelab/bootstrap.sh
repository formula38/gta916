#!/usr/bin/env bash
set -euo pipefail

# GTA916 homelab bootstrap: scaffolds the runtime layout and downloads the
# latest RECOMMENDED FXServer build from the official artifact listing.
#
# Usage: ./bootstrap.sh [base_dir]
#   base_dir defaults to ~/gta916
#
# After this script, follow the printed next steps (first boot creates the
# txAdmin profile; then run wire-profile.sh to install configs + resources).

BASE_DIR="${1:-$HOME/gta916}"
SERVER_DIR="${BASE_DIR}/server"
TXDATA_DIR="${BASE_DIR}/txData"
ARTIFACTS_URL="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"

echo "Preparing GTA916 homelab layout at: ${BASE_DIR}"

# NOTE: do NOT pre-create ${TXDATA_DIR}/default. txAdmin v8 creates the
# profile on first boot and fails with error E5110 if the profile folder
# exists without a config.json inside it.
mkdir -p "${SERVER_DIR}" "${TXDATA_DIR}"

if [ -f "${SERVER_DIR}/run.sh" ]; then
  echo "FXServer already present in ${SERVER_DIR}, skipping download."
else
  echo "Finding latest RECOMMENDED build from ${ARTIFACTS_URL} ..."
  # The 'latest' shortcut URL no longer exists; parse the listing instead.
  # The recommended build is the anchor styled with the 'is-primary' class.
  build_id="$(curl -fsSL "${ARTIFACTS_URL}" | tr -d '\n' \
    | grep -o 'href= *"\./[0-9]*-[a-f0-9]*/fx\.tar\.xz" *class="button is-link is-primary"' \
    | grep -o '[0-9]*-[a-f0-9]*' | head -1 || true)"

  if [ -z "${build_id}" ]; then
    echo "Could not auto-detect the recommended build." >&2
    echo "Download fx.tar.xz manually from ${ARTIFACTS_URL} and extract into ${SERVER_DIR}" >&2
    exit 1
  fi

  echo "Downloading build ${build_id} ..."
  curl -fSL "${ARTIFACTS_URL}${build_id}/fx.tar.xz" -o "${BASE_DIR}/fx.tar.xz"
  tar -xf "${BASE_DIR}/fx.tar.xz" -C "${SERVER_DIR}"
  echo "${build_id}" > "${SERVER_DIR}/ARTIFACT_VERSION"
  echo "Extracted FXServer build ${build_id} into ${SERVER_DIR}"
fi

cat <<EOF

Next steps:
1) First boot (txAdmin creates the profile and prints a registration PIN):
   ./ops/homelab/start-server.sh ${BASE_DIR}
2) Open http://localhost:40120, enter the PIN, link your Cfx.re account.
3) Wire repo configs + resources into the profile:
   ./ops/homelab/wire-profile.sh ${BASE_DIR}
4) Fill real secrets in ${TXDATA_DIR}/default/server.cfg.local
   (sv_licenseKey now; sv_tebexSecret in Phase 2).
5) Restart the server and run docs/setup/private-smoke-tests.md.
EOF

echo "Scaffold complete."
