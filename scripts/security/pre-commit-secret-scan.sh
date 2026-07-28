#!/usr/bin/env bash
set -euo pipefail

# Scan staged content for likely secrets before commit.
# Uses gitleaks if installed; otherwise falls back to focused regex checks.

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! git diff --cached --quiet; then
  :
else
  exit 0
fi

if command -v gitleaks >/dev/null 2>&1; then
  echo "[secret-scan] Running gitleaks on staged changes..."
  # --no-git avoids scanning full history and focuses on workspace snapshot.
  gitleaks detect --no-git --redact --source . >/dev/null
  exit 0
fi

echo "[secret-scan] gitleaks not found, running fallback pattern scan..."

staged_files="$(git diff --cached --name-only --diff-filter=ACMRT)"
if [ -z "$staged_files" ]; then
  exit 0
fi

content="$(git diff --cached --unified=0 -- $staged_files)"

# Focused patterns to minimize false positives while catching real leaks.
patterns=(
  'cfxk_[A-Za-z0-9_]{20,}'
  'sv_tebexSecret[[:space:]]+"[^"]{8,}"'
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  '-----BEGIN (RSA|EC|OPENSSH|DSA|PGP) PRIVATE KEY-----'
)

for pattern in "${patterns[@]}"; do
  if printf '%s\n' "$content" | rg -n -e "$pattern" >/dev/null 2>&1; then
    echo "[secret-scan] Possible secret detected in staged changes."
    echo "[secret-scan] Pattern: $pattern"
    echo "[secret-scan] Commit blocked. Move secrets to local-only files."
    exit 1
  fi
done

exit 0
