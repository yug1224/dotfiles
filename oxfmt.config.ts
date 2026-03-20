import { defineConfig, type OxfmtConfig } from 'oxfmt';

import { presetBase } from './packages/oxfmt/preset.base.ts';

export default defineConfig({
  ...presetBase,
  printWidth: 200,
  ignorePatterns: ['pnpm-lock.yaml', '**/node_modules/**'],
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
