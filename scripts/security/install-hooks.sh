#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
hook_source="$repo_root/.githooks/pre-commit"
hook_target="$repo_root/.git/hooks/pre-commit"

if [ ! -f "$hook_source" ]; then
  echo "Missing hook source: $hook_source" >&2
  exit 1
fi

cp "$hook_source" "$hook_target"
chmod +x "$hook_target"
chmod +x "$repo_root/scripts/security/pre-commit-secret-scan.sh"

echo "Installed pre-commit hook at: $hook_target"
