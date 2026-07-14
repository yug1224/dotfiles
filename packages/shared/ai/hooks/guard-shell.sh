#!/usr/bin/env bash
# Shared guard: reads Cursor beforeShellExecution–style JSON on stdin
# ({ "command", "cwd", "sandbox" }) and prints one JSON line with
# { "permission": "allow" | "ask" | "deny", ... }.
#
# Deployed to ~/.config/shared/ai/hooks/ (via make mise-dotfiles). Cursor invokes
# ~/.cursor/hooks/guard-shell.sh, a thin wrapper that execs this file. Claude uses
# ~/.claude/hooks/guard-shell.sh (adapter) piping the same JSON shape into
# ~/.config/shared/ai/hooks/guard-shell.sh.
#
# This file must NOT exec or source other scripts for its core decision.
set -uo pipefail

# GUI hook は login zsh の mise activate を通らないため shim を絶対指定（oxfmt-stdin と同型）
JQ="${JQ:-$HOME/.local/share/mise/shims/jq}"

deny_json() {
  "$JQ" -nc \
    --arg u "${1:-guard-shell: コマンドをブロックしました}" \
    --arg a "${2:-}" \
    '{permission:"deny", user_message: $u, agent_message: (if $a == "" then null else $a end)}'
}

if [[ ! -x "$JQ" ]]; then
  printf '%s\n' '{"permission":"deny","user_message":"guard-shell: jq が未インストールです。make mise-tools（packages/mise/config.toml の jq）でインストールしてください。","agent_message":"Shell ガードを実行できません。"}'
  exit 0
fi

input=$(cat || true)
if [[ -z "$input" ]]; then
  deny_json "guard-shell: stdin が空です。"
  exit 0
fi

if ! "$JQ" -e . >/dev/null 2>&1 <<<"$input"; then
  deny_json "guard-shell: stdin が不正な JSON です。"
  exit 0
fi

cmd=$("$JQ" -r '.command // ""' <<<"$input")
if [[ -z "$cmd" ]]; then
  deny_json "guard-shell: command が空か、command キーがありません。"
  exit 0
fi

# --- helpers ---

strip_rtk_prefix() {
  local s="$1"
  while [[ "$s" =~ ^rtk[[:space:]]+(.+)$ ]]; do
    s="${BASH_REMATCH[1]}"
  done
  printf '%s' "$s"
}

normalize_git_cmd() {
  local s="$1"
  local prev=""
  while [[ "$s" != "$prev" ]]; do
    prev="$s"
    if [[ "$s" =~ ^git[[:space:]]+-C[[:space:]]+[^[:space:]]+[[:space:]]+(.+)$ ]]; then
      s="git ${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^git[[:space:]]+-c[[:space:]]+[^[:space:]]+=[^[:space:]]+[[:space:]]+(.+)$ ]]; then
      s="git ${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^git[[:space:]]+--no-pager[[:space:]]+(.+)$ ]]; then
      s="git ${BASH_REMATCH[1]}"
    else
      break
    fi
  done
  printf '%s' "$s"
}

classify_git_tail() {
  local tail="$1"

  # Destructive / agent-restricted (deny)
  if [[ "$tail" =~ ^reset[[:space:]] ]] && [[ "$tail" == *--hard* ]]; then echo deny; return; fi

  if [[ "$tail" =~ ^clean[[:space:]] ]]; then
    if [[ "$tail" == *--force* ]] || [[ "$tail" == *xfd* ]] || [[ "$tail" == *-fd* ]] \
      || [[ "$tail" == *-f* ]]; then echo deny; return; fi
  fi

  if [[ "$tail" =~ ^branch[[:space:]]+-D ]] \
    || [[ "$tail" =~ ^branch[[:space:]]+--delete[[:space:]]+--force ]] \
    || [[ "$tail" =~ ^branch[[:space:]]+--force[[:space:]]+--delete ]]; then
    echo deny
    return
  fi

  if [[ "$tail" =~ ^stash[[:space:]]+drop ]] || [[ "$tail" =~ ^stash[[:space:]]+clear ]]; then
    echo deny
    return
  fi

  if [[ "$tail" =~ ^reflog[[:space:]]+delete ]] || [[ "$tail" =~ ^reflog[[:space:]]+expire ]]; then
    echo deny
    return
  fi

  if [[ "$tail" =~ ^commit([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^push([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^checkout([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^switch([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^fetch([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^pull([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^clone([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^config([[:space:]]|$) ]]; then echo deny; return; fi
  if [[ "$tail" =~ ^restore([[:space:]]|$) ]]; then echo deny; return; fi

  if [[ "$tail" =~ ^rebase([[:space:]]|$) ]]; then echo ask; return; fi

  # Allow (read / low-risk git per policy)
  if [[ "$tail" =~ ^status([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^diff([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^log([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^show([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^add([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^blame([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$tail" == "stash" ]] || [[ "$tail" =~ ^stash[[:space:]]*$ ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^stash[[:space:]]+pop ]]; then echo allow; return; fi

  if [[ "$tail" =~ ^reflog ]]; then echo allow; return; fi

  if [[ "$tail" == "branch" ]] || [[ "$tail" =~ ^branch[[:space:]]*$ ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^branch[[:space:]]+-a([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^branch[[:space:]]+-d([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$tail" =~ ^branch[[:space:]]+[^-] ]]; then echo allow; return; fi

  if [[ "$tail" =~ ^tag([[:space:]]|$) ]]; then echo allow; return; fi

  echo allow
}

classify_git() {
  local s tail
  s=$(normalize_git_cmd "$1")
  if [[ ! "$s" =~ ^git([[:space:]]|$) ]]; then
    echo allow
    return
  fi
  tail=$(printf '%s' "${s#git}" | sed 's/^[[:space:]]*//')
  classify_git_tail "$tail"
}

classify_gh() {
  local s="$1"

  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+merge ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+repo[[:space:]]+delete ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+release[[:space:]]+delete ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+issue[[:space:]]+delete ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+gist[[:space:]]+delete ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+run[[:space:]]+delete ]]; then echo deny; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+repo[[:space:]]+archive ]]; then echo deny; return; fi

  # Read-only allowlist (before broad ask patterns)
  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+list([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+view([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+diff([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+checks([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+status([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+issue[[:space:]]+list([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+issue[[:space:]]+view([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+issue[[:space:]]+status([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+run[[:space:]]+list([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+run[[:space:]]+view([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+repo[[:space:]]+view([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+release[[:space:]]+list([[:space:]]|$) ]]; then echo allow; return; fi
  if [[ "$s" =~ ^gh[[:space:]]+release[[:space:]]+view([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+search[[:space:]]+repos([[:space:]]|$) ]]; then echo allow; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+api([[:space:]]|$) ]]; then
    if [[ "$s" =~ [[:space:]]-X[[:space:]]+(POST|PUT|DELETE|PATCH)([[:space:]]|$) ]]; then echo ask; return; fi
    if [[ "$s" =~ [[:space:]]--method[[:space:]]+(POST|PUT|DELETE|PATCH)([[:space:]]|$) ]]; then echo ask; return; fi
    if [[ "$s" =~ [[:space:]]-f[[:space:]] ]] || [[ "$s" =~ [[:space:]]-f= ]]; then echo ask; return; fi
    if [[ "$s" =~ [[:space:]]-F[[:space:]] ]] || [[ "$s" =~ [[:space:]]-F= ]]; then echo ask; return; fi
    if [[ "$s" =~ [[:space:]]--field[[:space:]] ]]; then echo ask; return; fi
    if [[ "$s" =~ [[:space:]]--raw-field[[:space:]] ]]; then echo ask; return; fi
    echo allow
    return
  fi

  if [[ "$s" =~ ^gh[[:space:]]+pr[[:space:]]+(create|comment|edit|close|reopen|review|ready|lock|unlock)([[:space:]]|$) ]]; then
    echo ask
    return
  fi

  if [[ "$s" =~ ^gh[[:space:]]+issue[[:space:]]+(create|comment|edit|close|reopen|transfer|pin|unpin|lock|unlock)([[:space:]]|$) ]]; then
    echo ask
    return
  fi

  if [[ "$s" =~ ^gh[[:space:]]+release[[:space:]]+(create|edit|upload)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+repo[[:space:]]+(create|edit|fork|rename)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+gist[[:space:]]+(create|edit)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+label[[:space:]]+(create|edit|delete)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+secret[[:space:]]+(set|delete|remove)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+variable[[:space:]]+(set|delete)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+workflow[[:space:]]+(run|enable|disable)([[:space:]]|$) ]]; then echo ask; return; fi

  if [[ "$s" =~ ^gh[[:space:]]+run[[:space:]]+(cancel|rerun)([[:space:]]|$) ]]; then echo ask; return; fi

  echo allow
}

classify_pnpm() {
  local s="$1"

  # Package scripts / test runners the agent must not run.
  if [[ "$s" =~ ^pnpm[[:space:]]+(run[[:space:]]+)?(typecheck|test|sql-test|vitest)([[:space:]]|$) ]] \
    || [[ "$s" =~ ^pnpm[[:space:]]+exec[[:space:]]+vitest([[:space:]]|$) ]] \
    || [[ "$s" =~ ^pnpm[[:space:]]+dlx[[:space:]]+vitest([[:space:]]|$) ]]; then
    echo deny
    return
  fi

  # Local linter. Other pnpm exec can run arbitrary binaries.
  if [[ "$s" =~ ^pnpm[[:space:]]+exec[[:space:]]+oxlint([[:space:]]|$) ]]; then
    echo allow
    return
  fi

  if [[ "$s" =~ ^pnpm[[:space:]]+exec([[:space:]]|$) ]] \
    || [[ "$s" =~ ^pnpm[[:space:]]+dlx([[:space:]]|$) ]]; then
    echo ask
    return
  fi

  echo allow
}

classify_one() {
  local s="$1"
  s=$(printf '%s' "$s" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [[ -z "$s" ]]; then
    echo allow
    return
  fi

  s=$(strip_rtk_prefix "$s")

  if [[ "$s" =~ ^gh[[:space:]] ]]; then
    classify_gh "$s"
    return
  fi

  if [[ "$s" =~ ^git([[:space:]]|$) ]]; then
    classify_git "$s"
    return
  fi

  if [[ "$s" =~ ^pnpm([[:space:]]|$) ]]; then
    classify_pnpm "$s"
    return
  fi

  echo allow
}

worst=allow
while IFS= read -r seg; do
  [[ -z "$seg" ]] && continue
  verdict=$(classify_one "$seg")
  if [[ "$verdict" == deny ]]; then
    worst=deny
    break
  fi
  if [[ "$verdict" == ask && "$worst" == allow ]]; then
    worst=ask
  fi
done < <("$JQ" -nr --arg cmd "$cmd" '
  $cmd
  | gsub("\\s*&&\\s*"; "\u0001")
  | gsub("\\s*\\|\\|\\s*"; "\u0001")
  | gsub("\\s*;\\s*"; "\u0001")
  | split("\u0001")[]
  | gsub("^\\s+"; "")
  | gsub("\\s+$"; "")
  | select(length > 0)
')

"$JQ" -nc --arg p "$worst" '{permission: $p}'

exit 0
