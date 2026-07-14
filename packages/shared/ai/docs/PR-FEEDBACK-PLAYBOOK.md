# PR フィードバック Playbook

指摘 → 記録 → 蒸留 → 検証の閉ループ。**log / index / registry は常に `*.local.md`（Git 管理外）**。Git に残すのは蒸留先となった shared rules / commands のみ。

## 1. Capture（記録）

PR マージ後またはレビュー確定後、`docs/feedback-log.local.md`（`~/.config/shared/ai/`）へ追記する。

private org/repo URL・会社名は **書かない**。

## 2. Classify（分類）

| 分類             | 条件                              | ID 形式     |
| ---------------- | --------------------------------- | ----------- |
| ツール横断       | dotfiles / AI 設定 / レビュー cmd | FB-00x      |
| プロジェクト固有 | 業務リポジトリ                    | 例: FB-Dxxx |

## 3. Distill（蒸留）

| Capture / Index / Registry（すべて local）                                            | 詳細の蒸留先                                                |
| ------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `feedback-log.local.md` / `feedback-index.local.md` / `pr-feedback-registry.local.md` | shared rule・command（汎用化できたもの）または `*.local.md` |

## 4. Verify（検証）

| 手段 | 内容                                                                                                                    |
| ---- | ----------------------------------------------------------------------------------------------------------------------- |
| 手動 | `wrapper-parity-checklist.md`、`leakage-checklist.md`、ゴールデンパス（registry 参照 cmd、サブエージェント明示/非明示） |
| 再発 | 同一 FB-ID が log に 2 回出たら rule 強化または checklist 追加                                                          |

## 5. Archive（アーカイブ）

- log は 90 日目安で index + registry へ集約
- `*.local.*` が log / index / registry の正本（Git にアーカイブしない）

## 関連ドキュメント

- [LOCAL-SETUP.md](./LOCAL-SETUP.md)
- [../rules/meta/ai-config-rule.md](../rules/meta/ai-config-rule.md)
