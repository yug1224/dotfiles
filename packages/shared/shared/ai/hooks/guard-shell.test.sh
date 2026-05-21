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

run_case deny '{"command":"git config user.name \"test\""}' 'git config'
run_case deny '{"command":"git config --global user.email \"test@example.com\""}' 'git config --global'
run_case deny '{"command":"git status && git config user.name \"test\""}' 'compound: && で git config'

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
run_case deny '{"command":"git restore file.txt"}' 'git restore'
run_case ask '{"command":"git rebase main"}' 'git rebase'
run_case ask '{"command":"git rebase --interactive main"}' 'git rebase --interactive'
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

# --- deny: gh 破壊的コマンド ---

run_case deny '{"command":"gh pr merge 123"}' 'gh pr merge'
run_case deny '{"command":"gh pr merge --auto 123"}' 'gh pr merge --auto'
run_case deny '{"command":"gh repo delete owner/repo"}' 'gh repo delete'
run_case deny '{"command":"gh release delete v1.0.0"}' 'gh release delete'
run_case deny '{"command":"gh issue delete 123"}' 'gh issue delete'
run_case deny '{"command":"gh gist delete abc123"}' 'gh gist delete'
run_case deny '{"command":"gh run delete 12345"}' 'gh run delete'
run_case deny '{"command":"gh repo archive owner/repo"}' 'gh repo archive'

# --- ask: gh 書き込みコマンド ---

run_case ask '{"command":"gh pr create"}' 'gh pr create'
run_case ask '{"command":"gh pr comment 123"}' 'gh pr comment'
run_case ask '{"command":"gh pr edit 123"}' 'gh pr edit'
run_case ask '{"command":"gh pr close 123"}' 'gh pr close'
run_case ask '{"command":"gh pr reopen 123"}' 'gh pr reopen'
run_case ask '{"command":"gh pr review 123"}' 'gh pr review'
run_case ask '{"command":"gh pr ready 123"}' 'gh pr ready'
run_case ask '{"command":"gh pr lock 123"}' 'gh pr lock'
run_case ask '{"command":"gh pr unlock 123"}' 'gh pr unlock'

run_case ask '{"command":"gh issue create"}' 'gh issue create'
run_case ask '{"command":"gh issue comment 123"}' 'gh issue comment'
run_case ask '{"command":"gh issue edit 123"}' 'gh issue edit'
run_case ask '{"command":"gh issue close 123"}' 'gh issue close'
run_case ask '{"command":"gh issue reopen 123"}' 'gh issue reopen'
run_case ask '{"command":"gh issue transfer 123 owner/repo"}' 'gh issue transfer'
run_case ask '{"command":"gh issue pin 123"}' 'gh issue pin'
run_case ask '{"command":"gh issue unpin 123"}' 'gh issue unpin'
run_case ask '{"command":"gh issue lock 123"}' 'gh issue lock'
run_case ask '{"command":"gh issue unlock 123"}' 'gh issue unlock'

run_case ask '{"command":"gh release create v1.0.0"}' 'gh release create'
run_case ask '{"command":"gh release edit v1.0.0"}' 'gh release edit'
run_case ask '{"command":"gh release upload v1.0.0 file.tar.gz"}' 'gh release upload'

run_case ask '{"command":"gh repo create my-repo"}' 'gh repo create'
run_case ask '{"command":"gh repo edit owner/repo"}' 'gh repo edit'
run_case ask '{"command":"gh repo fork owner/repo"}' 'gh repo fork'
run_case ask '{"command":"gh repo rename new-name"}' 'gh repo rename'

run_case ask '{"command":"gh gist create file.txt"}' 'gh gist create'
run_case ask '{"command":"gh gist edit abc123"}' 'gh gist edit'

run_case ask '{"command":"gh label create bug"}' 'gh label create'
run_case ask '{"command":"gh label edit bug"}' 'gh label edit'
run_case ask '{"command":"gh label delete bug"}' 'gh label delete'

run_case ask '{"command":"gh secret set MY_SECRET"}' 'gh secret set'
run_case ask '{"command":"gh secret delete MY_SECRET"}' 'gh secret delete'
run_case ask '{"command":"gh secret remove MY_SECRET"}' 'gh secret remove'

run_case ask '{"command":"gh variable set MY_VAR"}' 'gh variable set'
run_case ask '{"command":"gh variable delete MY_VAR"}' 'gh variable delete'

run_case ask '{"command":"gh workflow run deploy.yml"}' 'gh workflow run'
run_case ask '{"command":"gh workflow enable deploy.yml"}' 'gh workflow enable'
run_case ask '{"command":"gh workflow disable deploy.yml"}' 'gh workflow disable'

run_case ask '{"command":"gh run cancel 12345"}' 'gh run cancel'
run_case ask '{"command":"gh run rerun 12345"}' 'gh run rerun'

run_case ask '{"command":"gh api repos/user/repo/issues -X POST"}' 'gh api -X POST'
run_case ask '{"command":"gh api repos/user/repo -X DELETE"}' 'gh api -X DELETE'
run_case ask '{"command":"gh api repos/user/repo --method PUT"}' 'gh api --method PUT'
run_case ask '{"command":"gh api repos/user/repo -X PATCH"}' 'gh api -X PATCH'
run_case ask '{"command":"gh api repos/user/repo -f title=test"}' 'gh api -f (implicit POST)'
run_case ask '{"command":"gh api repos/user/repo -F body=@file.txt"}' 'gh api -F (implicit POST)'
run_case ask '{"command":"gh api repos/user/repo --field title=test"}' 'gh api --field (implicit POST)'
run_case ask '{"command":"gh api repos/user/repo --raw-field body=test"}' 'gh api --raw-field (implicit POST)'

# --- allow: gh 読み取りコマンド（Allowlist / Cursor が制御） ---

run_case allow '{"command":"gh pr list"}' 'gh pr list'
run_case allow '{"command":"gh pr view 123"}' 'gh pr view'
run_case allow '{"command":"gh pr diff 123"}' 'gh pr diff'
run_case allow '{"command":"gh pr checks 123"}' 'gh pr checks'
run_case allow '{"command":"gh pr status"}' 'gh pr status'
run_case allow '{"command":"gh issue list"}' 'gh issue list'
run_case allow '{"command":"gh issue view 123"}' 'gh issue view'
run_case allow '{"command":"gh issue status"}' 'gh issue status'
run_case allow '{"command":"gh run list"}' 'gh run list'
run_case allow '{"command":"gh run view 12345"}' 'gh run view'
run_case allow '{"command":"gh repo view owner/repo"}' 'gh repo view'
run_case allow '{"command":"gh release list"}' 'gh release list'
run_case allow '{"command":"gh release view v1.0.0"}' 'gh release view'
run_case allow '{"command":"gh search repos query"}' 'gh search repos'
run_case allow '{"command":"gh api repos/user/repo"}' 'gh api (GET, no write flags)'

# --- allow: pnpm exec vitest / oxlint ---

run_case allow '{"command":"pnpm exec vitest"}' 'pnpm exec vitest'
run_case allow '{"command":"pnpm exec vitest run src/foo.test.ts"}' 'pnpm exec vitest (subcommand + args)'
run_case allow '{"command":"pnpm exec oxlint"}' 'pnpm exec oxlint'

# --- ask: pnpm exec (other binaries) / dlx ---

run_case ask '{"command":"pnpm exec eslint"}' 'pnpm exec (other binary)'
run_case ask '{"command":"pnpm dlx create-vite"}' 'pnpm dlx'

echo "all tests passed ($GUARD)"
