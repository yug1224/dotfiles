#!/usr/bin/env bash
# guard-shell.sh のテスト（jq 必須）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="${SCRIPT_DIR}/guard-shell.sh"

if [[ -z "${JQ:-}" ]]; then
  JQ="$HOME/.local/share/mise/shims/jq"
  [[ -x "$JQ" ]] || JQ="$(command -v jq || true)"
fi
if [[ ! -x "$JQ" ]]; then
  echo "SKIP: executable jq required at JQ=$JQ (make mise / packages/mise/config.toml の jq)" >&2
  # CI で SKIP すると未検証のまま成功に見えるので落とす
  [[ -n "${CI:-}" ]] && exit 1
  exit 0
fi
export JQ

run_case() {
  local expected="$1" json="$2" label="${3:-$json}"
  local perm
  perm="$(printf '%s' "$json" | "$GUARD" | "$JQ" -r '.permission // empty')"
  if [[ "$perm" != "$expected" ]]; then
    echo "FAIL: 期待=$expected 実際=$perm ($label)" >&2
    exit 1
  fi
  echo "ok: $expected <- $label"
}

# fail-closed
out="$(printf '{}' | JQ=/nonexistent "$GUARD")"
echo "$out" | grep -q '"permission":"deny"' || { echo "FAIL: jq 未インストール時 deny" >&2; exit 1; }
echo "ok: deny <- jq 未インストール (fail-closed)"

# deny: git push / 破壊的 rm・gh
run_case deny '{"command":"git push"}' 'git push'
run_case deny '{"command":"git push origin main"}' 'git push origin main'
run_case deny '{"command":"git push --force"}' 'git push --force'
run_case deny '{"command":"git push --force-with-lease"}' 'git push --force-with-lease'
run_case deny '{"command":"git status && git push origin main"}' 'compound: && で git push'
run_case deny '{"command":"rm -rf /tmp/foo"}' 'rm -rf'
run_case deny '{"command":"rm -r -f dir"}' 'rm -r -f'
run_case deny '{"command":"gh pr merge 123"}' 'gh pr merge'
run_case deny '{"command":"gh repo delete owner/repo"}' 'gh repo delete'

# allow: push 以外の git / 非破壊的
run_case allow '{"command":"git status"}' 'git status'
run_case allow '{"command":"git reset --hard HEAD"}' 'git reset --hard'
run_case allow '{"command":"git clean -fd"}' 'git clean -fd'
run_case allow '{"command":"git branch -D topic"}' 'git branch -D'
run_case allow '{"command":"git stash drop"}' 'git stash drop'
run_case allow '{"command":"git clean -n"}' 'git clean -n (dry-run)'
run_case allow '{"command":"gh pr view 123"}' 'gh pr view'
run_case allow '{"command":"rm file.txt"}' 'rm file.txt'

# deny: 先頭の環境変数代入
run_case deny '{"command":"FOO=1 git push"}' 'FOO=1 git push'
run_case deny '{"command":"A=1 B=2 rm -rf x"}' 'A=1 B=2 rm -rf x'

# deny: ラッパー経由（env / command / builtin / exec / sudo / time / nohup / nice / timeout / xargs）
run_case deny '{"command":"env git push"}' 'env git push'
run_case deny '{"command":"env -i git push"}' 'env -i git push'
run_case deny '{"command":"env -u HOME git push"}' 'env -u HOME git push（値を取るオプション）'
run_case deny '{"command":"env --unset=HOME git push"}' 'env --unset=HOME git push'
run_case deny '{"command":"env -C /tmp git push"}' 'env -C /tmp git push'
run_case deny '{"command":"env -S '\''git push'\''"}' 'env -S git push（split-string 再帰）'
run_case allow '{"command":"env -u HOME ls"}' 'env -u HOME ls'
run_case allow '{"command":"env"}' 'env（引数なし）'
run_case allow '{"command":"env FOO=1 ls"}' 'env FOO=1 ls'
run_case deny '{"command":"command git push"}' 'command git push'
run_case deny '{"command":"builtin git push"}' 'builtin git push'
run_case deny '{"command":"exec git push"}' 'exec git push'
run_case deny '{"command":"sudo git push"}' 'sudo git push'
run_case deny '{"command":"sudo -u root git push"}' 'sudo -u root git push'
run_case deny '{"command":"time git push"}' 'time git push'
run_case deny '{"command":"nohup git push"}' 'nohup git push'
run_case deny '{"command":"nice git push"}' 'nice git push'
run_case deny '{"command":"nice -n 10 git push"}' 'nice -n 10 git push'
run_case deny '{"command":"timeout 5 git push"}' 'timeout 5 git push'
run_case deny '{"command":"timeout -k 5 10 git push"}' 'timeout -k 5 10 git push'
run_case deny '{"command":"xargs -n1 git push"}' 'xargs -n1 git push'
run_case deny '{"command":"sudo env FOO=1 git push"}' 'sudo env FOO=1 git push（連鎖）'

# deny: 先頭の記号 / パス
run_case deny '{"command":"(git push)"}' '(git push)'
run_case deny '{"command":"{ git push; }"}' '{ git push; }'
run_case deny '{"command":"! git push"}' '! git push'
run_case deny '{"command":"\\git push"}' '\\git push'
run_case deny '{"command":"/usr/bin/git push"}' '/usr/bin/git push'
run_case deny '{"command":"/bin/rm -rf x"}' '/bin/rm -rf x'
run_case deny '{"command":"./gh pr merge 1"}' './gh pr merge 1'

# deny: 区切り文字（単独 | / & / 改行）
run_case deny '{"command":"echo hi | git push"}' 'echo hi | git push'
run_case deny '{"command":"git push &"}' 'git push &'
run_case deny "{\"command\":\"echo hi\\ngit push\"}" '改行区切り git push'

# deny: bash/sh -c, eval, コマンド置換
run_case deny '{"command":"bash -c \"git push\""}' 'bash -c "git push"'
run_case deny '{"command":"sh -lc \"git push\""}' 'sh -lc "git push"'
run_case deny '{"command":"eval \"git push\""}' 'eval "git push"'
run_case deny '{"command":"eval git push"}' 'eval git push（無引用）'
run_case deny '{"command":"echo $(git push)"}' 'echo $(git push)'
run_case deny '{"command":"echo `git push`"}' 'echo `git push`'
run_case deny '{"command":"sudo env FOO=1 bash -c \"git push\""}' 'ラッパー多重＋bash -c'

# deny: git グローバルオプションの拡張
run_case deny '{"command":"git -C \"a b\" push"}' 'git -C "a b" push'
run_case deny '{"command":"git --git-dir=.git push"}' 'git --git-dir=.git push'
run_case deny '{"command":"git --work-tree . push"}' 'git --work-tree . push'
run_case deny '{"command":"git -P push"}' 'git -P push'
run_case deny '{"command":"git --bare push"}' 'git --bare push'

# deny: gh のグローバル寄り -R/--repo がサブコマンド前にある形
run_case deny '{"command":"gh -R owner/repo pr merge"}' 'gh -R owner/repo pr merge'

# allow: 誤 deny を増やさないことの確認
run_case allow '{"command":"gh -R owner/repo pr view 1"}' 'gh -R owner/repo pr view'
run_case allow '{"command":"git log --grep push"}' 'git log --grep push'
run_case allow '{"command":"git commit -m \"push fix\""}' 'git commit -m "push fix"'
run_case allow '{"command":"env"}' 'env 単体'
run_case allow '{"command":"timeout 5 ls"}' 'timeout 5 ls'
run_case allow '{"command":"bash -c \"echo hi\""}' 'bash -c "echo hi"'
run_case allow '{"command":"ls $(pwd)"}' 'ls $(pwd)'
run_case allow '{"command":"gh api -X DELETE repos/o/r"}' 'gh api -X DELETE（対象外）'

# 新規追加ケース（jq 単一プログラム移行の受け入れ条件）
# deny: 分割で片側だけ引用符が残るケース／引用符で囲まれたコマンド名
run_case deny '{"command":"bash -c '"'"'echo a; git push'"'"'"}' 'bash -c '"'"'echo a; git push'"'"'（; 分割で引用符が残る）'
run_case deny '{"command":"bash -c \"git status && git push\""}' 'bash -c "git status && git push"（&& 分割で引用符が残る）'
run_case deny '{"command":"\"git\" push"}' '"git" push（引用符付きコマンド名）'
run_case deny "{\"command\":\"'rm' -rf x\"}" "'rm' -rf x（引用符付きコマンド名）"
run_case deny '{"command":"xargs -n 1 git push"}' 'xargs -n 1 git push'
run_case deny '{"command":"timeout -s KILL 5 git push"}' 'timeout -s KILL 5 git push'
run_case deny '{"command":"git -c user.name=x push"}' 'git -c user.name=x push'
run_case deny '{"command":"git push &"}' 'git push &'
run_case deny '{"command":"gh --repo=owner/repo repo delete owner/repo"}' 'gh --repo=owner/repo repo delete'
run_case deny '{"command":"rm --recursive --force d"}' 'rm --recursive --force d'
run_case deny '{"command":"sudo rm -rf /"}' 'sudo rm -rf /'

# allow
run_case allow '{"command":"ls"}' 'ls'
run_case allow '{"command":"git commit -m \"a; b\""}' 'git commit -m "a; b"（; を含む引用符内は分割対象外の想定）'
run_case allow '{"command":"echo git push"}' 'echo git push'
run_case allow '{"command":"echo \"git push\""}' 'echo "git push"'
run_case allow '{"command":"rm -r dir"}' 'rm -r dir（force なし）'
run_case allow '{"command":"bash script.sh"}' 'bash script.sh（-c なし）'
run_case allow '{"command":"command -v git"}' 'command -v git'

# deny: 以前すり抜けていた形
run_case deny '{"command":"command -p git push"}' 'command -p git push'
run_case deny '{"command":"exec -a x git push"}' 'exec -a x git push'
run_case deny '{"command":"gh -R=owner/repo pr merge 1"}' 'gh -R=owner/repo pr merge'
run_case deny '{"command":"git --exec-path=/x push"}' 'git --exec-path=/x push'
run_case deny '{"command":"git --config-env x=Y push"}' 'git --config-env x=Y push'
run_case deny '{"command":"git -c core.bare push"}' 'git -c core.bare push（= なし）'
run_case deny '{"command":"git p\\ush"}' 'git p\ush（エスケープ）'
run_case deny '{"command":"find /tmp/x -exec rm -rf {} +"}' 'find -exec rm -rf'
run_case deny '{"command":"find . -execdir rm -fr {} \\;"}' 'find -execdir rm -fr'
run_case deny '{"command":"git subtree push --prefix=d origin main"}' 'git subtree push'
run_case allow '{"command":"find . -exec ls {} +"}' 'find -exec ls'
run_case allow '{"command":"git -c color.ui=never status"}' 'git -c color.ui=never status'

# 性能: 大きい入力でも allow が返ること（実行時間の assert はしない）
BIG_CMD=""
for i in $(seq 1 300); do
  BIG_CMD="${BIG_CMD}line ${i} padding text used only for performance measurement
"
done
BIG_JSON="$("$JQ" -nc --arg c "$BIG_CMD" '{command:$c}')"
perm="$(printf '%s' "$BIG_JSON" | "$GUARD" | "$JQ" -r '.permission // empty')"
[[ "$perm" == allow ]] || { echo "FAIL: 大きい入力(約${#BIG_CMD}バイト)で allow が返ること" >&2; exit 1; }
echo "ok: allow <- 大きい入力（約${#BIG_CMD}バイト、300行）"

# adapters: ~/.config/shared を一時 HOME に張って Claude / Cursor の入口を通す
ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -r "$TMP_HOME"' EXIT
mkdir -p "$TMP_HOME/.config"
ln -s "$ROOT/packages/shared" "$TMP_HOME/.config/shared"
# mise shim は HOME を差し替えると trust を失うので実体を渡す
JQ="$(mise which jq 2>/dev/null || command -v jq)"
export JQ

CLAUDE_ADAPTER="$ROOT/packages/claude/hooks/guard-shell.sh"
claude_case() {
  local expected="$1" json="$2" label="$3" out decision
  out="$(printf '%s' "$json" | HOME="$TMP_HOME" "$CLAUDE_ADAPTER")"
  decision="$(printf '%s' "$out" | "$JQ" -r '.hookSpecificOutput.permissionDecision // "silent"' 2>/dev/null || echo invalid)"
  [[ -z "$out" ]] && decision=silent
  if [[ "$decision" != "$expected" ]]; then
    echo "FAIL: claude 期待=$expected 実際=$decision ($label)" >&2
    exit 1
  fi
  echo "ok: claude $expected <- $label"
}
claude_case deny '{"tool_name":"Bash","tool_input":{"command":"git push"}}' 'git push'
claude_case deny '{"tool_name":"Bash","tool_input":{"command":"git -C repo push"}}' 'git -C repo push'
claude_case silent '{"tool_name":"Bash","tool_input":{"command":"git status"}}' 'git status（allow は無出力で通常の権限判定へ）'
claude_case deny '{"tool_name":"Shell","tool_input":{"command":"git push"},"cwd":"/tmp"}' 'Cursor 経由（tool_name=Shell）の git push'
claude_case silent '{"tool_name":"Shell","tool_input":{"command":"git status"}}' 'Cursor 経由（tool_name=Shell）の git status'
claude_case silent '{"tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' 'Bash / Shell 以外は素通し'
out="$(printf '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | HOME="$TMP_HOME" JQ=/usr/bin/false "$CLAUDE_ADAPTER")"
[[ "$(printf '%s' "$out" | "$JQ" -r '.hookSpecificOutput.permissionDecision')" == deny ]] \
  || { echo "FAIL: claude adapter は jq 故障時に deny すること" >&2; exit 1; }
echo "ok: claude deny <- jq 故障 (fail-closed)"

CURSOR_ADAPTER="$ROOT/packages/cursor/hooks/guard-shell.sh"
perm="$(printf '{"command":"rm -rf /tmp/foo"}' | HOME="$TMP_HOME" "$CURSOR_ADAPTER" | "$JQ" -r '.permission')"
[[ "$perm" == deny ]] || { echo "FAIL: cursor adapter rm -rf" >&2; exit 1; }
echo "ok: cursor deny <- rm -rf"
perm="$(printf '{"command":"ls"}' | HOME=/nonexistent "$CURSOR_ADAPTER" | "$JQ" -r '.permission')"
[[ "$perm" == deny ]] || { echo "FAIL: cursor adapter missing shared" >&2; exit 1; }
echo "ok: cursor deny <- shared 未展開 (fail-closed)"

echo "all tests passed ($GUARD)"
