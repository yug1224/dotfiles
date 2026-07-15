#!/usr/bin/env bash
# Verify Cursor/Claude thin wrappers exist for shared AI artifacts.
# Exceptions: conventions/output-verification-rule (command-direct @import).
# Ignores *.local.* overlays.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_RULES="${ROOT}/packages/shared/ai/rules"
SHARED_CMDS="${ROOT}/packages/shared/ai/commands"
SHARED_AGENTS="${ROOT}/packages/shared/ai/agents"
CURSOR="${ROOT}/packages/cursor"
CLAUDE="${ROOT}/packages/claude"

EXCEPTIONS_FILE="${ROOT}/scripts/wrapper-exceptions.txt"

is_exception() {
  local id="$1" line
  [[ -f "$EXCEPTIONS_FILE" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == "$id" ]] && return 0
  done <"$EXCEPTIONS_FILE"
  return 1
}

failed=0

check_import() {
  local file="$1" expected="$2"
  if ! grep -qF "$expected" "$file"; then
    echo "FAIL: $file missing import $expected" >&2
    failed=1
  fi
}

# --- rules ---
while IFS= read -r -d '' shared; do
  rel="${shared#"$SHARED_RULES"/}"
  id="${rel%.md}"
  [[ "$id" == *.local ]] && continue
  is_exception "$id" && continue

  cursor_file="${CURSOR}/rules/${id}.mdc"
  claude_file="${CLAUDE}/rules/${id}.md"
  expected="@~/.config/shared/ai/rules/${id}.md"

  if [[ ! -f "$cursor_file" ]]; then
    echo "FAIL: missing Cursor wrapper: packages/cursor/rules/${id}.mdc" >&2
    failed=1
  else
    check_import "$cursor_file" "$expected"
  fi
  if [[ ! -f "$claude_file" ]]; then
    echo "FAIL: missing Claude wrapper: packages/claude/rules/${id}.md" >&2
    failed=1
  else
    check_import "$claude_file" "$expected"
  fi
done < <(find "$SHARED_RULES" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

# Extra wrappers without shared SoT
while IFS= read -r -d '' cursor_file; do
  rel="${cursor_file#"$CURSOR"/rules/}"
  id="${rel%.mdc}"
  [[ "$id" == *.local ]] && continue
  shared="${SHARED_RULES}/${id}.md"
  if [[ ! -f "$shared" ]] && ! is_exception "$id"; then
    echo "FAIL: Cursor wrapper without shared SoT: packages/cursor/rules/${id}.mdc" >&2
    failed=1
  fi
done < <(find "$CURSOR/rules" -type f -name '*.mdc' ! -name '*.local.mdc' -print0 | sort -z)

while IFS= read -r -d '' claude_file; do
  rel="${claude_file#"$CLAUDE"/rules/}"
  id="${rel%.md}"
  [[ "$id" == *.local ]] && continue
  shared="${SHARED_RULES}/${id}.md"
  if [[ ! -f "$shared" ]] && ! is_exception "$id"; then
    echo "FAIL: Claude wrapper without shared SoT: packages/claude/rules/${id}.md" >&2
    failed=1
  fi
done < <(find "$CLAUDE/rules" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

# --- commands ---
while IFS= read -r -d '' shared; do
  base="$(basename "$shared" .md)"
  [[ "$base" == *.local ]] && continue
  expected="@~/.config/shared/ai/commands/${base}.md"
  cursor_file="${CURSOR}/commands/${base}.md"
  claude_file="${CLAUDE}/commands/${base}.md"
  if [[ ! -f "$cursor_file" ]]; then
    echo "FAIL: missing Cursor command wrapper: packages/cursor/commands/${base}.md" >&2
    failed=1
  else
    check_import "$cursor_file" "$expected"
  fi
  if [[ ! -f "$claude_file" ]]; then
    echo "FAIL: missing Claude command wrapper: packages/claude/commands/${base}.md" >&2
    failed=1
  else
    check_import "$claude_file" "$expected"
  fi
done < <(find "$SHARED_CMDS" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

while IFS= read -r -d '' cursor_file; do
  base="$(basename "$cursor_file" .md)"
  [[ "$base" == *.local ]] && continue
  shared="${SHARED_CMDS}/${base}.md"
  if [[ ! -f "$shared" ]]; then
    echo "FAIL: Cursor command wrapper without shared SoT: packages/cursor/commands/${base}.md" >&2
    failed=1
  fi
done < <(find "$CURSOR/commands" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

while IFS= read -r -d '' claude_file; do
  base="$(basename "$claude_file" .md)"
  [[ "$base" == *.local ]] && continue
  shared="${SHARED_CMDS}/${base}.md"
  if [[ ! -f "$shared" ]]; then
    echo "FAIL: Claude command wrapper without shared SoT: packages/claude/commands/${base}.md" >&2
    failed=1
  fi
done < <(find "$CLAUDE/commands" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

# --- agents ---
while IFS= read -r -d '' shared; do
  base="$(basename "$shared" .md)"
  [[ "$base" == *.local ]] && continue
  expected="@~/.config/shared/ai/agents/${base}.md"
  cursor_file="${CURSOR}/agents/${base}.md"
  claude_file="${CLAUDE}/agents/${base}.md"
  if [[ ! -f "$cursor_file" ]]; then
    echo "FAIL: missing Cursor agent wrapper: packages/cursor/agents/${base}.md" >&2
    failed=1
  else
    check_import "$cursor_file" "$expected"
  fi
  if [[ ! -f "$claude_file" ]]; then
    echo "FAIL: missing Claude agent wrapper: packages/claude/agents/${base}.md" >&2
    failed=1
  else
    check_import "$claude_file" "$expected"
  fi
done < <(find "$SHARED_AGENTS" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

while IFS= read -r -d '' cursor_file; do
  base="$(basename "$cursor_file" .md)"
  [[ "$base" == *.local ]] && continue
  shared="${SHARED_AGENTS}/${base}.md"
  if [[ ! -f "$shared" ]]; then
    echo "FAIL: Cursor agent wrapper without shared SoT: packages/cursor/agents/${base}.md" >&2
    failed=1
  fi
done < <(find "$CURSOR/agents" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

while IFS= read -r -d '' claude_file; do
  base="$(basename "$claude_file" .md)"
  [[ "$base" == *.local ]] && continue
  shared="${SHARED_AGENTS}/${base}.md"
  if [[ ! -f "$shared" ]]; then
    echo "FAIL: Claude agent wrapper without shared SoT: packages/claude/agents/${base}.md" >&2
    failed=1
  fi
done < <(find "$CLAUDE/agents" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

if [[ "$failed" -eq 0 ]]; then
  echo "ok: wrapper parity (rules/commands/agents)"
  exit 0
fi
exit 1
