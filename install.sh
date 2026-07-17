#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# Homebrew の curl が依存欠落で壊れていることがあるため、seed では常にシステム curl を使う
CURL=/usr/bin/curl

if [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
  "$CURL" -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "install.sh: brew not found after install" >&2
  exit 1
fi

# brew curl は依存欠落で dyld abort しうるため実行せず、ライブラリ有無だけ見て修復する
prefix="$(brew --prefix)"
if [[ -x "$prefix/opt/curl/bin/curl" ]]; then
  if [[ ! -e "$prefix/opt/rtmpdump/lib/librtmp.1.dylib" ]]; then
    brew install rtmpdump || true
  fi
  if [[ ! -e "$prefix/opt/openldap/lib/libldap.2.dylib" ]]; then
    brew install openldap || true
  fi
fi

ZPREZTO="${ZDOTDIR:-$HOME}/.zprezto"
if [[ ! -d "$ZPREZTO/.git" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO"
fi

if ! command -v mise >/dev/null 2>&1; then
  brew install mise
fi

if [[ -f "$ROOT/mise.toml" ]]; then
  mise -C "$ROOT" trust
  mise -C "$ROOT" bootstrap --yes
fi
