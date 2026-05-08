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

if ! command -v jq &>/dev/null; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"guard-shell (claude adapter): jq が未インストール。brew install jq でインストールしてください。"}}'
  exit 0
fi

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

# Bash 以外は本フックの責務外 → そのまま通す
if [[ "$tool" != "Bash" ]]; then
  jq -n '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "allow" } }'
  exit 0
fi

# 共有ガードに Cursor 形式の入力で問い合わせ
result=$(echo "$input" \
  | jq '{ command: (.tool_input.command // ""), cwd: (.cwd // ""), sandbox: false }' \
  | "$HOME/.config/shared/ai/hooks/guard-shell.sh")

permission=$(echo "$result" | jq -r '.permission // "deny"')
message=$(echo "$result" | jq -r '[.user_message, .agent_message] | map(select(. != null and . != "")) | join(" / ")')

case "$permission" in
  allow|ask|deny) ;;
  *) permission="deny"; message="${message:-guard-shell adapter: 不正な permission 値}";;
esac

jq -n \
  --arg p "$permission" \
  --arg m "$message" \
  '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: $p, permissionDecisionReason: $m } }'
