#!/usr/bin/env bash
# Warn when shared AI docs describe Task / subagent_type launch of work-type
# agents without composer-2.5 on the **same line** (heuristic; not a full parse).
# Work types: explore / generalPurpose / *-worker / docs-researcher / shell / MAGI.
# Usage: ./scripts/check-work-task-model-pin.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAN_DIR="$ROOT/packages/shared/ai"
FAIL=0

# Built-ins + custom workers + MAGI units
TYPES='explore|generalPurpose|build-worker|design-worker|docs-researcher|shell|melchior-1|balthasar-2|casper-3'
# Launch-ish line: Task(...) or subagent_type … <type>
WORK_RE="(subagent_type[^[:alnum:]_]*[\`\"]?(${TYPES})[\`\"]?|Task\\([^)]*(${TYPES}))"

while IFS= read -r -d '' file; do
  lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    if [[ "$line" =~ $WORK_RE ]]; then
      if [[ ! "$line" =~ composer-2\.5 ]]; then
        echo "WARN: ${file#"$ROOT/"}:$lineno: work-type Task/subagent launch without composer-2.5" >&2
        echo "  $line" >&2
        FAIL=1
      fi
    fi
  done < "$file"
done < <(find "$SCAN_DIR" -name '*.md' ! -name '*.local.md' -type f -print0)

if [[ $FAIL -eq 0 ]]; then
  echo "ok: work-type Task model pins look consistent"
fi
exit "$FAIL"
