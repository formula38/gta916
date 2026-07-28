#!/usr/bin/env bash
set -euo pipefail

# Starts FXServer/txAdmin with the correct data path.
#
# Usage: ./start-server.sh [base_dir]
#   base_dir defaults to ~/gta916
#
# txAdmin v8 note: '+set serverProfile' and '+set txAdminPort' are deprecated.
# The supported way to pick the data location is the TXHOST_DATA_PATH env var
# (and TXHOST_TXA_PORT for a custom panel port).

BASE_DIR="${1:-$HOME/gta916}"
SERVER_DIR="${BASE_DIR}/server"

if [ ! -f "${SERVER_DIR}/run.sh" ]; then
  echo "FXServer not found in ${SERVER_DIR}. Run bootstrap.sh first." >&2
  exit 1
fi

cd "${SERVER_DIR}"
exec env TXHOST_DATA_PATH="${BASE_DIR}/txData" ./run.sh
