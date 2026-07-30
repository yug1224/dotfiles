---
name: general-worker
description: 汎用作業ワーカー（sonnet）。外部 URL 取得の要約（WebFetch 等）や、専門 Worker が決まらない複数ステップのフォールバック。明確なら explore/build/design-worker を優先。親は Task で model: sonnet を必ず渡す。
model: sonnet
tools: Read, Grep, Glob, WebFetch, Bash, Write, Edit
---

@~/.config/shared/ai/agents/general-worker.md
