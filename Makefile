.PHONY: install
install:
	@sudo true
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

.PHONY: brew
brew:
	brew bundle -v --file=~/Workspaces/dotfiles/Brewfile

.PHONY: stow
stow:
	stow -R -v -d ~/Workspaces/dotfiles/packages -t ~ zsh ssh
	stow -R -v -d ~/Workspaces/dotfiles/packages -t ~/Library/Application\ Support/Code/User code

.PHONY: node
node:
	npm install

.PHONY: all
all:
	install brew stow
