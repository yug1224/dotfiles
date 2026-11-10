#!/usr/bin/env bash
# Shared guard: Cursor beforeShellExecution JSON on stdin → { "permission": "allow"|"deny" }.
# 文字列での判定なので、変数展開・alias・python などの別インタプリタ経由は見抜けない。
# 誤操作を止める柵として使い、push / merge の最終防御は GitHub のブランチ保護に置く。
set -uo pipefail

if [[ -z "${JQ:-}" ]]; then
  if [[ -x "$HOME/.local/share/mise/shims/jq" ]]; then
    JQ="$HOME/.local/share/mise/shims/jq"
  elif command -v jq &>/dev/null; then
    JQ="$(command -v jq)"
  else
    JQ=""
  fi
fi

deny_json() {
  printf '%s\n' '{"permission":"deny","user_message":"guard-shell: jq が未インストールです。make mise（packages/mise/config.toml の jq）でインストールしてください。","agent_message":"Shell ガードを実行できません。"}'
}

input=$(cat || true)

if [[ -z "$JQ" || ! -x "$JQ" ]]; then
  deny_json
  exit 0
fi

if [[ -z "$input" ]] || ! "$JQ" -e . >/dev/null 2>&1 <<<"$input"; then
  "$JQ" -nc '{permission:"deny", user_message:"guard-shell: 不正な入力です。"}'
  exit 0
fi

cmd=$("$JQ" -r '.command // ""' <<<"$input")
if [[ -z "$cmd" ]]; then
  "$JQ" -nc '{permission:"deny", user_message:"guard-shell: command が空です。"}'
  exit 0
fi

# --- 判定ロジック本体（単一 jq プロセス） ------------------------------
# bash 側はここから下の探索・fail-closed・入力検証・出力 JSON のみを担う。
# 判定仕様（区切り／反復正規化／ラッパー／git・gh・rm の判定）はすべて
# 以下の jq プログラム 1 本に集約している（jq プロセスは 1 回のみ起動）。
read -r -d '' JQ_PROGRAM <<'JQEOF' || true
def MAXDEPTH: 3;

def ltrim: sub("^[\\s]+"; "");
def rtrim: sub("[\\s]+$"; "");
def trim: ltrim | rtrim;

def strip_quotes:
  if (length >= 2) and
     ( (.[0:1] == "'" and .[length-1:length] == "'")
       or (.[0:1] == "\"" and .[length-1:length] == "\"") )
  then .[1:length-1]
  else .
  end;

def firstword_rest:
  if . == "" then {w:"", rest:""}
  else capture("^(?<w>\\S+)(?<rest>.*)$")
  end;

# 先頭のオプション（値を取るものは次トークンごと消費）を反復して剥がす。
def strip_leading_opts($valueOpts):
  def go:
    (ltrim) as $t
    | if ($t | test("^-")) then
        ($t | firstword_rest) as $m
        | ($m.rest | ltrim) as $r1
        | if ($valueOpts | index($m.w)) then
            ($r1 | firstword_rest) as $m2
            | ($m2.rest | ltrim | go)
          else
            ($r1 | go)
          end
      else
        $t
      end;
  go;

# env: 先頭の "-*" または "*=*" トークンを反復して剥がす。
# 値を取るオプション（-u/--unset, -C/--chdir）は次トークンも消費する。
# -S/--split-string は「分割されたコマンド列」を渡す指定なので、
# 引用符を保ったまま eval 形式へ変換し、既存の eval 再帰判定に委ねる。
def strip_env_prefix:
  def go:
    (ltrim) as $t
    | if $t == "" then $t
      else
        ($t | firstword_rest) as $m
        | ($m.w) as $w
        | if ($w == "-S") or ($w == "--split-string") then
            "eval " + ($m.rest | ltrim)
          elif ($w | test("^--split-string=")) then
            "eval " + ($w | sub("^--split-string="; "")) + $m.rest
          elif ($w == "-u") or ($w == "--unset") then
            ($m.rest | ltrim | firstword_rest) as $m2
            | ($m2.rest | ltrim | go)
          elif ($w | test("^--unset=")) then
            ($m.rest | go)
          elif ($w == "-C") or ($w == "--chdir") then
            ($m.rest | ltrim | firstword_rest) as $m2
            | ($m2.rest | ltrim | go)
          elif ($w | test("^--chdir=")) then
            ($m.rest | go)
          elif ($w | test("^-")) or ($w | test("=")) then
            ($m.rest | go)
          else
            $t
          end
      end;
  go;

def nice_strip:
  . as $r
  | if ($r | test("^-n\\s+")) then
      (($r | capture("^-n\\s+(?<rest>.*)$")).rest | ltrim) as $r1
      | ($r1 | firstword_rest) as $m2
      | ($m2.rest | ltrim)
    elif ($r | test("^-[0-9]+\\s+")) then
      ($r | capture("^-[0-9]+\\s+(?<rest>.*)$")).rest
    elif ($r | test("^-")) then
      ($r | firstword_rest) as $m2
      | ($m2.rest | ltrim)
    else
      $r
    end;

def timeout_strip:
  strip_leading_opts(["-s", "-k", "--signal", "--kill-after"])
  | firstword_rest
  | .rest | ltrim;

# 先頭ラッパー語 $w に応じて残り文字列 $rest を剥がす。マッチしなければ null。
def wrapper_strip($w; $rest):
  if $w == "env" then ($rest | strip_env_prefix)
  elif ($w == "command" or $w == "builtin" or $w == "time" or $w == "nohup") then ($rest | ltrim | strip_leading_opts([]))
  elif $w == "exec" then ($rest | ltrim | strip_leading_opts(["-a"]))
  elif $w == "sudo" then
    ($rest | ltrim | strip_leading_opts(
      ["-u", "-g", "-p", "-r", "-C", "-D", "-R", "-T", "-U",
       "--user", "--group", "--prompt", "--role", "--close-from", "--directory", "--type"]))
  elif $w == "nice" then ($rest | ltrim | nice_strip)
  elif $w == "timeout" then ($rest | ltrim | timeout_strip)
  elif $w == "xargs" then ($rest | ltrim | strip_leading_opts(["-n", "-I", "-P", "-s", "-L"]))
  else null
  end;

# 1 段階だけ剥がす。変化なければ入力をそのまま返す（呼び出し側が同一判定で停止）。
def strip_layer_once:
  . as $s
  | if ($s | test("^\\([\\s]*")) then
      ($s | capture("^\\([\\s]*(?<r>.*)$")).r
    elif ($s | test("^\\{[\\s]+")) then
      ($s | capture("^\\{[\\s]+(?<r>.*)$")).r
    elif ($s | test("^![\\s]+")) then
      ($s | capture("^![\\s]+(?<r>.*)$")).r
    elif ($s | test("^\\\\")) then
      ($s | sub("^\\\\"; ""))
    elif ($s | test("^(.*[^\\s])[\\s]*\\)[\\s]*$")) then
      ($s | capture("^(?<r>.*[^\\s])[\\s]*\\)[\\s]*$")).r
    elif ($s | test("^(.*[^\\s])[\\s]*\\}[\\s]*$")) then
      ($s | capture("^(?<r>.*[^\\s])[\\s]*\\}[\\s]*$")).r
    elif ($s | test("^[A-Za-z_][A-Za-z0-9_]*=\\S*[\\s]+")) then
      ($s | capture("^[A-Za-z_][A-Za-z0-9_]*=\\S*[\\s]+(?<r>.+)$")).r
    else
      ($s | firstword_rest) as $m
      | ($m.w) as $w
      | if $w == "" then $s
        elif ($w | test("/")) then
          ($w | sub(".*/"; "")) as $wn
          | $wn + $m.rest
        else
          (wrapper_strip($w; $m.rest)) as $ws
          | if $ws == null then $s else $ws end
        end
    end;

# strip_layer_once を変化しなくなるまで（上限 20 回）反復。
def stabilize:
  def go($n):
    if $n <= 0 then .
    else
      . as $s
      | (strip_layer_once) as $s2
      | if $s2 == $s then $s else ($s2 | go($n - 1)) end
    end;
  go(20);

# 文字列内の全ての ' " \ を削除する（分割で片側だけ残った引用符 / 引用符で囲まれた
# コマンド名 / p\ush のようなエスケープ対策）。
def deleted_quotes:
  gsub("'"; "") | gsub("\""; "") | gsub("\\\\"; "");

def normalize_gh_once:
  . as $s
  | if ($s | test("^gh\\s+-R\\s+\\S+\\s+.+$")) then
      "gh " + ($s | capture("^gh\\s+-R\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^gh\\s+--repo\\s+\\S+\\s+.+$")) then
      "gh " + ($s | capture("^gh\\s+--repo\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^gh\\s+(--repo|-R)=\\S*\\s+.+$")) then
      "gh " + ($s | capture("^gh\\s+(--repo|-R)=\\S*\\s+(?<r>.+)$")).r
    else $s
    end;

def normalize_gh:
  def go:
    . as $s
    | (normalize_gh_once) as $s2
    | if $s2 == $s then $s else ($s2 | go) end;
  go;

def normalize_git_once:
  . as $s
  | if ($s | test("^git\\s+-C\\s+\"[^\"]*\"\\s+.+$")) then
      "git " + ($s | capture("^git\\s+-C\\s+\"[^\"]*\"\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+-C\\s+'[^']*'\\s+.+$")) then
      "git " + ($s | capture("^git\\s+-C\\s+'[^']*'\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+-C\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+-C\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+-c\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+-c\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--(exec-path|config-env)=\\S*\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--(exec-path|config-env)=\\S*\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--config-env\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--config-env\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--no-pager\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--no-pager\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--git-dir=\\S*\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--git-dir=\\S*\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--git-dir\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--git-dir\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--work-tree=\\S*\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--work-tree=\\S*\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--work-tree\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--work-tree\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--namespace=\\S*\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--namespace=\\S*\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+--namespace\\s+\\S+\\s+.+$")) then
      "git " + ($s | capture("^git\\s+--namespace\\s+\\S+\\s+(?<r>.+)$")).r
    elif ($s | test("^git\\s+(-P|--paginate|--bare|--literal-pathspecs|--no-replace-objects|--no-optional-locks)\\s+.+$")) then
      "git " + ($s | capture("^git\\s+(-P|--paginate|--bare|--literal-pathspecs|--no-replace-objects|--no-optional-locks)\\s+(?<r>.+)$")).r
    else $s
    end;

def normalize_git:
  def go:
    . as $s
    | (normalize_git_once) as $s2
    | if $s2 == $s then $s else ($s2 | go) end;
  go;

def is_denied_rm:
  . as $s
  | if (($s | test("^rm\\s")) | not) then false
    else
      ( ($s | test("(^|\\s)-[A-Za-z]*[rR]")) or ($s | test("--recursive")) ) as $has_r
      | ( ($s | test("(^|\\s)-[A-Za-z]*[fF]")) or ($s | test("--force")) ) as $has_f
      | $has_r and $has_f
    end;

def is_denied_gh:
  . as $s
  | if (($s | test("^gh(\\s|$)")) | not) then false
    else
      ($s | normalize_gh) as $s2
      | ["^gh\\s+pr\\s+merge", "^gh\\s+repo\\s+delete", "^gh\\s+repo\\s+archive",
         "^gh\\s+release\\s+delete", "^gh\\s+issue\\s+delete", "^gh\\s+gist\\s+delete",
         "^gh\\s+run\\s+delete"] as $pats
      | any($pats[]; . as $p | $s2 | test($p))
    end;

def is_denied_git:
  . as $s
  | if (($s | test("^git(\\s|$)")) | not) then false
    else
      ($s | normalize_git) as $s2
      | ($s2 | sub("^git\\s*"; "")) as $tail
      | ($tail | test("^(subtree\\s+)?push(\\s|$)"))
    end;

# 最終判定: 引用符を残したまま一度、全削除して一度、どちらかで deny なら deny。
def final_judgement:
  . as $s
  | if (($s | is_denied_gh) or ($s | is_denied_rm) or ($s | is_denied_git)) then true
    else
      ($s | deleted_quotes) as $s2
      | (($s2 | is_denied_gh) or ($s2 | is_denied_rm) or ($s2 | is_denied_git))
    end;

# $(...) （1 段ネスト許容）とバッククォートの中身を全て抽出する。
def extract_subs:
  ( [scan("\\$\\(([^()]*(?:\\([^()]*\\)[^()]*)*)\\)")] | map(.[0]) ) as $dollar
  | ( [scan("`([^`]*)`")] | map(.[0]) ) as $backtick
  | $dollar + $backtick;

def split_segments:
  gsub("\r\n"; "\n")
  | gsub("\\s*&&\\s*"; "\u0001")
  | gsub("\\s*\\|\\|\\s*"; "\u0001")
  | gsub("\\s*;\\s*"; "\u0001")
  | gsub("\\s*\\|\\s*"; "\u0001")
  | gsub("\\s*&\\s*"; "\u0001")
  # find -exec / -ok の後ろは別コマンドとして判定する
  | gsub("\\s+-(exec|execdir|ok|okdir)\\s+"; "\u0001")
  | gsub("\n"; "\u0001")
  | split("\u0001")
  | map(trim)
  | map(select(length > 0));

# classify($raw; $depth): $raw をセグメント分割し、いずれかが deny なら true。
# 自己再帰のみを用いる（相互再帰を避けるため、per-segment 判定もこの中に inline する）。
def classify($raw; $depth):
  ($raw | split_segments) as $segs
  | any($segs[];
      . as $s0
      | ($s0 | trim) as $s0t
      | if $s0t == "" then false
        else
          (
            if $depth < MAXDEPTH then
              ($s0t | extract_subs) as $subs
              | any($subs[]; classify(.; $depth + 1))
            else false
            end
          ) as $sub_deny
          | if $sub_deny then true
            else
              ($s0t | stabilize) as $s
              | ($s | firstword_rest) as $m0
              | ($m0.w | sub(".*/"; "")) as $wn0
              | (
                  if ($depth < MAXDEPTH) and ($wn0 == "bash" or $wn0 == "sh" or $wn0 == "zsh" or $wn0 == "dash") then
                    ( { rest: ($m0.rest | ltrim), has_c: false }
                      | until(
                          (.rest | test("^-")) | not;
                          ( . as $st
                            | ($st.rest | firstword_rest) as $om
                            | { rest: ($om.rest | ltrim),
                                has_c: ($st.has_c or ($om.w | test("c"))) }
                          )
                        )
                    ) as $optres
                    | if $optres.has_c then
                        { kind: "inner", inner: ($optres.rest | strip_quotes) }
                      else
                        { kind: "none" }
                      end
                  elif ($depth < MAXDEPTH) and ($wn0 == "eval") then
                    { kind: "inner", inner: ($m0.rest | ltrim | strip_quotes) }
                  else
                    { kind: "none" }
                  end
                ) as $wrap
              | if $wrap.kind == "inner" then
                  classify($wrap.inner; $depth + 1)
                else
                  ($s | final_judgement)
                end
            end
        end
    );

if (classify($cmd; 0)) then "deny" else "allow" end
JQEOF

worst=$("$JQ" -nr --arg cmd "$cmd" "$JQ_PROGRAM" 2>/dev/null)

if [[ "$worst" != "allow" && "$worst" != "deny" ]]; then
  # jq プログラムの実行エラーは fail-closed。
  "$JQ" -nc '{permission:"deny", user_message:"guard-shell: 判定処理に失敗しました。"}'
  exit 0
fi

if [[ "$worst" == deny ]]; then
  "$JQ" -nc '{
    permission: "deny",
    user_message: "guard-shell: 破壊的コマンド（git push / rm -rf / 破壊的な gh）を拒否しました。",
    agent_message: "このコマンドはエージェントから実行できません。ユーザーに実行を依頼してください。"
  }'
else
  "$JQ" -nc '{permission: "allow"}'
fi
exit 0
