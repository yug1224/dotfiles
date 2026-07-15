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

.PHONY: mise-tools
mise-tools: mise-dotfiles
	mise install

.PHONY: node
node:
	pnpm install

.PHONY: check-fmt
check-fmt:
	pnpm run check

.PHONY: scaffold-wrappers
scaffold-wrappers:
	./scripts/scaffold-wrappers.sh

.PHONY: check-wrappers
check-wrappers:
	./scripts/scaffold-wrappers.sh --check

.PHONY: check-sync
check-sync:
	REQUIRE_JQ=1 ./scripts/check-allowlist-sync.sh
	./scripts/check-wrapper-parity.sh
	REQUIRE_JQ=1 ./scripts/check-deny-guard-sync.sh
	REQUIRE_JQ=1 ./scripts/check-always-on-sync.sh

.PHONY: test-scripts
test-scripts:
	./scripts/check-allowlist-sync.test.sh

.PHONY: check
check: check-fmt check-sync test-scripts
