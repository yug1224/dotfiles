curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
eval "$(/opt/homebrew/bin/brew shellenv)"
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
