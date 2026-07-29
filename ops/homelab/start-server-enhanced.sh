#!/usr/bin/env bash
set -euo pipefail

# Starts Cfx Server (FiveM for GTAV Enhanced) with its own txAdmin data path.
#
# Usage: ./start-server-enhanced.sh [base_dir]
#   base_dir defaults to ~/gta916
#
# Uses the same ports as the legacy stack (30120 game, 40120 txAdmin), so
# stop the legacy server first - only one of the two runs at a time.

BASE_DIR="${1:-$HOME/gta916}"
SERVER_DIR="${BASE_DIR}/server-enhanced"

if [ ! -f "${SERVER_DIR}/run.sh" ]; then
  echo "Cfx Server not found in ${SERVER_DIR}. Run bootstrap-enhanced.sh first." >&2
  exit 1
fi

cd "${SERVER_DIR}"
exec env TXHOST_DATA_PATH="${BASE_DIR}/txData-enhanced" ./run.sh
