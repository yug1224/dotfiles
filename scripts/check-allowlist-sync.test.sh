#!/usr/bin/env bash
# Minimal regression tests for check-allowlist-sync.sh (normalize + exact + exceptions).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/scripts/check-allowlist-sync.sh"
FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT

fail=0

run_case() {
  CURSOR_PERMS="$FIX/cursor.json" \
    CLAUDE_SETTINGS="$FIX/claude.json" \
    MCP_EXCEPTIONS="$1" \
    REQUIRE_JQ=1 \
    "$SCRIPT"
}

cat >"$FIX/cursor.json" <<'EOF'
{
  "terminalAllowlist": ["git status", "gh pr view"],
  "mcpAllowlist": [
    "github:get_*",
    "user-github:list_*",
    "Playwright:browser_click",
    "codegraph:*"
  ]
}
EOF

cat >"$FIX/claude.json" <<'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(gh pr view:*)",
      "mcp__github__get_*",
      "mcp__user-github__list_*",
      "mcp__codegraph__*"
    ],
    "deny": []
  }
}
EOF

cat >"$FIX/exceptions.txt" <<'EOF'
only_cursor|Playwright:browser_click
EOF

cat >"$FIX/exceptions-empty.txt" <<'EOF'
# none
EOF

echo "== case1: synced + Playwright exception =="
if run_case "$FIX/exceptions.txt"; then
  echo "ok: case1"
else
  echo "FAIL: case1 expected pass" >&2
  fail=1
fi

echo "== case2: missing MCP without exception =="
if run_case "$FIX/exceptions-empty.txt"; then
  echo "FAIL: case2 expected fail" >&2
  fail=1
else
  echo "ok: case2"
fi

echo "== case3: intentional drift fails =="
jq '.mcpAllowlist += ["notion:notion-fetch"]' "$FIX/cursor.json" >"$FIX/cursor2.json"
mv "$FIX/cursor2.json" "$FIX/cursor.json"
if run_case "$FIX/exceptions.txt"; then
  echo "FAIL: case3 expected fail" >&2
  fail=1
else
  echo "ok: case3"
fi

echo "== case4: user-github alias normalizes =="
cat >"$FIX/cursor.json" <<'EOF'
{
  "terminalAllowlist": ["git status"],
  "mcpAllowlist": ["user-github:get_*"]
}
EOF
cat >"$FIX/claude.json" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git status:*)", "mcp__github__get_*"],
    "deny": []
  }
}
EOF
if run_case "$FIX/exceptions-empty.txt"; then
  echo "ok: case4"
else
  echo "FAIL: case4 expected pass (user-github ↔ github)" >&2
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "ok: check-allowlist-sync.test.sh"
  exit 0
fi
exit 1
