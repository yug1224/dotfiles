---
name: review-advisor
description: Guides code review by delegating to the review-advisor specialist agent. Use when reviewing pull requests, examining code changes, checking code quality, or performing pre-merge reviews. Triggers for review, PR, pull request, code review, diff, レビュー, コードレビュー, プルリクエスト.
---

# Review Advisor Dispatcher

コードレビュータスクを検出し、`review-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- PR のレビュー依頼
- コード変更の品質チェック
- マージ前のレビュー
- 特定ファイルのレビュー

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する (GitHub CLI を優先):

1. **PR 情報**: `gh pr view` で PR の説明を取得し、`gh pr diff` で変更差分を取得する
2. **PR チェック**: `gh pr checks` で CI の状態を確認する
3. **変更履歴**: `git log` / `git blame` で変更箇所の履歴と背景を把握する
4. **プロジェクトルール**: `.cursor/rules/` 内のコーディング規約を Read で収集する
5. **影響範囲**: Grep で変更箇所の呼び出し元・依存先を調査する
6. **静的解析**: `package.json` の scripts を確認し、該当するリント・型チェックコマンドで静的解析結果を確認する
7. **ランタイム状況** (該当する場合): Datadog MCP の `get_monitors` / `get_logs` で関連するモニター/ログを確認する

8. **レビュー観点チェックリスト**: 網羅的なレビュー観点の確認が必要な場合は [references/code-review-checklist.md](references/code-review-checklist.md) を参照する

GitHub CLI で対応できない操作（`search_code` 等）は GitHub MCP にフォールバックする。

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **PR 情報**: (PR 番号、タイトル、変更ファイル数)
> - **CI 状態**: (gh pr checks の結果要約)
> - **影響範囲**: (呼び出し元・依存先の要約)
> - **静的解析**: (lint / typecheck の結果)
> - **ランタイム状況**: (Datadog から取得した情報の要約、該当する場合)

## Phase 2: サブエージェントへの委譲

Task ツールで `review-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `review-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - PR 情報: (渡す PR 情報の要約)
>   - 影響範囲: (渡す調査結果の要約)

プロンプトには以下を含める:

- ユーザーのタスク内容（レビュー対象の PR 番号やファイル）
- Phase 1 で収集したコンテキスト:
  - PR の説明と変更差分
  - CI の状態
  - 変更履歴と背景
  - プロジェクトのコーディング規約
  - 影響範囲の調査結果
  - 静的解析結果
  - ランタイム状況 (該当する場合)

## Phase 3: 結果の適用

サブエージェントのレビュー結果を確認し、対応する:

1. Critical な指摘は優先的に修正する
2. Suggestion は検討し、妥当であれば修正する
3. 修正が必要な場合は、該当する開発エージェント (`frontend-advisor`, `backend-advisor` 等) に委譲する
