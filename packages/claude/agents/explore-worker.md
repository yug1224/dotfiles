---
name: explore-worker
description: コードベース調査ワーカー（sonnet・読み取り専用）。軽いファイル発見は組み込み explore、書込は design/build-worker。親 Orchestrator が構造・意味・影響範囲の調査を委譲するときに使う。起動時は Task の model を必ず渡す（sonnet。composer-2.5-fast 禁止）。
model: sonnet
tools: Read, Grep, Glob, WebFetch, Bash
---

@~/.config/shared/ai/agents/explore-worker.md
