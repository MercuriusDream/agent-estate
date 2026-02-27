---
name: claude-estate
description: Perpetual autonomous work loop for Claude Code — no end condition, no memory regression, no context overfill. Maintains a persistent ledger across all sessions.
---

# Claude Estate

Perpetual autonomous work loop plugin for Claude Code. Turns Claude into an agent that works cycle after cycle, maintaining a persistent ledger across all sessions, never stopping until explicitly told to.

## Overview

Claude Estate creates an infinite work loop by intercepting Claude's stop events via a shell hook. Each time Claude tries to exit, the hook blocks the exit, increments the cycle counter, and re-injects the prompt — creating a true perpetual agent.

## Architecture

```
claude-estate/
├── .claude-plugin/plugin.json   # Plugin manifest (name, version, author)
├── commands/
│   ├── start.md                 # /claude-estate:start — activates the loop
│   ├── stop.md                  # /claude-estate:stop — removes state file to allow exit
│   └── status.md                # /claude-estate:status — shows cycle count, ledger summary
├── hooks/
│   ├── hooks.json               # Registers stop-hook.sh on the "Stop" event
│   └── stop-hook.sh             # Core engine: blocks exit, increments cycle, re-injects prompt
├── scripts/
│   └── setup-estate.sh          # Creates .claude/claude-estate.local.md state file
├── LICENSE
└── README.md
```

## Key Components

### Stop Hook (`hooks/stop-hook.sh`)

The core engine. Runs on every Claude "Stop" event:

1. Checks if `.claude/claude-estate.local.md` exists (is the loop active?)
2. If **not active**: exits normally (exit 0)
3. If **active**:
   - Detects rate limits (429) → waits 60s
   - Detects API overload (529) → waits 30s
   - Increments cycle counter in the state file
   - Outputs a JSON `{"decision": "block", "reason": "..."}` to prevent exit
   - Re-injects the prompt for the next cycle

### Setup Script (`scripts/setup-estate.sh`)

Creates the state file at `.claude/claude-estate.local.md` with YAML frontmatter (`active`, `cycle`, `started_at`, `user_prompt`) and the full cycle protocol instructions. If already active, outputs current state and continues.

### Ledger (`.claude/claude-estate.md`)

The persistent brain — every Claude session reads and updates it. Contains:

- **Current Status** — phase, focus, momentum, cycle count
- **Session Log** — what happened each session
- **Worked Things** — table of everything done with files touched
- **Future Works** — prioritized task queue
- **More Works** — ideas, discoveries, nice-to-haves
- **Statistics** — cycles, tests, bugs fixed, features shipped
- **Tell The Next Claude** — sacred handoff message for cross-context memory

### State File (`.claude/claude-estate.local.md`)

Ephemeral file that signals an active loop. Contains the cycle counter and preserved user prompt. Removing this file (via `/claude-estate:stop`) is the **only** way to end the loop.

## Commands

| Command | Description |
|---------|-------------|
| `/claude-estate:start` | Activate the perpetual loop (optionally with a guiding prompt) |
| `/claude-estate:start <prompt>` | Start with a specific task focus preserved across all cycles |
| `/claude-estate:status` | Show current cycle, stats, and the latest handoff message |
| `/claude-estate:stop` | Remove the state file to allow Claude to exit |

## Work Priority Protocol

Built into the agent instructions, in order:

1. **Broken things** — failing tests, bugs, errors
2. **Incomplete things** — half-finished features, TODOs, FIXMEs
3. **Missing things** — no tests, no error handling
4. **Ugly things** — code smells, dead code
5. **Slow things** — performance issues
6. **New things** — features that improve the project
7. **Creative things** — surprise the user

## Cycle Protocol

Each cycle follows this pattern:

1. Read `.claude/claude-estate.md` (the ledger)
2. Decide what to work on next
3. **Do the work** — write code, fix bugs, add features, run tests
4. Update the ledger with what was done, discovered, and planned
5. Update statistics, session log, and "Tell The Next Claude" handoff
6. Immediately start the next cycle (never stop)

## Prerequisites

- `jq` — required for JSON output in the stop hook
- Claude Code with plugin support

## Installation

```bash
git clone https://github.com/MercuriusDream/claude-estate.git
mkdir -p ~/.claude/plugins/local
ln -s "$(pwd)/claude-estate" ~/.claude/plugins/local/claude-estate
chmod +x claude-estate/scripts/setup-estate.sh
chmod +x claude-estate/hooks/stop-hook.sh
```

## Tips

- **Long sessions**: Claude Max recommended for extended autonomous runs
- **Guiding prompts**: Use `/claude-estate:start <prompt>` for focused work without being restrictive
- **Ledger size**: If it exceeds ~300KB, Claude will auto-summarize older cycles
- **Resuming**: The ledger persists after stop. Start again and Claude picks up from the handoff
- **Full autonomy**: No prompt = Claude explores and decides what's most valuable
