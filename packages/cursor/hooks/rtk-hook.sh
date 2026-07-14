#!/usr/bin/env bash
# Cursor preToolUse: exec mise shim `rtk` (PATH 非依存).
set -u

RTK="${RTK:-$HOME/.local/share/mise/shims/rtk}"
if [[ ! -x "$RTK" ]]; then
  echo "rtk-hook (cursor): $RTK が実行できません。make mise-tools（packages/mise/config.toml の rtk）でインストールしてください。" >&2
  exit 1
fi

exec "$RTK" hook cursor
