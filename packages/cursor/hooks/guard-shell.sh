#!/bin/bash
set -u

# beforeShellExecution hook: 破壊的コマンドを deny する防御層
# 一次ゲートは permissions.json（Allowlist-first）。このフックは deny のみを担当する。
# Input:  { "command": "...", "cwd": "...", "sandbox": bool }
# Output: { "permission": "allow"|"deny", "user_message": "...", "agent_message": "..." }

if ! command -v jq &>/dev/null; then
  echo '{"permission":"deny","user_message":"guard-shell.sh: jq が未インストール","agent_message":"brew install jq でインストールしてください。"}'
  exit 0
fi

cmd=$(cat | jq -r '.command // empty')

deny() {
  jq -n --arg u "$1" --arg a "$2" \
    '{ permission: "deny", user_message: $u, agent_message: $a }'
  exit 0
}

# git のグローバルオプション（-C <path>, -c <key>=<val>, --no-pager 等）を吸収
GIT='git(\s+(-[a-zA-Z](\s+\S+)?|--[a-z][-a-z]*(=\S+)?))*'
END='(\s|[);|&]|$)'

# --- 破壊的コマンド → deny ---
echo "$cmd" | grep -qE "${GIT}\s+reset\s+--hard"                                       && deny "git reset --hard はブロックされました。" "不可逆的な変更破棄。git stash や reset --soft を検討してください。"
echo "$cmd" | grep -qE "${GIT}\s+clean\s+.*(--force|-[a-z]*f)"                          && deny "git clean -f はブロックされました。" "git clean -n (dry-run) で確認してからユーザーに相談してください。"
echo "$cmd" | grep -qE "${GIT}\s+branch\s+.*(-D|--delete\s+--force|--force\s+--delete)" && deny "git branch -D はブロックされました。" "git branch -d（小文字）を使用してください。"
echo "$cmd" | grep -qE "${GIT}\s+stash\s+(drop|clear)${END}"                            && deny "git stash drop/clear はブロックされました。" "スタッシュの不可逆的な削除です。ユーザーに確認してください。"
echo "$cmd" | grep -qE "${GIT}\s+reflog\s+(delete|expire)${END}"                        && deny "git reflog delete/expire はブロックされました。" "reflog エントリの不可逆的な削除です。ユーザーに相談してください。"

# --- エージェント制限コマンド → deny ---
echo "$cmd" | grep -qE "${GIT}\s+commit${END}"   && deny "git commit はブロックされました。" "コミットはユーザーが内容を確認してから行うべき操作です。ユーザーに依頼してください。"
echo "$cmd" | grep -qE "${GIT}\s+push${END}"     && deny "git push はブロックされました。" "プッシュはユーザーが変更内容を確認してから行うべき操作です。ユーザーに依頼してください。"
echo "$cmd" | grep -qE "${GIT}\s+checkout${END}" && deny "git checkout はブロックされました。" "ブランチの切り替えやファイルの復元はユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+switch${END}"   && deny "git switch はブロックされました。" "ブランチの切り替えはユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+fetch${END}"    && deny "git fetch はブロックされました。" "リモートからの取得はユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+pull${END}"     && deny "git pull はブロックされました。" "リモートからの取得・マージはユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+clone\s"        && deny "git clone はブロックされました。" "代わりに 'gh repo clone <owner>/<repo>' を使用してください。"

# Allowlist が auto-run を制御。フックは何もブロックしない。
echo '{"permission":"allow"}'
