#!/usr/bin/env bash
# guard-shell.sh のテスト（jq 必須）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="${SCRIPT_DIR}/guard-shell.sh"

if ! command -v jq &>/dev/null; then
  echo "SKIP: jq が必要です (brew install jq)" >&2
  exit 0
fi

# --- deny: jq 未インストール (fail-closed) ---

_path_without_jq() {
  local IFS=: d result=""
  for d in $PATH; do
    [[ -x "$d/jq" ]] || result+="$d:"
  done
  echo "${result%:}"
}
out="$(printf '{}' | PATH="$(_path_without_jq)" "$GUARD")"
if ! echo "$out" | grep -q '"permission":"deny"'; then
  echo "FAIL: 期待=deny (jq 未インストール)" >&2
  echo "  output: $out" >&2
  exit 1
fi
echo "ok: deny <- jq 未インストール (fail-closed)"

# --- deny: 不正入力 (fail-closed) ---

out="$(printf '' | "$GUARD")"
if ! echo "$out" | grep -q '"permission":"deny"'; then
  echo "FAIL: 期待=deny (空の stdin)" >&2
  echo "  output: $out" >&2
  exit 1
fi
echo "ok: deny <- 空の stdin (fail-closed)"

out="$(printf 'not-json' | "$GUARD")"
if ! echo "$out" | grep -q '"permission":"deny"'; then
  echo "FAIL: 期待=deny (不正な JSON)" >&2
  echo "  output: $out" >&2
  exit 1
fi
echo "ok: deny <- 不正な JSON (fail-closed)"

run_case() {
  local expected="$1" json="$2" label="${3:-$json}"
  local perm
  perm="$(printf '%s' "$json" | "$GUARD" | jq -r '.permission // empty')"
  if [[ "$perm" != "$expected" ]]; then
    echo "FAIL: 期待=$expected 実際=$perm ($label)" >&2
    echo "  output: $(printf '%s' "$json" | "$GUARD")" >&2
    exit 1
  fi
  echo "ok: $expected <- $label"
}

# --- deny: 不正入力 — command キーなし / 空 (fail-closed) ---

run_case deny '{"cwd":"/tmp"}' 'command キーなし (fail-closed)'
run_case deny '{"command":""}' '空の command (fail-closed)'

# --- deny: 破壊的コマンド ---

run_case deny '{"command":"git reset --hard HEAD"}' 'git reset --hard'
run_case deny '{"command":"git reset --hard"}' 'git reset --hard (引数なし)'

run_case deny '{"command":"git clean -f"}' 'git clean -f'
run_case deny '{"command":"git clean -fd"}' 'git clean -fd'
run_case deny '{"command":"git clean -xfd"}' 'git clean -xfd'
run_case deny '{"command":"git clean --force"}' 'git clean --force'

run_case deny '{"command":"git branch -D topic"}' 'git branch -D'
run_case deny '{"command":"git branch --delete --force topic"}' 'git branch --delete --force'
run_case deny '{"command":"git branch --force --delete topic"}' 'git branch --force --delete'

run_case deny '{"command":"git stash drop"}' 'git stash drop'
run_case deny '{"command":"git stash drop stash@{0}"}' 'git stash drop stash@{0}'
run_case deny '{"command":"git stash clear"}' 'git stash clear'

run_case deny '{"command":"git reflog delete HEAD@{0}"}' 'git reflog delete'
run_case deny '{"command":"git reflog expire --all"}' 'git reflog expire'

# --- deny: エージェント制限コマンド ---

run_case deny '{"command":"git commit"}' 'git commit'
run_case deny '{"command":"git commit -m \"test\""}' 'git commit -m'
run_case deny '{"command":"git commit --amend"}' 'git commit --amend'

run_case deny '{"command":"git push"}' 'git push'
run_case deny '{"command":"git push origin main"}' 'git push origin main'
run_case deny '{"command":"git push --force"}' 'git push --force'
run_case deny '{"command":"git push -f"}' 'git push -f'

run_case deny '{"command":"git checkout main"}' 'git checkout'
run_case deny '{"command":"git checkout -b new-branch"}' 'git checkout -b'

run_case deny '{"command":"git switch main"}' 'git switch'
run_case deny '{"command":"git switch -c new-branch"}' 'git switch -c'

run_case deny '{"command":"git fetch"}' 'git fetch'
run_case deny '{"command":"git fetch origin"}' 'git fetch origin'

run_case deny '{"command":"git pull"}' 'git pull'
run_case deny '{"command":"git pull --rebase"}' 'git pull --rebase'

run_case deny '{"command":"git clone https://github.com/user/repo"}' 'git clone'

# --- deny: グローバルオプション付き ---

run_case deny '{"command":"git -C /tmp reset --hard"}' 'git -C <path> reset --hard'
run_case deny '{"command":"git -c user.name=foo commit -m \"x\""}' 'git -c <key>=<val> commit'
run_case deny '{"command":"git --no-pager push"}' 'git --no-pager push'

# --- allow: フックを通過（Allowlist / Cursor が制御） ---

run_case allow '{"command":"git status"}' 'git status'
run_case allow '{"command":"git diff --staged"}' 'git diff'
run_case allow '{"command":"git log --oneline -10"}' 'git log'
run_case allow '{"command":"git show HEAD"}' 'git show'
run_case allow '{"command":"git add ."}' 'git add'
run_case allow '{"command":"git blame file.txt"}' 'git blame'
run_case allow '{"command":"git stash"}' 'git stash (= push)'
run_case allow '{"command":"git stash pop"}' 'git stash pop (Cursor が ask)'
run_case allow '{"command":"git reflog"}' 'git reflog (参照)'
run_case allow '{"command":"git branch"}' 'git branch (一覧)'
run_case allow '{"command":"git branch -a"}' 'git branch -a'
run_case allow '{"command":"git branch -d merged"}' 'git branch -d (Cursor が ask)'
run_case allow '{"command":"git branch feature/foo"}' 'git branch 作成 (Cursor が ask)'
run_case allow '{"command":"git restore file.txt"}' 'git restore (Cursor が ask)'
run_case allow '{"command":"git rebase main"}' 'git rebase (Cursor が ask)'
run_case allow '{"command":"git tag v1.0.0"}' 'git tag (Cursor が ask)'
run_case allow '{"command":"git -C /tmp status"}' 'git -C <path> status'
run_case allow '{"command":"git --no-pager diff"}' 'git --no-pager diff'

# --- deny: 複合コマンド（&& / ; / || でつながれた破壊的操作） ---

run_case deny '{"command":"git status && git reset --hard"}' 'compound: && で破壊的コマンド'
run_case deny '{"command":"git add . && git commit -m \"test\""}' 'compound: && でコミット'
run_case deny '{"command":"git status; git push"}' 'compound: ; でプッシュ'
run_case deny '{"command":"git diff && git push --force"}' 'compound: && で force push'
run_case deny '{"command":"false || git reset --hard"}' 'compound: || で破壊的コマンド'
run_case deny '{"command":"git status || git push"}' 'compound: || でプッシュ'

# --- allow: gh コマンド（Allowlist / Cursor が制御） ---

run_case allow '{"command":"gh pr list"}' 'gh pr list'
run_case allow '{"command":"gh pr view 123"}' 'gh pr view'
run_case allow '{"command":"gh pr create"}' 'gh pr create (Cursor が ask)'
run_case allow '{"command":"gh issue create"}' 'gh issue create (Cursor が ask)'
run_case allow '{"command":"gh api repos/user/repo"}' 'gh api (Cursor が ask)'

echo "all tests passed ($GUARD)"
