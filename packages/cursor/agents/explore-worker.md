---
name: explore-worker
description: コードベース調査ワーカー（Composer・読み取り専用）。軽いファイル発見は組み込み explore、書込は design/build-worker。親 Orchestrator が構造・意味・影響範囲の調査を委譲するときに使う。起動時は Task の model を必ず渡す（composer-2.5。composer-2.5-fast 禁止）。
model: composer-2.5[fast=false]
readonly: true
---

@~/.config/shared/ai/agents/explore-worker.md
