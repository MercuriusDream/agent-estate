# AGENTS.md

> Agent Estate — perpetual autonomous work loop for Claude Code.

## Overview

This is a **Claude Code plugin** that creates an infinite autonomous work loop. It uses Claude Code's plugin system (hooks, commands, state files) to intercept exit events and re-inject prompts, keeping Claude working cycle after cycle with persistent memory via a ledger file.

**Not a library. Not an API.** It's a plugin that modifies Claude Code's runtime behavior.

## Project Structure

```
agent-estate/
├── .claude-plugin/plugin.json   # Plugin manifest (name, version, author)
├── commands/
│   ├── start.md                 # /agent-estate:start — slash command definition
│   ├── stop.md                  # /agent-estate:stop — removes state file
│   └── status.md                # /agent-estate:status — shows cycle/stats
├── hooks/
│   ├── hooks.json               # Registers stop-hook.sh on the "Stop" event
│   └── stop-hook.sh             # Core engine: blocks exit, increments cycle
├── scripts/
│   └── setup-estate.sh          # Creates .claude/agent-estate.local.md state file
├── SKILL.md                     # Claude Code skill definition
├── LICENSE                      # AGPL-3.0
└── README.md
```

## Claude Code Plugin Conventions

This project follows Claude Code's plugin architecture. If you're unfamiliar:

### Plugin Manifest (`.claude-plugin/plugin.json`)

Declares the plugin identity. Must contain `name`, `description`, `version`. Located at `.claude-plugin/plugin.json` — this is what Claude Code scans to discover plugins.

### Commands (`commands/*.md`)

Slash commands users invoke inside Claude Code. Each `.md` file:

- Has YAML frontmatter with `description`, optional `argument-hint`, and `allowed-tools`
- Body contains instructions Claude follows when the command is invoked
- Filename becomes the command suffix: `start.md` → `/agent-estate:start`

### Hooks (`hooks/hooks.json` + shell scripts)

Event-driven scripts. `hooks.json` maps Claude Code lifecycle events to shell commands:

- **Event**: `"Stop"` — fires when Claude tries to end its turn
- **Action**: Runs `stop-hook.sh` which reads stdin (hook context), detects rate limits, increments cycle counter, and outputs `{"decision": "block", "reason": "..."}` JSON to prevent exit
- `${CLAUDE_PLUGIN_ROOT}` is a special variable resolved by Claude Code to the plugin's root directory

### State Files (runtime, not in repo)

Created at runtime in the user's project directory:

- `.claude/agent-estate.local.md` — ephemeral, signals active loop. Has YAML frontmatter (`active`, `cycle`, `started_at`, `user_prompt`) followed by the full prompt. Removing this file is the only way to stop the loop.
- `.claude/agent-estate.md` — persistent ledger. Tracks all work, sessions, statistics, and the "Tell The Next Claude" handoff message across contexts.

## Dependencies

- **`jq`** — required by `stop-hook.sh` to produce JSON output for the hook response
- **`bash`** — all scripts use `#!/bin/bash` with `set -euo pipefail`
- Standard POSIX tools: `sed`, `awk`, `grep`, `date`, `cat`

## Installation (for development)

```bash
# symlink into Claude Code's local plugin directory
mkdir -p ~/.claude/plugins/local
ln -s "$(pwd)" ~/.claude/plugins/local/agent-estate

# make scripts executable
chmod +x scripts/setup-estate.sh
chmod +x hooks/stop-hook.sh
```

## Testing Changes

There are no automated tests. To verify changes:

1. Install the plugin locally (symlink above)
2. Open Claude Code in any project
3. Run `/agent-estate:start test prompt` — verify state file is created
4. Let it run 2-3 cycles — verify cycle counter increments
5. Run `/agent-estate:status` — verify it reads state + ledger correctly
6. Run `/agent-estate:stop` — verify state file is removed and Claude exits

### Testing the stop hook in isolation

```bash
echo "normal exit" | bash hooks/stop-hook.sh    # should block if state file exists
echo "429 rate limit" | bash hooks/stop-hook.sh  # should wait 60s then block
```

## Code Style

- Shell scripts: `bash` with `set -euo pipefail`, no external dependencies beyond `jq`
- Command files: Markdown with YAML frontmatter, imperative instructions for Claude
- No build step, no transpilation, no package manager
- Keep it minimal — the entire plugin is ~15 files and ~400 lines total

## Key Design Decisions

- **State file as control mechanism**: The loop's on/off state is a single file's existence. Simple, atomic, no race conditions.
- **Prompt preservation**: The user's original prompt from `/agent-estate:start <prompt>` is embedded in the state file and re-injected every cycle, so Claude never forgets the guiding directive.
- **Rate limit resilience**: The hook detects 429/529 errors from stdin context and sleeps before retrying, rather than crashing or losing state.
- **Ledger as cross-context memory**: Since Claude's context resets between sessions, the ledger file (`.claude/agent-estate.md`) acts as persistent memory with structured sections for handoff.
