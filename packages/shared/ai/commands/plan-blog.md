ブログ記事のテーマと概要・補足情報を受け取り、執筆プランを Markdown で作成する。プランは反復前提で、修正版の入力（既存プランファイル）も受け付ける。

**参照ルール**:

- `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`（`blog-base`）
- `@~/.config/shared/ai/rules/blog/writing-style-rule.md`
- `@~/.config/shared/ai/rules/blog/structure-templates-rule.md`
- `@~/.config/shared/ai/rules/blog/topic-ideation-rule.md`
- `@~/.config/shared/ai/rules/blog/meta-and-seo-rule.md`
- `@~/.config/shared/ai/rules/blog/publish-checklist.md`
- （任意・体験記／読み物時）`@~/.config/shared/ai/rules/writing/cognitive-rhythm-writing-rule.md`

**Input**: `/plan-blog` の後に続くテキストは、テーマの説明・概要・補足情報（参考リンク、対象読者、伝えたい主張など）。既存プランファイルのパスを渡すと修正版を作成する。

**使用例**:

- `/plan-blog oxlint と oxfmt を導入して CI を高速化した話。Before/After の数値あり。対象読者はフロントエンドエンジニア。`
- `/plan-blog ./drafts/plan-blog-oxlint.md を修正してほしい。タイトルをもっとキャッチーに。`
- `/plan-blog EMからICへのキャリアチェンジ。登壇資料のブログ化。補足: https://speakerdeck.com/yug1224/xxx`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /plan-blog` と出力する。

### 1. ルールの読み込み

以下を Read する:

- `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`（必須。適用は `blog-base`。詳細は writing-style Override）
- `@~/.config/shared/ai/rules/blog/writing-style-rule.md`（必須。Override 表が blog で優先）
- `@~/.config/shared/ai/rules/blog/structure-templates-rule.md`
- `@~/.config/shared/ai/rules/blog/topic-ideation-rule.md`
- `@~/.config/shared/ai/rules/blog/meta-and-seo-rule.md`
- `@~/.config/shared/ai/rules/blog/publish-checklist.md`
- 体験記・読み物寄りのテーマのときのみ `@~/.config/shared/ai/rules/writing/cognitive-rhythm-writing-rule.md`（任意）

### 2. 入力の解析

引数で渡された情報を整理する:

- テーマ・概要
- 補足情報（参考リンク、対象読者、伝えたい主張）
- 既存プランファイルの有無（修正モードかどうか）

既存プランファイルが指定されていれば Read ツールで読み込み、修正の方向性を確認する。

### 3. 執筆プランの下書き作成

以下の項目を含む執筆プランの**下書き**を作成する（この Step ではユーザーに提示しない）:

```markdown
# 執筆プラン: [仮タイトル]

## 基本情報

- **テーマ**: ...
- **記事タイプ**: （構成テンプレートから選定: 技術解説/体験記/チュートリアル/比較/トラブルシュート/etc）
- **対象読者**: ...
- **前提知識**: 読者に求める最低限の知識
- **想定ボリューム**: 軽め / 標準 / 重め

## 中心となる主張・差別化ポイント

（この記事ならではの価値。既存記事との違い。）

## 見出し構成

（H2 / H3 の階層構造。各節にキーメッセージを 1 行ずつ添える。）

## 候補タイトル

1. ...
2. ...
3. ...

## メタ情報案

- **emoji**: ...
- **type**: tech / idea
- **topics / tags**: ...
- **要約（80-120字）**: ...

## 参考リンク・検証すべき事項

- ...

## 公開前チェックの観点メモ

（この記事で特に注意すべきチェック項目をピックアップ。）
```

### 4. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って Step 3 の下書きプランを検証・修正する。

### 5. ユーザーへの確認

Step 4 で修正したプランを提示し、修正したい箇所がないか確認する。修正がある場合は Step 3 に戻って反復する。

---

## Guardrails

- `/plan-blog` はプランの作成のみを行い、記事本文は書かない
- テーマが曖昧な場合は Step 2 でユーザーに確認してから先に進む
- 候補タイトルは必ず 3 案以上出す
- 構成テンプレートを参考にするが、テーマに合わない場合は柔軟にアレンジしてよい
- 記事タイプの判定理由を簡潔に示す
- 文体・構成の衝突時は `writing-style-rule`（blog Override）を優先する。一文一行は要求しない
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない
