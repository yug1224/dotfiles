#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

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

# deno
export PATH="/Users/yuji/.deno/bin:$PATH"

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


# general use
alias ls='exa'
alias lsa='exa -a'
alias ll='exa -lbF --time-style=full-iso --git --color-scale'
alias lla='exa -lbFa --time-style=full-iso --git --color-scale'

# # speciality views
# alias lS='exa -1'
# alias lt='exa --tree --level=2'

alias history='history 1'
alias g='git'
alias n='npm'
alias y='yarn'
alias v='volta'
