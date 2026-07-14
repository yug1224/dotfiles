#!/usr/bin/env bash
# Cursor Hooks beforeShellExecution adapter for the shared guard-shell.
#
# Delegates stdin/stdout (Cursor JSON: { command, cwd, sandbox }) to the single
# implementation at ~/.config/shared/ai/hooks/guard-shell.sh.
set -u

SHARED_GUARD="${HOME}/.config/shared/ai/hooks/guard-shell.sh"
if [[ ! -f "$SHARED_GUARD" ]]; then
  printf '%s\n' '{"permission":"deny","user_message":"guard-shell (cursor adapter): ~/.config/shared/ai/hooks/guard-shell.sh が見つかりません","agent_message":"dotfiles で make mise-dotfiles を実行し、~/.config/shared が展開されているか確認してください。"}'
  exit 0
fi

exec "$SHARED_GUARD"
