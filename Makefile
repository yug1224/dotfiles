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
	pnpm run fmt:check

.PHONY: check-lint
check-lint:
	pnpm run lint:check

.PHONY: check-typecheck
check-typecheck:
	pnpm run type:check

.PHONY: check-sync
check-sync:
	./scripts/check-context-bloat.sh --fail
	./scripts/check-kernel-sync.sh
	./scripts/check-local-tracked.sh

.PHONY: test-scripts
test-scripts:
	./packages/shared/ai/hooks/guard-shell.test.sh

.PHONY: check-bootstrap
check-bootstrap:
	@if [ "$$(uname -s)" = "Darwin" ]; then \
	  command -v mise >/dev/null || (echo "mise not found; run: make mise" && exit 1); \
	  mise -C "$(CURDIR)" bootstrap packages status --missing; \
	fi

.PHONY: check
check: check-fmt check-lint check-typecheck check-sync test-scripts check-bootstrap
