#!/bin/bash
set -u

# beforeShellExecution hook: 破壊的コマンドを deny する防御層
# 一次ゲートは permissions.json（Allowlist-first）。このフックは deny / ask を担当する。
# Input:  { "command": "...", "cwd": "...", "sandbox": bool }
# Output: { "permission": "allow"|"ask"|"deny", "user_message": "...", "agent_message": "..." }

if ! command -v jq &>/dev/null; then
  echo '{"permission":"deny","user_message":"guard-shell.sh: jq が未インストール","agent_message":"brew install jq でインストールしてください。"}'
  exit 0
fi

cmd=$(cat | jq -r '.command // empty' 2>/dev/null) || cmd=''

if [[ -z "$cmd" ]]; then
  echo '{"permission":"deny","user_message":"guard-shell.sh: コマンドの解析に失敗","agent_message":"入力が不正です。Cursor Hooks の仕様を確認してください。"}'
  exit 0
fi

deny() {
  jq -n --arg u "$1" --arg a "$2" \
    '{ permission: "deny", user_message: $u, agent_message: $a }'
  exit 0
}

ask() {
  jq -n --arg u "$1" --arg a "$2" \
    '{ permission: "ask", user_message: $u, agent_message: $a }'
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
echo "$cmd" | grep -qE "${GIT}\s+restore${END}"  && deny "git restore はブロックされました。" "ファイルの復元はユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+switch${END}"   && deny "git switch はブロックされました。" "ブランチの切り替えはユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+fetch${END}"    && deny "git fetch はブロックされました。" "リモートからの取得はユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+pull${END}"     && deny "git pull はブロックされました。" "リモートからの取得・マージはユーザーが行うべき操作です。"
echo "$cmd" | grep -qE "${GIT}\s+clone\s"        && deny "git clone はブロックされました。" "代わりに 'gh repo clone <owner>/<repo>' を使用してください。"
echo "$cmd" | grep -qE "${GIT}\s+config${END}"  && deny "git config はブロックされました。" "git config の参照・変更はユーザーが行うべき操作です。"

# --- ユーザー確認コマンド → ask ---
echo "$cmd" | grep -qE "${GIT}\s+rebase${END}" && ask "git rebase の実行にはユーザーの承認が必要です。" "rebase はユーザーの承認を得てから実行してください。"

# --- gh 破壊的コマンド → deny ---
echo "$cmd" | grep -qE "gh\s+pr\s+merge"                             && deny "gh pr merge はブロックされました。" "PR のマージは取り消しが困難です。ユーザーに依頼してください。"
echo "$cmd" | grep -qE "gh\s+(repo|release|issue|gist|run)\s+delete" && deny "gh delete はブロックされました。" "リソースの不可逆的な削除です。ユーザーに依頼してください。"
echo "$cmd" | grep -qE "gh\s+repo\s+archive"                         && deny "gh repo archive はブロックされました。" "リポジトリのアーカイブは取り消しが困難です。ユーザーに依頼してください。"

# --- gh 書き込みコマンド → ask ---
echo "$cmd" | grep -qE "gh\s+pr\s+(create|comment|edit|close|reopen|review|ready|lock|unlock)${END}"          && ask "gh pr の書き込み操作にはユーザーの承認が必要です。" "PR への書き込みはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+issue\s+(create|comment|edit|close|reopen|transfer|pin|unpin|lock|unlock)${END}" && ask "gh issue の書き込み操作にはユーザーの承認が必要です。" "Issue への書き込みはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+release\s+(create|edit|upload)${END}"                                            && ask "gh release の書き込み操作にはユーザーの承認が必要です。" "Release への書き込みはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+repo\s+(create|edit|fork|rename)${END}"                                          && ask "gh repo の書き込み操作にはユーザーの承認が必要です。" "リポジトリへの書き込みはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+gist\s+(create|edit)${END}"                                                      && ask "gh gist の書き込み操作にはユーザーの承認が必要です。" "Gist への書き込みはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+label\s+(create|edit|delete)${END}"                                              && ask "gh label の書き込み操作にはユーザーの承認が必要です。" "ラベルの変更はユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+secret\s+(set|delete|remove)${END}"                                              && ask "gh secret の書き込み操作にはユーザーの承認が必要です。" "シークレットの変更はユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+variable\s+(set|delete)${END}"                                                   && ask "gh variable の書き込み操作にはユーザーの承認が必要です。" "変数の変更はユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+workflow\s+(run|enable|disable)${END}"                                           && ask "gh workflow の操作にはユーザーの承認が必要です。" "ワークフローの操作はユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+run\s+(cancel|rerun)${END}"                                                     && ask "gh run の操作にはユーザーの承認が必要です。" "ワークフロー実行の操作はユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+api\s+.*(-X|--method)\s+(POST|PUT|DELETE|PATCH)"                                 && ask "gh api の書き込みメソッドにはユーザーの承認が必要です。" "gh api の書き込みリクエストはユーザーの承認を得てから実行してください。"
echo "$cmd" | grep -qE "gh\s+api\s+.*(-f|-F|--field|--raw-field)\s+"                                          && ask "gh api のフィールド指定（POST 暗黙指定）にはユーザーの承認が必要です。" "gh api の -f/-F は POST を暗黙指定します。ユーザーの承認を得てから実行してください。"

# Allowlist が auto-run を制御。フックは何もブロックしない。
echo '{"permission":"allow"}'
