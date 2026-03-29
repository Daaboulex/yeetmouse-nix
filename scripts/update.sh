#!/usr/bin/env bash
set -euo pipefail

# Update script for yeetmouse-nix
# Tracks upstream AndyFilter/YeetMouse commits
# Contract: exit 0 = success/no-update, exit 1 = failed, exit 2 = network error

OUTPUT_FILE="${GITHUB_OUTPUT:-/tmp/update-outputs.env}"
: > "$OUTPUT_FILE"

output() { echo "$1=$2" >> "$OUTPUT_FILE"; }
log() { echo "==> $*"; }
warn() { echo "::warning::$*"; }
err() { echo "::error::$*"; }

output "package_name" "yeetmouse"

CURRENT_REV=$(jq -r '.rev' version.json)
output "old_version" "${CURRENT_REV:0:7}"
log "Current: ${CURRENT_REV:0:7}"

LATEST_REV=$(curl -sfL 'https://api.github.com/repos/AndyFilter/YeetMouse/commits/master' | jq -r '.sha') || {
  warn "Failed to fetch latest YeetMouse commit"
  output "updated" "false"
  exit 2
}

log "Latest: ${LATEST_REV:0:7}"
output "upstream_url" "https://github.com/AndyFilter/YeetMouse/commit/${LATEST_REV}"

if [ "$CURRENT_REV" = "$LATEST_REV" ]; then
  log "Already up to date"
  output "updated" "false"
  exit 0
fi

log "Update found"
output "updated" "true"
output "new_version" "${LATEST_REV:0:7}"

DATE=$(date +%Y-%m-%d)
jq --arg r "$LATEST_REV" --arg v "${LATEST_REV:0:7}" --arg d "$DATE" \
  '.rev = $r | .version = $v | .date = $d' \
  version.json > version.json.tmp && mv version.json.tmp version.json

nix flake update yeetmouse-src

log "Step 1/2: Eval check"
if ! nix flake check --no-build 2>&1; then
  err "Eval check failed after update"
  output "error_type" "eval-error"
  exit 1
fi

log "Step 2/2: Build"
if ! nix build .#default --no-link --print-build-logs 2>&1; then
  err "Build failed after update"
  output "error_type" "build-error"
  exit 1
fi

log "Update verified: ${CURRENT_REV:0:7} → ${LATEST_REV:0:7}"
exit 0
