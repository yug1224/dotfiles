import { defineConfig, type OxfmtConfig } from 'oxfmt';

import { presetBase } from './packages/oxfmt/preset.base.ts';

export default defineConfig({
  ...presetBase,
  printWidth: 200,
  // settings.json は claude plugin install などが自分の形式で書き直すので、その形式のまま管理する
  ignorePatterns: ['pnpm-lock.yaml', '**/node_modules/**', 'packages/claude/settings.json'],
  overrides: [
    {
      files: ['*.md', '*.mdx'],
      options: {
        printWidth: 100,
        proseWrap: 'preserve',
      },
    },
  ],
} as OxfmtConfig);
