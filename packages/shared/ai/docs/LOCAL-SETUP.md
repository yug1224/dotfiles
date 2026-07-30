# ローカル AI ルール初期化

`.local.*` は **Git 管理しない**（`packages/shared/ai/.gitignore`）。展開先（`~/.config/shared/ai/`）で個人・プロジェクト固有ルールを直接編集する。

公開境界の契約は [BOUNDARY.md](./BOUNDARY.md) を参照。

## 前提

```bash
make mise   # shared → ~/.config/shared/ai/
```

## ルールファイル

`~/.config/shared/ai/rules/conventions/`:

| ファイル                         | 用途                                     | 典型層        |
| -------------------------------- | ---------------------------------------- | ------------- |
| `coding-rule.local.md`           | **実装時**のコーディング規約             | L2            |
| `pr-review-rule.local.md`        | **レビュー時**の追加観点                 | L1/L2 overlay |
| `review-common-rule.local.md`    | レビュー共通のローカル追記               | L1 overlay    |
| `pr-feedback-registry.local.md`  | フィードバック registry（FB-00x / FB-D） | L2            |
| `ticket-retrieval-rule.local.md` | チケット取得のプロバイダ固有アダプタ     | L1/L2 overlay |

```bash
SHARED=~/.config/shared/ai
mkdir -p "$SHARED/rules/conventions" "$SHARED/docs"
touch "$SHARED/rules/conventions/coding-rule.local.md" \
      "$SHARED/rules/conventions/pr-review-rule.local.md" \
      "$SHARED/rules/conventions/review-common-rule.local.md" \
      "$SHARED/rules/conventions/pr-feedback-registry.local.md" \
      "$SHARED/rules/conventions/ticket-retrieval-rule.local.md" \
      "$SHARED/docs/feedback-log.local.md" \
      "$SHARED/docs/feedback-index.local.md"
```

## コマンドリネーム対応表（ローカル追従用）

コマンド basename 変更後、手元の `*.local.md` / Cursor・Claude ラッパー内の `@~/.config/shared/ai/commands/<name>.md` を旧名から新名へ更新する。

| 旧                      | 新                     |
| ----------------------- | ---------------------- |
| `pr-review`             | `review-pr`            |
| `diff-review`           | `review-diff`          |
| `blog-review`           | `review-blog`          |
| `magi-pr-review`        | `review-pr-magi`       |
| `blog-plan`             | `plan-blog`            |
| `capture-pr-lesson`     | `capture-pr-feedback`  |
| `fix-issue`             | `analyze-issue`        |
| `graphic-record-prompt` | `write-graphic-prompt` |

（上記 8 件。ローカル側の `fix-issue.local.md` 等も新 basename に合わせてリネームする。）

## フィードバックの蒸留

log / index / registry は **すべて local**:

1. `docs/feedback-log.local.md` に記録
2. `docs/feedback-index.local.md` に ID を追加
3. `pr-feedback-registry.local.md` に概要行を追加
4. 詳細を shared rule（汎用化できたもの）または `*.local.md` に追記

**dotfiles Git には log / index / registry をコミットしない。** Git に載せるのは蒸留先となった shared rules / commands のみ。

## Cursor 専用（任意）

`~/.cursor/rules/**/*.local.mdc`（`packages/cursor/.gitignore` 対象）

### `coding-rule.local` と alwaysApply（推奨）

- **Git `alwaysApply: true` に載せない**（常時税・過制約の主因になりやすい）
- Cursor ラッパーは `alwaysApply: false` の agent-requestable、または `/apply-coding-rule` 起動時のみ Read
- 「実装前に必ずサブエージェント」等の剛性句は、必要時だけ judgement（周囲のコード・タスク規模）に寄せる
- L2 本文の書き換えは手元で行う（本ドキュメントは指針のみ）

## Meta LOOP（モデル割当の推奨）

親チャット（Orchestrator）: **Grok 4.5**（Cursor モデルプール）。Advisor（design/build/quality）: Cursor は **Grok 4.5**（明示時のみ・読み取り）、Claude Code は Grok 非対応のため **`sonnet`**。作業系（`design-worker` / `build-worker` / `explore-worker` / `general-worker`、MAGI、組み込み `explore` / `generalPurpose` / `docs-researcher` / `shell`）: Cursor は **Composer 2.5**（カスタム agent は `[fast=false]`）、Claude Code は Composer 非対応のため **`sonnet`** に分岐（haiku / `composer-2.5-fast` は使わない）。

`quality-worker` は置かない。品質は `quality-advisor`（提案・レビュー）、テスト**コード**の書込は `build-worker`。品質・意味・影響範囲の調査は `explore-worker`（readonly）。

### 委譲基準

`agent-delegation-rule`「委譲ゲート（MUST）」と同じ閾値（正本: `@~/.config/shared/ai/rules/conventions/agent-delegation-rule.md`）:

- **親が直接**: 1〜数行・ユーザー貼付済み・直前ターンで得た要約の続き・統合・ユーザー返答（WebFetch し直さない）
- **`explore-worker`**: 構造・意味・影響範囲の品質調査（読み取り専用。ユーザー明示不要）
- **`design-worker`**: ADR / OpenAPI / スキーマ設計文書 / OpenSpec 等の設計成果物をリポジトリに書くとき
- **`build-worker`**: 新規機能、または変更見込み 3 ファイル以上、またはまとまった実装・テストコード
- **`general-worker`**: 専門が曖昧な複数ステップ（迷ったらこれ。直実行しない）。外部 URL の WebFetch（主目的または複数 URL）の取得・構造化要約も含む
- **組み込み `explore`**: 軽いファイル発見・広域探索のみ（品質調査には使わない）
- **組み込み `generalPurpose`**: 互換・非推奨。可能な限り `general-worker`
- **呼び出さない**: Advisor / MAGI の代替、毎タスク強制、品質レビュー用途

L2（`coding-rule.local.md`）でもまとまった実装は `build-worker`、設計成果物の書込は `design-worker`、品質調査は `explore-worker`、曖昧時は `general-worker` を優先してよい。

### Cursor ラッパーの `model`（bracket オプション）

Cursor 公式 [Subagents](https://cursor.com/docs/subagents) の bracket 構文を使う（Claude Code ラッパーには書かない）。

| 役割                                                       | frontmatter 例                                                                                          |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Advisor                                                    | `model: grok-4.5[effort=high,fast=false]`（Claude Code は `sonnet`）                                    |
| `design-worker` / `build-worker` / `general-worker` / MAGI | `model: composer-2.5[fast=false]`（Claude Code は `sonnet`）                                            |
| `explore-worker`（調査・readonly）                         | `model: composer-2.5[fast=false]` + `readonly: true`（Claude は `sonnet`）                              |
| 軽いファイル発見（組み込み `explore`）                     | Task 呼び出し時に `composer-2.5` を明示（カスタム agent なし）                                          |
| `generalPurpose` / `docs-researcher` / `shell`             | Task 呼び出し時に `composer-2.5` を明示（`generalPurpose` は互換・非推奨。可能な限り `general-worker`） |

`composer-2.5` 単体は fast に落ちることがあるため、カスタム agent では `[fast=false]` を明示する。書込 Worker（`design-worker` / `build-worker`）の Cursor ラッパーは **書込可**（`readonly: true` にしない）。`explore-worker` は調査専用のため **`readonly: true`**（Worker 命名の明示例外）。`make scaffold-wrappers` の agents 既定は readonly + `inherit` のため、モデル pin は手書き frontmatter を維持する。

**Task 呼び出し**: 作業系（Worker / MAGI / `explore-worker` / `explore` / `general-worker` / `generalPurpose` / `docs-researcher` / `shell`）では frontmatter に加え、親が Task の `model` に Cursor は **`composer-2.5`**（`composer-2.5-fast` は使わない）、Claude Code は **`sonnet`** を**必ず**渡す。省略すると親が高コストモデルのとき作業系もそれになりうる。Advisor は省略可。詳細は `agent-delegation-rule`「Task の model 必須（作業系）」。

### トラブルシュート: 作業系が高コストモデルで動く

1. **親が Task せず直実装していないか** — UI 上「Worker」に見えても親の書込のことがある。まとまった実装は `build-worker` を Task する
2. **Task に `model` が付いているか** — `build-worker` / `explore-worker` / `general-worker` / `explore` / `generalPurpose` 等でも `model` 省略だと親モデル継承しうる。Cursor は `composer-2.5`、Claude Code は `sonnet` を明示
3. **Worker 本文の高コストモデル自己判定はソフトガード** — 発火しない場合がある。Task の `model` 指定を正とする
4. **`build-advisor` と取り違えていないか** — Advisor は Grok（Claude は sonnet）・提案のみ。書込は `design-worker` / `build-worker`、調査は `explore-worker`
5. **プラン / admin 制限** — Composer が使えないと公式フォールバックしうる（[Subagents model configuration](https://cursor.com/docs/subagents.md#model-configuration)）
6. **調査が Composer 2.5 fast になる** — 品質調査は組み込み `explore` ではなく `explore-worker`（frontmatter `[fast=false]`）を Task する。UI/ログでモデル名を確認する煙テスト: 親から `subagent_type: "explore-worker"`, `model: "composer-2.5"` を起動し、非 fast であること。`general-worker` も同様に `model: "composer-2.5"`（Claude は `sonnet`）で起動確認

## Cursor と AGENTS.md

Cursor はワークスペース内の nested `AGENTS.md` を自動添付することがある。本リポジトリの `packages/*/AGENTS.md`（shared への symlink）もその対象になりうる。AGENTS.md 本文はメンテ要約に薄くしているが、「常時コンテキストに載せない」は Claude Tier A / Cursor Git 管理 alwaysApply の話であり、Cursor の nested 探索までは止められない。

## 実装 vs レビューの分離

| フェーズ | 主なファイル                                       | サブエージェント                                      |
| -------- | -------------------------------------------------- | ----------------------------------------------------- |
| 実装     | `coding-rule.local.md`                             | ローカル定義に従う                                    |
| レビュー | `review-common-rule` + `pr-review-rule` + registry | **常時**（`explore-worker` + `quality-advisor` 並列） |

**ローカル overlay 注意**: `review-common-rule.local.md` に旧「明示時のみ」「直接調査モード」等が残っていると、正本の常時並列方針を上書きする。`make mise` 後に overlay を見直すこと。

## Git に載せないもの

- 会社名・製品名・private org/repo URL・業務ツールの private URL
- `*.local.*` 全文（`feedback-*.local.md` / `pr-feedback-registry.local.md` 含む）
- 業務リポジトリ固有の詳細ルール（未汎用化分）

詳細: [PR-FEEDBACK-PLAYBOOK.md](./PR-FEEDBACK-PLAYBOOK.md) / [BOUNDARY.md](./BOUNDARY.md)
