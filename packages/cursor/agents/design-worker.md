---
name: design-worker
description: 設計成果物の書込ワーカー（Composer）。design-advisor（Grok・提案のみ）とは別。親 Orchestrator が ADR・OpenAPI・スキーマ設計文書・OpenSpec 等の書込を委譲するときに使う。実装コードは書かない。起動時は Task の model を必ず渡す（composer-2.5。composer-2.5-fast 禁止）。
model: composer-2.5[fast=false]
---

@~/.config/shared/ai/agents/design-worker.md
