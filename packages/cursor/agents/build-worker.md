---
name: build-worker
description: 実装の書込ワーカー（Composer）。build-advisor（Grok・提案のみ）とは別。親 Orchestrator がまとまった実装・テストコードの書込を委譲するときに使う。軽微な1行修正は親のまま。起動時は Task の model を必ず渡す（composer-2.5。composer-2.5-fast 禁止）。
model: composer-2.5[fast=false]
---

@~/.config/shared/ai/agents/build-worker.md
