#!/usr/bin/env bash
set -euo pipefail

# packages/code/bin -> dotfiles repo root
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STDIN_FILEPATH="${1:-f.txt}"

OXFMT="${OXFMT:-$HOME/.local/share/mise/shims/oxfmt}"
if [[ ! -x "$OXFMT" ]]; then
  OXFMT="$(command -v oxfmt || true)"
fi
if [[ -z "$OXFMT" || ! -x "$OXFMT" ]]; then
  OXFMT="${ROOT}/node_modules/.bin/oxfmt"
fi

exec "$OXFMT" -c "${ROOT}/oxfmt.config.ts" --stdin-filepath "${STDIN_FILEPATH}"
