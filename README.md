# Agent-Estate

<img width="2200" height="1440" alt="AGENT_ESTATE" src="https://github.com/user-attachments/assets/fb464d2e-a064-41ac-82c6-763ef9e8b9d0" />

> *IT'S THE FREE REAL AGENT ESTATE*

Perpetual autonomous work loop for Claude Code agent with no end condition, no memory regression, no context overfill.

## About

Agent Estate turns Claude Code into a perpetual autonomous agent — cycle after cycle — maintaining a persistent ledger across all sessions. It never stops until you say so.

Built this to run 100+ hour autonomous coding sessions with <10 manual steerings. Used it to build a [from-scratch C++ web browser](https://github.com/MercuriusDream/Vibrowser) in 287 autonomous cycles — 3,374 tests, zero failures.

- Stop hook intercepts every exit attempt and re-injects the prompt
- Rate limits? Waits and retries. API overloaded? Backs off and comes back
- Persistent ledger tracks everything across sessions
- "Tell The Next Claude" handoff for cross-context memory

## Install

```bash
git clone https://github.com/MercuriusDream/agent-estate.git

# symlink into local plugins
mkdir -p ~/.claude/plugins/local
ln -s "$(pwd)/agent-estate" ~/.claude/plugins/local/agent-estate

# make scripts executable
chmod +x agent-estate/scripts/setup-estate.sh
chmod +x agent-estate/hooks/stop-hook.sh
```

Requires `jq`:

```bash
brew install jq        # macOS
sudo apt install jq    # debian/ubuntu
```

## Usage

```
/agent-estate:start                                # full autonomy
/agent-estate:start build a web server with tests  # guided prompt
/agent-estate:status                               # check cycle, stats, handoff
/agent-estate:stop                                 # only way to stop
```

## How It Works

### Loop

```
read ledger → pick next task → do the work → update ledger → try to exit
  → stop hook intercepts → blocks exit → re-injects prompt → loop continues
```

### Ledger

`.claude/agent-estate.md` — the persistent brain. Every Claude reads it, every Claude updates it.

- **Current Status** — phase, focus, momentum, cycle count
- **Session Log** — what happened each session
- **Worked Things** — table of everything done with files touched
- **Future Works** — prioritized task queue
- **Statistics** — cycles, tests, bugs fixed, features shipped
- **Tell The Next Claude** — sacred handoff message

### Stop Hook

`hooks/stop-hook.sh` — the core engine.

1. Checks if `.claude/agent-estate.local.md` exists (loop active?)
2. If active: increments cycle counter, re-injects prompt, blocks exit
3. If rate limited: waits 60s, retries
4. If API overloaded: waits 30s, retries
5. If state file removed (`/agent-estate:stop`): allows normal exit

### Work Priority

Built into the protocol:

1. Broken things — failing tests, bugs, errors
2. Incomplete things — half-finished features, TODOs
3. Missing things — no tests, no error handling
4. Ugly things — code smells, dead code
5. Slow things — performance issues
6. New things — features that improve the project
7. Creative things — surprise the user

## Files

```
agent-estate/
├── .claude-plugin/plugin.json
├── commands/
│   ├── start.md
│   ├── stop.md
│   └── status.md
├── hooks/
│   ├── hooks.json
│   └── stop-hook.sh
├── scripts/
│   └── setup-estate.sh
├── LICENSE
└── README.md
```

## Battle-Tested

Used to build [Vibrowser](https://github.com/MercuriusDream/Vibrowser) — a from-scratch C++ browser engine:

- 287 autonomous cycles across 123 sessions
- 100+ hours autonomous runtime, <10 manual steerings
- 3,374 tests, zero failures
- 2,440+ features, 124 bugs fixed, 168,360+ lines
- CSS engine (370+ properties), JS engine (QuickJS), CORS/CSP/TLS
- Renders real websites off the live internet
- [claude.ai 403'd the browser Claude built](https://x.com/Mercuriusdream/status/2026732290630672682)

## Tips

- **Long sessions** — Claude Max recommended for hours-long autonomous runs
- **Guiding prompts** — focus without being restrictive
- **Ledger size** — if it gets large (300KB+), Claude will summarize older cycles. you can also manually trim
- **Resuming** — ledger persists after stop. start again and Claude picks up from the handoff
- **Full autonomy** — no prompt = Claude explores and decides what's most valuable

## License

AGPL-3.0

## Author

MercuriusDream (Wooseok Sung)

- [@Mercuriusdream](https://x.com/Mercuriusdream)
- [mercuriusdream.com](https://mercuriusdream.com)
