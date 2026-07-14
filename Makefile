.PHONY: install
install:
	@sudo true
	./install.sh

.PHONY: brew
brew:
	brew bundle -v --file=./Brewfile

.PHONY: mise-gate
mise-gate:
	@command -v mise >/dev/null || (echo "mise not found; run: make brew (needs brew 'mise')" && exit 1)
	@mise --version
	@mise -C "$(CURDIR)" trust

.PHONY: mise-dotfiles
mise-dotfiles: mise-gate
	mise -C "$(CURDIR)" dotfiles apply --yes

.PHONY: stow
stow:
	stow -R -v -d ./packages -t ~ ssh zsh
	stow -R -v -d ./packages -t ~/.config mise shared
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Code/User code
	stow -R -v -d ./packages -t ~/Library/Application\ Support/Cursor/User code
	mkdir -p ~/.claude
	stow -R -v -d ./packages -t ~/.cursor cursor
	stow -R -v -d ./packages -t ~/.claude claude

.PHONY: node
node:
	npm install
