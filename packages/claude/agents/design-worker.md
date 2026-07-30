---
name: design-worker
description: 設計成果物の書込ワーカー（sonnet）。design-advisor（sonnet・提案のみ）とは別。親 Orchestrator が ADR・OpenAPI・スキーマ設計文書・OpenSpec 等の書込を委譲するときに使う。実装コードは書かない。起動時は Task の model を必ず渡す（sonnet。composer-2.5-fast 禁止）。
model: sonnet
tools: Read, Grep, Glob, WebFetch, Bash, Write, Edit
---

@~/.config/shared/ai/agents/design-worker.md
