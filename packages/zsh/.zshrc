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
export PATH="$HOME/.deno/bin:$PATH"

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# alias
alias ls='eza'
alias lsa='eza -a'
alias ll='eza -lbF --time-style=full-iso --git'
alias lla='eza -lbFa --time-style=full-iso --git'
alias date='gdate'

# # speciality views
# alias lS='exa -1'
# alias lt='exa --tree --level=2'

alias cat='bat'
alias sed='gsed'

alias b='brew'
alias c='code'
alias g='git'
alias h='history 1'
alias lh='lefthook'
alias n='npm'
alias v='volta'
alias y='yarn'
alias c='code'

alias gsw='(){
  git fetch origin $1 && git switch -fC $1 origin/$1
}'
export PATH="/opt/homebrew/opt/go@1.18/bin:$PATH"

source ~/.zsh_plugins/gibo-completion.zsh
source ~/.zsh_plugins/lefthook-completion.zsh

autoload -Uz add-zsh-hook
function chpwd_volta_install() {
  # .node-versionが存在するかチェック
  if [[ -e ".node-version" ]]; then
    # .node-versionから内容を読み取る
    content=$(cat .node-version)
    volta install node@$content --quiet
    volta install npm@bundled --quiet
  fi

  # .nvmrcが存在するかチェック
  if [[ -e ".nvmrc" ]]; then
    # .nvmrcから内容を読み取る
    content=$(cat .nvmrc)

    case $content in
    # lts/argonの場合
    "lts/argon")
      volta install node@4 --quiet
      ;;
    # lts/boronの場合
    "lts/boron")
      volta install node@6 --quiet
      ;;
    # lts/carbonの場合
    "lts/carbon")
      volta install node@8 --quiet
      ;;
    # lts/dubniumの場合
    "lts/dubnium")
      volta install node@10 --quiet
      ;;
    # lts/erbiumの場合
    "lts/erbium")
      volta install node@12 --quiet
      ;;
    # lts/fermiumの場合
    "lts/fermium")
      volta install node@14 --quiet
      ;;
    # lts/galliumの場合
    "lts/gallium")
      volta install node@16 --quiet
      ;;
    # lts/hydrogenの場合
    "lts/hydrogen")
      volta install node@18 --quiet
      ;;
    # lts/*の場合
    "lts/*")
      volta install node@lts --quiet
      ;;
    # latest,current,node,*の場合
    "latest" | "current" | "node" | "*")
      volta install node@latest --quiet
      ;;
    # それ以外の場合
    *)
      volta install node@$content --quiet
      ;;
    esac
    volta install npm@bundled --quiet
  fi
}
add-zsh-hook chpwd chpwd_volta_install

function chpwd_yarn_install() {
  # yarn.lock が存在するかチェック
  if [[ -e "yarn.lock" ]]; then
    FROM=$(git rev-parse --abbrev-ref HEAD)
    TO=$(git rev-parse --abbrev-ref ${-1})
    DIFF=$(git diff --name-only $FROM $TO yarn.lock)
    if [[ -n $DIFF ]]; then
      yarn install
    fi
  fi
}
add-zsh-hook chpwd chpwd_lefthook_install

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
