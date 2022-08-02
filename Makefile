.PHONY: install
install:
	@sudo true
	./install.sh

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
