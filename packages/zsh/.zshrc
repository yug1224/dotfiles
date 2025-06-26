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

alias cat='bat'
alias sed='gsed'

alias b='brew'
alias c='code'
alias g='git'
alias h='history 1'
alias lh='lefthook'
alias m='mise'
alias n='npm'
alias y='yarn'
alias c='code'

alias gsw='(){
  git fetch origin $1 && git switch -fC $1 origin/$1
}'

source ~/.zsh_plugins/gibo-completion.zsh
source ~/.zsh_plugins/lefthook-completion.zsh

# MISE
export MISE_SHELL=zsh
export __MISE_ORIG_PATH="$PATH"

mise() {
  local command
  command="${1:-}"
  if [ "$#" = 0 ]; then
    command /opt/homebrew/bin/mise
    return
  fi
  shift

  case "$command" in
  deactivate|shell|sh)
    # if argv doesn't contains -h,--help
    if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]; then
      eval "$(command /opt/homebrew/bin/mise "$command" "$@")"
      return $?
    fi
    ;;
  esac
  command /opt/homebrew/bin/mise "$command" "$@"
}

_mise_hook() {
  eval "$(/opt/homebrew/bin/mise hook-env -s zsh)";
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_mise_hook]+1}" ]]; then
  precmd_functions=( _mise_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_mise_hook]+1}" ]]; then
  chpwd_functions=( _mise_hook ${chpwd_functions[@]} )
fi

_mise_hook
if [ -z "${_mise_cmd_not_found:-}" ]; then
    _mise_cmd_not_found=1
    [ -n "$(declare -f command_not_found_handler)" ] && eval "${$(declare -f command_not_found_handler)/command_not_found_handler/_command_not_found_handler}"

    function command_not_found_handler() {
        if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /opt/homebrew/bin/mise hook-not-found -s zsh -- "$1"; then
          _mise_hook
          "$@"
        elif [ -n "$(declare -f _command_not_found_handler)" ]; then
            _command_not_found_handler "$@"
        else
            echo "zsh: command not found: $1" >&2
            return 127
        fi
    }
fi

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
