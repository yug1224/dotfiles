#!/usr/bin/env bash
# Create thin Cursor/Claude wrappers for shared AI artifacts.
# Usage: scaffold-wrappers.sh [--check]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_RULES="${ROOT}/packages/shared/ai/rules"
SHARED_CMDS="${ROOT}/packages/shared/ai/commands"
SHARED_AGENTS="${ROOT}/packages/shared/ai/agents"
CURSOR="${ROOT}/packages/cursor"
CLAUDE="${ROOT}/packages/claude"

CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

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

first_h1_or_basename() {
  local file="$1" fallback="$2" line
  line="$(head -n 20 "$file" 2>/dev/null | grep -m1 '^# ' | sed 's/^# //' || true)"
  if [[ -n "${line}" ]]; then
    printf '%s' "$line"
  else
    printf '%s' "$fallback"
  fi
}

# Prefer H1; otherwise basename. Never use ✅️: / blank / @import as description.
wrapper_description() {
  local file="$1" fallback="$2"
  first_h1_or_basename "$file" "$fallback"
}

write_if_missing() {
  local path="$1" content="$2"
  if [[ -f "$path" ]]; then
    return 0
  fi
  echo "CREATE: ${path#"$ROOT"/}"
  WOULD=1
  if [[ "$CHECK" -eq 1 ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" >"$path"
}

WOULD=0

# --- rules ---
while IFS= read -r -d '' shared; do
  rel="${shared#"$SHARED_RULES"/}"
  id="${rel%.md}"
  [[ "$id" == *.local ]] && continue
  is_exception "$id" && continue

  base="$(basename "$id")"
  desc="$(wrapper_description "$shared" "$base")"
  expected="@~/.config/shared/ai/rules/${id}.md"

  write_if_missing "${CURSOR}/rules/${id}.mdc" "---
description: ${desc}
globs: []
alwaysApply: false
---

${expected}
"
  write_if_missing "${CLAUDE}/rules/${id}.md" "${expected}
"
done < <(find "$SHARED_RULES" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

# --- commands ---
while IFS= read -r -d '' shared; do
  base="$(basename "$shared" .md)"
  [[ "$base" == *.local ]] && continue
  desc="$(wrapper_description "$shared" "$base")"
  expected="@~/.config/shared/ai/commands/${base}.md"
  body="---
name: ${base}
description: ${desc}
---

${expected}
"
  write_if_missing "${CURSOR}/commands/${base}.md" "$body"
  write_if_missing "${CLAUDE}/commands/${base}.md" "$body"
done < <(find "$SHARED_CMDS" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

# --- agents ---
while IFS= read -r -d '' shared; do
  base="$(basename "$shared" .md)"
  [[ "$base" == *.local ]] && continue
  desc="$(wrapper_description "$shared" "$base")"
  expected="@~/.config/shared/ai/agents/${base}.md"

  write_if_missing "${CURSOR}/agents/${base}.md" "---
name: ${base}
description: ${desc}
model: inherit
readonly: true
---

${expected}
"
  write_if_missing "${CLAUDE}/agents/${base}.md" "---
name: ${base}
description: ${desc}
model: inherit
tools: Read, Grep, Glob, WebFetch
---

${expected}
"
done < <(find "$SHARED_AGENTS" -type f -name '*.md' ! -name '*.local.md' -print0 | sort -z)

if [[ "$WOULD" -eq 1 ]]; then
  if [[ "$CHECK" -eq 1 ]]; then
    echo "FAIL: missing wrappers (run: make scaffold-wrappers)" >&2
    exit 1
  fi
  echo "ok: scaffold-wrappers (created)"
  exit 0
fi

echo "ok: scaffold-wrappers (nothing to do)"
exit 0
