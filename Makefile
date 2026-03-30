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
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Cursor/User code
	stow -R -v -d ./packages -t ~/.cursor cursor
	# Re-apply smudge filter after stow to replace __DOTFILES__ with the actual repo path
	git checkout -- packages/code/settings.json

.PHONY: node
node:
	npm install
