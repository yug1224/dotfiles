#!/usr/bin/env bash
# Verify Claude settings.json permissions.deny patterns are enforced by guard-shell (deny).
# Exit 1 on mismatch. Requires jq.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_SETTINGS="${ROOT}/packages/claude/settings.json"
GUARD="${ROOT}/packages/shared/ai/hooks/guard-shell.sh"

if ! command -v jq &>/dev/null; then
  if [[ "${REQUIRE_JQ:-0}" == "1" ]]; then
    echo "ERROR: jq required (REQUIRE_JQ=1)" >&2
    exit 1
  fi
  echo "SKIP: jq required" >&2
  exit 0
fi

# guard-shell defaults to mise shim; CI apt jq is on PATH — pin that for the probe.
export JQ="${JQ:-$(command -v jq)}"

# Map deny prefix (from Bash(...:*) ) to a representative command string
sample_for_deny() {
  local pattern="$1"
  case "$pattern" in
    "git reset --hard") echo "git reset --hard HEAD" ;;
    "git clean -f") echo "git clean -f" ;;
    "git clean --force") echo "git clean --force" ;;
    "git branch -D") echo "git branch -D topic" ;;
    "git stash drop") echo "git stash drop" ;;
    "git stash clear") echo "git stash clear" ;;
    "gh pr merge") echo "gh pr merge 123" ;;
    "gh repo delete") echo "gh repo delete owner/repo" ;;
    "gh release delete") echo "gh release delete v1.0.0" ;;
    "gh issue delete") echo "gh issue delete 123" ;;
    "gh gist delete") echo "gh gist delete abc123" ;;
    "gh run delete") echo "gh run delete 12345" ;;
    "gh repo archive") echo "gh repo archive owner/repo" ;;
    *) echo "$pattern" ;;
  esac
}

run_guard() {
  local cmd="$1"
  jq -nc --arg c "$cmd" '{command: $c}' | "$GUARD" | jq -r '.permission // empty'
}

failed=0
while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  prefix=$(printf '%s' "$entry" | sed -E 's/^Bash\(([^:]+).*/\1/')
  sample=$(sample_for_deny "$prefix")
  perm=$(run_guard "$sample")
  if [[ "$perm" != "deny" ]]; then
    echo "FAIL: settings.deny '$entry' → guard expected deny, got '$perm' (sample: $sample)" >&2
    failed=1
  else
    echo "ok: deny ← $sample ($prefix)"
  fi
done < <(jq -r '.permissions.deny[]' "$CLAUDE_SETTINGS")

if [[ "$failed" -eq 0 ]]; then
  echo "all settings.deny entries enforced by guard-shell"
  exit 0
fi
exit 1
