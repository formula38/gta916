#!/usr/bin/env bash
set -euo pipefail

# Wires the GTA916 repo into an existing txAdmin profile:
# - installs server.cfg from the sanitized template (if not present)
# - installs server.cfg.local from the example (if not present)
# - symlinks the repo resources category for a live dev loop
#
# Usage: ./wire-profile.sh [base_dir] [profile]
#   base_dir defaults to ~/gta916, profile defaults to 'default'
#
# Run this AFTER the first txAdmin boot (the profile must already exist).

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BASE_DIR="${1:-$HOME/gta916}"
PROFILE="${2:-default}"
PROFILE_DIR="${BASE_DIR}/txData/${PROFILE}"

if [ ! -d "${PROFILE_DIR}" ]; then
  echo "Profile not found: ${PROFILE_DIR}" >&2
  echo "Boot txAdmin once first so it creates the profile (see start-server.sh)." >&2
  exit 1
fi

if [ -f "${PROFILE_DIR}/server.cfg" ] && [ -s "${PROFILE_DIR}/server.cfg" ]; then
  echo "Keeping existing server.cfg (delete it to reinstall from template)."
else
  cp "${REPO_ROOT}/ops/homelab/server.cfg.template" "${PROFILE_DIR}/server.cfg"
  echo "Installed server.cfg from template."
fi

if [ -f "${PROFILE_DIR}/server.cfg.local" ]; then
  echo "Keeping existing server.cfg.local."
else
  cp "${REPO_ROOT}/ops/homelab/server.cfg.local.example" "${PROFILE_DIR}/server.cfg.local"
  echo "Installed server.cfg.local from example - FILL IN YOUR REAL KEY."
fi

mkdir -p "${PROFILE_DIR}/resources"
ln -sfn "${REPO_ROOT}/resources/[gta916]" "${PROFILE_DIR}/resources/[gta916]"
echo "Symlinked repo resources: ${PROFILE_DIR}/resources/[gta916] -> ${REPO_ROOT}/resources/[gta916]"

echo "Profile wired. Edit ${PROFILE_DIR}/server.cfg.local, then start the server."
