.PHONY: install
install:
	@sudo true
	./install.sh

.PHONY: brew
brew:
	brew bundle -v --file=./Brewfile

.PHONY: stow
stow:
	stow -R -v -d ./packages -t ~ ssh tig zsh
	stow -R -v -d ./packages -t ~/.config git mise
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Code/User code

.PHONY: node
node:
	npm install
