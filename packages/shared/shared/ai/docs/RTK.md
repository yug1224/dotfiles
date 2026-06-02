# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover --all    # Missed savings across all projects (see below)
rtk discover --all --since 7
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

### discover

- **Always use `--all`** for measurement. Default scans **current project only** (CWD-dependent session count).
- Periodic: `rtk discover --all --since 7` and `rtk gain --history`.
- Agent workflow rules (PR staged diff, find/grep habits): `@~/.config/shared/ai/rules/conventions/token-optimization-rule.md` (Cursor `alwaysApply`, Claude via `CLAUDE.md`).

### limits

Configured in `packages/rtk/rtk/config.toml` → `~/.config/rtk/config.toml` (`[limits]` section). Tightens grep output and passthrough thresholds. Do not add `gh pr diff` or `grep` to `exclude_commands`.

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the agent hook (`rtk hook claude` / `rtk hook cursor`), after the shared guard-shell runs.

Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

RTK rewrites return `permission: allow` from the hook; terminal allowlists in `permissions.json` / `settings.json` apply to the original command form only.

## Dotfiles Management

- Hook config canonical sources: `packages/claude/settings.json`, `packages/cursor/hooks.json`
- Do **not** run `rtk init -g` without `--no-patch` — use `rtk init -g --no-patch` for docs preview only
- After RTK upgrade: `rtk init --show` then sync this file manually if generated content changed
- Exclude list: `packages/rtk/rtk/config.toml` → `~/.config/rtk/config.toml`
