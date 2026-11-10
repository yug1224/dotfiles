#!/bin/bash
# Claude Code PreToolUse adapter for the shared guard-shell.
# Cursor も Third-Party Imports で ~/.claude/settings.json のフックを読む。そのとき tool_name は Shell になる。
# Deny only. On allow, stay silent (exit 0, no output) so settings.json permissions
# and auto mode still decide; an explicit "allow" would skip the permission prompt.
set -u

if [[ -z "${JQ:-}" ]]; then
  if [[ -x "$HOME/.local/share/mise/shims/jq" ]]; then
    JQ="$HOME/.local/share/mise/shims/jq"
  else
    JQ="$(command -v jq || true)"
  fi
fi

deny() {
  # jq が壊れていても deny を出せるよう printf で組む
  local reason="${1//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

if [[ -z "$JQ" || ! -x "$JQ" ]]; then
  deny "guard-shell (claude adapter): jq が未インストール。make mise（packages/mise/config.toml の jq）でインストールしてください。"
fi

input=$(cat)
tool=$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null) \
  || deny "guard-shell (claude adapter): 入力 JSON を解釈できません（jq: ${JQ}）。"

[[ "$tool" == "Bash" || "$tool" == "Shell" ]] || exit 0

SHARED_GUARD="${HOME}/.config/shared/ai/hooks/guard-shell.sh"
if [[ ! -f "$SHARED_GUARD" ]]; then
  deny "guard-shell (claude adapter): ~/.config/shared/ai/hooks/guard-shell.sh が見つかりません。make mise を実行してください。"
fi

result=$(printf '%s' "$input" \
  | "$JQ" '{ command: (.tool_input.command // ""), cwd: (.cwd // ""), sandbox: false }' \
  | JQ="$JQ" "$SHARED_GUARD")

permission=$(printf '%s' "$result" | "$JQ" -r '.permission // "deny"' 2>/dev/null || echo deny)
[[ "$permission" == "allow" ]] && exit 0

message=$(printf '%s' "$result" | "$JQ" -r '[.user_message, .agent_message] | map(select(. != null and . != "")) | join(" / ")' 2>/dev/null || true)
deny "${message:-guard-shell: 破壊的コマンドのため拒否しました（git push / rm -rf / 破壊的な gh）。ユーザーに実行を依頼してください。}"
