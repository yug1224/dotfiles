---
name: test-advisor
description: Guides test strategy and implementation by delegating to the test-advisor specialist agent. Use when writing tests, designing test cases, improving coverage, or setting up test infrastructure. Triggers for test, spec, testing, coverage, unit test, integration test, E2E, Playwright, Vitest, Storybook stories, テスト, カバレッジ, テストケース.
---

# Test Advisor Dispatcher

テスト実装タスクを検出し、`test-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- テストコードの追加・修正
- テスト戦略の策定
- カバレッジ改善
- テストインフラの設定
- Storybook ストーリーの作成

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のテスト関連ルール（テストファイル配置、命名規則等）を Read で収集する
2. **テスト対象コード**: テスト対象のソースコードを Read で確認する
3. **既存テストパターン**: Glob で既存テストファイル (`*.spec.ts`, `*.test.ts`, `*.stories.tsx`) の配置を調査し、Read で同ドメインの既存テストコードを参考実装として確認する
4. **テスト設定**: テスト設定ファイル (`vitest.config.ts` 等) を Read で確認する
5. **ライブラリドキュメント**: context7 MCP で Vitest / Playwright / MSW の最新 API を確認する (`resolve-library-id` → `query-docs`)
6. **テスト戦略マトリクス**: テスト種別の使い分けやカバレッジ目標の確認が必要な場合は [references/test-strategy-matrix.md](references/test-strategy-matrix.md) を参照する

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **テスト対象**: (テスト対象のソースファイルパスと概要)
> - **既存テストパターン**: (参照した既存テストファイルとパターンの要約)
> - **テスト設定**: (確認したテスト設定ファイルの要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)

## Phase 2: サブエージェントへの委譲

Task ツールで `test-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `test-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - テスト対象: (渡すソースコードの要約)
>   - 既存パターン: (渡す既存テストパターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のテストルール
  - テスト対象のソースコード
  - 同ドメインの既存テストコード
  - テスト設定
  - テストライブラリの最新 API ドキュメント

## Phase 3: 結果の適用

サブエージェントの提案に基づいてテストを実装する:

1. 提案されたテストケース設計に従ってテストコードを作成する
2. `package.json` の scripts を確認し、該当するテスト実行コマンドで全テストがパスすることを確認する
3. 問題があれば `test-advisor` に再度相談する
