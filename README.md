# Agent-Estate

<img width="2200" height="1440" alt="AGENT_ESTATE" src="https://github.com/user-attachments/assets/fb464d2e-a064-41ac-82c6-763ef9e8b9d0" />

> *IT'S THE FREE REAL AGENT ESTATE*

Autonomous work loop for Claude Code. No end condition. Persistent memory. Zero config.

Used it to build a [from-scratch C++ web browser](https://github.com/MercuriusDream/Vibrowser) — 287 autonomous cycles, 100+ hours, 3,374 tests, zero failures, <10 manual steerings.

## Why Agent Estate?

- **Native hooks, not a wrapper** — uses Claude Code's Stop event to intercept exits. No bash wrapper, no tmux, no external process manager
- **Zero config** — no PRD files, no task definitions, no project setup. Just `/agent-estate:start`
- **Persistent memory** — ledger tracks everything across sessions. "Tell The Next Claude" handoff for cross-context memory. Context doesn't reset between cycles
- **Auto-stop when done** — `--done` flag lets Claude stop itself when the task is complete. Or run perpetual (default)
- **Rate limit resilience** — detects 429/529 errors, waits, retries. Never crashes, never loses state
- **~400 lines total** — the entire plugin. 3 directories, 7 files. Nothing to configure, nothing to break

## Install

### Claude Code Plugin (recommended)

```bash
/plugin marketplace add MercuriusDream/agent-estate
/plugin install agent-estate@MercuriusDream
```

### npx ([skills.sh](https://skills.sh))

```bash
npx skills add MercuriusDream/agent-estate
```

### Manual

```bash
git clone https://github.com/MercuriusDream/agent-estate.git
mkdir -p ~/.claude/plugins/local
ln -s "$(pwd)/agent-estate" ~/.claude/plugins/local/agent-estate
chmod +x agent-estate/scripts/setup-estate.sh
chmod +x agent-estate/hooks/stop-hook.sh
```

Requires `jq`:

```bash
brew install jq        # macOS
sudo apt install jq    # debian/ubuntu
```

## Usage

```bash
/agent-estate:start                                       # full autonomy, perpetual
/agent-estate:start build a web server with tests         # guided prompt, perpetual
/agent-estate:start --done build a web server with tests  # auto-stops when done
/agent-estate:status                                      # check cycle, mode, stats
/agent-estate:stop                                        # manual stop
```

## How It Works

```
start → read ledger → pick task → do the work → update ledger → try to exit
          ↑         stop hook intercepts → blocks exit → re-injects prompt ↲
```

### The Hook

`hooks/stop-hook.sh` runs on every Claude Stop event:

1. No state file? → exit normally
2. `done: true` in frontmatter? → remove state file, exit (auto-stop)
3. Rate limited (429)? → wait 60s, retry
4. API overloaded (529)? → wait 30s, retry
5. Otherwise → increment cycle, re-inject prompt, block exit

### The Ledger

`.claude/agent-estate.md` — the persistent brain. Every Claude reads it, every Claude updates it.

| Section | Purpose |
|---------|---------|
| **Current Status** | Phase, focus, momentum, cycle count |
| **Session Log** | What happened each session |
| **Worked Things** | Table of everything done with files touched |
| **Future Works** | Prioritized task queue |
| **Statistics** | Cycles, tests, bugs fixed, features shipped |
| **Tell The Next Claude** | Sacred handoff message — letter to yourself with amnesia |

### Work Priority

Built into the protocol, in order:

1. **Broken** — failing tests, bugs, errors
2. **Incomplete** — half-finished features, TODOs, FIXMEs
3. **Missing** — no tests, no error handling
4. **Ugly** — code smells, dead code
5. **Slow** — performance issues
6. **New** — features that improve the project
7. **Creative** — surprise the user

## Battle-Tested

Built [Vibrowser](https://github.com/MercuriusDream/Vibrowser) — a from-scratch C++ browser engine:

| | |
|---|---|
| Autonomous cycles | 287 across 123 sessions |
| Runtime | 100+ hours, <10 manual steerings |
| Tests | 3,374 — zero failures |
| Features | 2,440+ shipped, 124 bugs fixed |
| Lines | 168,360+ |
| Engines | CSS (370+ properties), JS (QuickJS), CORS/CSP/TLS |
| Result | Renders real websites off the live internet |
| Fun fact | [claude.ai 403'd the browser Claude built](https://x.com/Mercuriusdream/status/2026732290630672682) |

## Files

```
agent-estate/
├── .claude-plugin/plugin.json   # plugin manifest
├── commands/
│   ├── start.md                 # /agent-estate:start
│   ├── stop.md                  # /agent-estate:stop
│   └── status.md                # /agent-estate:status
├── hooks/
│   ├── hooks.json               # registers stop hook
│   └── stop-hook.sh             # core engine
├── scripts/
│   └── setup-estate.sh          # creates state file
├── SKILL.md                     # skill definition
├── AGENTS.md                    # agent instructions
└── README.md
```

## Tips

- **Long sessions** — Claude Max recommended for hours-long autonomous runs
- **Guiding prompts** — focus without being restrictive
- **Ledger size** — if it gets large (300KB+), Claude will auto-summarize older cycles
- **Resuming** — ledger persists after stop. Start again and Claude picks up from the handoff
- **Full autonomy** — no prompt = Claude explores and decides what's most valuable

## License

AGPL-3.0

## Author

MercuriusDream (Wooseok Sung)

- [@Mercuriusdream](https://x.com/Mercuriusdream)
- [mercuriusdream.com](https://mercuriusdream.com)
