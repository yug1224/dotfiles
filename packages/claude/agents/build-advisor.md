---
name: build-advisor
description: 実装専門アドバイザー（提案のみ・ファイル書込なし）。実装・テストの書込は build-worker。バックエンド・フロント・インフラ・a11y の実装方針を提案する。ユーザーが「サブエージェントを使って」「マルチエージェントで」等と明示した場合、またはサブエージェントを使うコマンドから起動された場合にのみ使用する。
model: claude-opus-5
tools: Read, Grep, Glob, WebFetch, Bash
---

@~/.config/shared/ai/agents/build-advisor.md
