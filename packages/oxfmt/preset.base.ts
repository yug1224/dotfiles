import type { OxfmtConfig } from 'oxfmt';

/** 他リポジトリにも持ち出せる汎用プリセット */
export const presetBase = {
  semi: true,
  singleQuote: true,
  trailingComma: 'all' as const,
  tabWidth: 2,
  useTabs: false,
  printWidth: 100,
  endOfLine: 'lf' as const,
  bracketSpacing: true,
  sortImports: {
    groups: ['builtin', 'external', ['internal', 'subpath'], ['parent', 'sibling', 'index'], 'style', 'unknown'],
    newlinesBetween: true,
    order: 'asc' as const,
    ignoreCase: true,
  },
  sortPackageJson: {
    sortScripts: false,
  },
} satisfies Partial<OxfmtConfig>;
