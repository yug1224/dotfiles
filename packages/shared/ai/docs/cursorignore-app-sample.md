# アプリリポジトリ用 `.cursorignore` サンプル

プロジェクトルートに `.cursorignore` を置き、必要行をコピーする。dotfiles の展開（mise-dotfiles）では各アプリへは自動展開されない。

```gitignore
node_modules/
dist/
build/
.next/
coverage/
*.lock
pnpm-lock.yaml
package-lock.json
**/*.generated.*
```
