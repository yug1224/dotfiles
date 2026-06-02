#!/usr/bin/env bash
set -euo pipefail

# packages/code/bin -> dotfiles repo root
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STDIN_FILEPATH="${1:-f.txt}"

exec "${ROOT}/node_modules/.bin/oxfmt" -c "${ROOT}/oxfmt.config.ts" --stdin-filepath "${STDIN_FILEPATH}"
