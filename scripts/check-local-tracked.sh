#!/usr/bin/env bash
# Fail when git tracks any *.local.* path (overlay must stay out of Git).
# Does not read file contents or scan $HOME / ~/.config.
# Usage: ./scripts/check-local-tracked.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

while IFS= read -r path; do
  if [[ "$path" == *".local."* ]]; then
    echo "FAIL: tracked local overlay: $path" >&2
    FAIL=1
  fi
done < <(git -C "$ROOT" ls-files)

if [[ $FAIL -eq 0 ]]; then
  echo "ok: no tracked *.local.* files"
fi
exit "$FAIL"
