# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# prezto
autoload -Uz promptinit
promptinit
prompt kylewest

# brew
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

LISTMAX=1000

# if [ -r ~/.zshrc ]; then echo 'export GPG_TTY=$(tty)' >> ~/.zshrc; \
#   else echo 'export GPG_TTY=$(tty)' >> ~/.zprofile; fi
export GPG_TTY=$(tty)

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# alias
alias ls='eza'
alias lsa='eza -a'
alias ll='eza -lbF --time-style=full-iso --git'
alias lla='eza -lbFa --time-style=full-iso --git'
alias date='gdate'

alias cat='bat --paging=never'
alias sed='gsed'

alias b='brew'
alias c='cursor'
alias g='git'
alias h='history 1'
alias lh='lefthook'
alias m='mise'
alias n='npm'
alias y='yarn'

alias gsw='(){
  git fetch origin $1 && git switch -fC $1 origin/$1
}'

source ~/.zsh_plugins/gibo-completion.zsh
source ~/.zsh_plugins/lefthook-completion.zsh

# LeftHook
function chpwd_lefthook_install() {
  # .git/info/lefthook.checksum が存在するかチェック
  if [[ -e ".git/info/lefthook.checksum" ]]; then
    lefthook uninstall >/dev/null
  fi

  # lefthook.yml が存在するかチェック
  if [[ -e "lefthook.yml" ]]; then
    lefthook install >/dev/null
  fi
}
add-zsh-hook chpwd chpwd_lefthook_install

# MISE
eval "$(mise activate zsh)"
eval "$(mise hook-env 2>/dev/null)"

# Cursor agent: working_directory指定時にzshフック(precmd/chpwd/preexec)が
# 発火しないため、miseのフックベースのバージョン切替が機能しない。
# shimsをPATH先頭に追加して、コマンドごとに正しいバージョンを解決する。
if [[ -n "$CURSOR_AGENT" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
