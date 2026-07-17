#!/bin/bash
# Claude Code PreToolUse adapter for the shared guard-shell.
#
# Reads Claude Code's hook JSON from stdin, extracts the Bash command,
# delegates to ~/.config/shared/ai/hooks/guard-shell.sh (Cursor-style {command} JSON),
# and translates the response to Claude Code's PreToolUse permission format.
#
# Stdin (Claude):  { "hook_event_name": "PreToolUse", "tool_name": "Bash",
#                    "tool_input": { "command": "...", ... }, ... }
# Stdout (Claude): { "hookSpecificOutput": {
#                     "hookEventName": "PreToolUse",
#                     "permissionDecision": "allow"|"ask"|"deny",
#                     "permissionDecisionReason": "..."
#                   } }
set -u

# GUI hook は login zsh の mise activate を通らないため shim を絶対指定
JQ="${JQ:-$HOME/.local/share/mise/shims/jq}"

if [[ ! -x "$JQ" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"guard-shell (claude adapter): jq が未インストール。make mise（packages/mise/config.toml の jq）でインストールしてください。"}}'
  exit 0
fi

input=$(cat)
tool=$(echo "$input" | "$JQ" -r '.tool_name // empty')

# Bash 以外は本フックの責務外 → そのまま通す
if [[ "$tool" != "Bash" ]]; then
  "$JQ" -n '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "allow" } }'
  exit 0
fi

# 共有ガードに Cursor 形式の入力で問い合わせ
result=$(echo "$input" \
  | "$JQ" '{ command: (.tool_input.command // ""), cwd: (.cwd // ""), sandbox: false }' \
  | "$HOME/.config/shared/ai/hooks/guard-shell.sh")

permission=$(echo "$result" | "$JQ" -r '.permission // "deny"')
message=$(echo "$result" | "$JQ" -r '[.user_message, .agent_message] | map(select(. != null and . != "")) | join(" / ")')

case "$permission" in
  allow|ask|deny) ;;
  *) permission="deny"; message="${message:-guard-shell adapter: 不正な permission 値}";;
esac

"$JQ" -n \
  --arg p "$permission" \
  --arg m "$message" \
  '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: $p, permissionDecisionReason: $m } }'
