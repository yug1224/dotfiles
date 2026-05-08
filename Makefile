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
	stow -R -v -d ./packages -t ~/.config git mise shared
	stow -R -v -d ./packages -t ~/Library/Preferences/pnpm pnpm
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Code/User code
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Cursor/User code
	mkdir -p ~/.claude
	stow -R -v -d ./packages -t ~/.cursor cursor
	stow -R -v -d ./packages -t ~/.claude claude

.PHONY: node
node:
	npm install
