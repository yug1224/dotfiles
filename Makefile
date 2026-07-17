.PHONY: install
install:
	@sudo true
	./install.sh

MISE_MIN_VERSION := 2026.7.7

.PHONY: mise-gate
mise-gate:
	@command -v mise >/dev/null || brew install mise
	@cur="$$(mise --version | awk '{print $$1}')"; \
	if [ "$$(/usr/bin/printf '%s\n%s\n' "$(MISE_MIN_VERSION)" "$$cur" | /usr/bin/sort -V | /usr/bin/head -n1)" != "$(MISE_MIN_VERSION)" ]; then \
		echo "mise $$cur < $(MISE_MIN_VERSION); upgrading via brew..."; \
		PATH="/usr/bin:$$PATH" NONINTERACTIVE=1 brew update && PATH="/usr/bin:$$PATH" NONINTERACTIVE=1 brew upgrade mise; \
	fi
	@mise --version
	@mise -C "$(CURDIR)" trust

.PHONY: mise
mise: mise-gate
	mise -C "$(CURDIR)" bootstrap --yes

# 互換・部分再適用
.PHONY: mise-dotfiles
mise-dotfiles: mise-gate
	mise -C "$(CURDIR)" bootstrap --only dotfiles --yes

.PHONY: mise-tools
mise-tools: mise-dotfiles
	mise -C "$(CURDIR)" bootstrap --only tools --yes

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

.PHONY: check-bootstrap
check-bootstrap:
	@if [ "$$(uname -s)" = "Darwin" ]; then \
	  command -v mise >/dev/null || (echo "mise not found; run: make mise" && exit 1); \
	  mise -C "$(CURDIR)" bootstrap packages status --missing; \
	fi

.PHONY: check
check: check-fmt check-sync test-scripts check-bootstrap
