#!/usr/bin/env bash
set -euo pipefail

# Starts the GTA916 MariaDB container (gameplay OLTP store - see
# docs/strategy/gta916-roadmap-whitepaper.md "Data architecture").
#
# Usage: ./start-db.sh [base_dir]
#   base_dir defaults to ~/gta916
#
# First run: generates credentials into ${BASE_DIR}/.mariadb.env (never
# committed - lives outside the repo) and creates the container with a
# persistent data dir. Later runs: just starts the existing container.
#
# The oxmysql connection string for server.cfg.local is printed at the end.

BASE_DIR="${1:-$HOME/gta916}"
ENV_FILE="${BASE_DIR}/.mariadb.env"
DATA_DIR="${BASE_DIR}/mariadb-data"
CONTAINER="gta916-mariadb"
IMAGE="mariadb:11.4"

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "MariaDB container already running."
elif docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Starting existing MariaDB container..."
  docker start "${CONTAINER}"
else
  echo "Creating MariaDB container (first run)..."
  mkdir -p "${DATA_DIR}"

  if [ ! -f "${ENV_FILE}" ]; then
    root_pw="$(openssl rand -hex 16)"
    qb_pw="$(openssl rand -hex 16)"
    umask 177
    cat > "${ENV_FILE}" <<EOF
MARIADB_ROOT_PASSWORD=${root_pw}
MARIADB_DATABASE=gta916
MARIADB_USER=qbcore
MARIADB_PASSWORD=${qb_pw}
EOF
    umask 022
    echo "Generated credentials in ${ENV_FILE} (mode 600, not in repo)."
  fi

  docker run -d \
    --name "${CONTAINER}" \
    --restart unless-stopped \
    --env-file "${ENV_FILE}" \
    -p 127.0.0.1:3306:3306 \
    -v "${DATA_DIR}:/var/lib/mysql" \
    "${IMAGE}"
fi

echo "Waiting for MariaDB to accept connections..."
for i in $(seq 1 30); do
  if docker exec "${CONTAINER}" healthcheck.sh --connect >/dev/null 2>&1 \
     || docker exec "${CONTAINER}" mariadb-admin ping --silent >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

# shellcheck disable=SC1090
source "${ENV_FILE}"
echo
echo "MariaDB ready on 127.0.0.1:3306 (db: ${MARIADB_DATABASE}, user: ${MARIADB_USER})"
echo "oxmysql connection string for server.cfg.local:"
echo "  set mysql_connection_string \"mysql://${MARIADB_USER}:${MARIADB_PASSWORD}@127.0.0.1/${MARIADB_DATABASE}?charset=utf8mb4\""
