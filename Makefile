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

.PHONY: node
node:
	npm install
