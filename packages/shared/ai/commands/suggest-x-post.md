テック記事の URL・本文・ローカル Markdown から、X（旧 Twitter）投稿用の**二文要約**を 1 案だけ提案する。

# テック記事URLからX投稿用二文要約を提案

**参照ルール**:

- `@~/.config/shared/ai/rules/writing/x-post-rule.md`（必須）
- 同ディレクトリの `x-post-rule.local.md`（Glob → 存在時のみ Read）

**Input**: `/suggest-x-post` の後に続く引数。以下のいずれか 1 つ以上が必須。

- 記事 URL
- 記事本文の直貼り
- ローカル `.md` ファイルパス

**オプション引数**:

| 引数       | 用途                                                                     |
| ---------- | ------------------------------------------------------------------------ |
| `with-url` | 最終出力の fenced ブロック直後に `source: <url>` を 1 行追加（既定オフ） |

**使用例**:

- `/suggest-x-post https://zenn.dev/user/articles/xxx`
- `/suggest-x-post ./articles/my-post.md`
- `/suggest-x-post with-url https://tech-blog.example.com/posts/123`
- `/suggest-x-post 認証を JWT+Refresh に変更した背景と、移行でハマった点をまとめた記事です。…（本文直貼り）`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /suggest-x-post` と出力する（ルール側の `✅️` はユーザー向けに出さない）。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/writing/x-post-rule.md` を Read する（必須）
2. 同ディレクトリの `x-post-rule.local.md` を Glob する。存在する場合のみ Read。矛盾時は `.local.md` を優先

### 2. 入力の分類

`/suggest-x-post` 後続の引数を分類する。

- `with-url` → **オプション**（他の入力と併用可）
- `http://` または `https://` で始まる文字列 → **URL**
- 既存ファイルとして解決できる `.md` パス → **パス**
- 上記以外の非空テキスト → **本文**

入力が空、または URL / 本文 / パスのいずれも特定できない場合は、記事 URL・本文・`.md` パスのいずれかを求めて**停止**する。

### 3. 材料の取得

- **パス** → Read ツールでファイル内容を取得する
- **本文** → 引数テキストをそのまま材料とする
- **URL** → Task ツール（`subagent_type`: `"general-worker"`, `model`: `"composer-2.5"`, `readonly`: `true`）で記事を取得・要約する。親へ返すのは次の構造化カード**のみ**（生 HTML・全文転載は禁止）:

  | フィールド      | 内容                             |
  | --------------- | -------------------------------- |
  | `title`         | 記事タイトル                     |
  | `one_liner`     | 記事の一行要約                   |
  | `key_points`    | 要点 3〜5 件                     |
  | `audience`      | 想定読者                         |
  | `notable_claim` | 記事の核となる主張・示唆（1 件） |
  | `source_url`    | 取得元 URL                       |
  | `lang`          | 記事の主要言語（`ja` / `en` 等） |

  取得に失敗した場合は **1 回だけ**再試行する。再試行後も失敗した場合は、ユーザーに要点の貼り付けを求めて**停止**する（推測で投稿文を作らない）。

### 4. 下書き作成（非提示）

`x-post-rule` に従い、取得した材料から X 投稿用の**二文**を下書きする（この Step ではユーザーに提示しない）。

### 5. セルフレビュー（非提示）

`x-post-rule` のチェックリストに従い下書きを検証・修正する（この Step ではユーザーに提示しない）。

### 6. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 7. 最終出力

Step 0 のあとに、下記フォーマットでユーザーに提示する。

---

## 出力フォーマット

応答は Step 0 の `✅️` のあと、次を出す。

- fenced `text` ブロック 1 つ（中身は二文。1 行 1 文）

例（`with-url` なし）:

````text
```text
1文目
2文目
```
````

- 外側は通常テキスト。二文は **fenced `text` ブロック 1 つ**にのみ入れる
- `with-url` 指定時かつ **URL 入力**がある場合のみ、fenced ブロックの直後に `source: <url>` を 1 行追加する（本文直貼り・パス入力時は出さない）

---

## Guardrails

- 前置き・解説・ハッシュタグ・松竹梅の複数案は出さない（**二文 1 案のみ**）
- 記事が取得できない・要点が不足している場合は捏造せず、入力を求めて停止する
- URL 取得時は Task の返却を構造化カードに限定し、生 HTML や全文をコンテキストに載せない
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない
