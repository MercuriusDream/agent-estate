# Claude Estate

**Perpetual autonomous work loop for Claude Code.** No end condition. Claude works autonomously — cycle after cycle — maintaining a persistent ledger across all sessions. It never stops until you say so.

Built this to run 100+ hour autonomous coding sessions with <10 manual interventions. Used it to build a [from-scratch C++ web browser](https://github.com/MercuriusDream/Vibrowser) in 287 autonomous cycles — 3,374 tests, zero failures.

## What It Does

Claude Estate turns Claude Code into a perpetual autonomous agent:

1. **Start** — give it an optional prompt (or let it run free)
2. **Loop** — Claude works, updates the ledger, starts the next cycle automatically
3. **Ledger** — persistent markdown file tracks everything across sessions: what was done, what's next, statistics, and a "Tell The Next Claude" handoff message
4. **Stop** — only when you explicitly say `/claude-estate:stop`

The stop hook intercepts every exit attempt and re-injects the prompt. Claude literally cannot stop working. Rate limits? It waits and retries. API overloaded? It backs off and comes back. The loop is infinite.

## Install

```bash
# Clone the repo
git clone https://github.com/MercuriusDream/claude-estate.git

# Add to your Claude Code plugins
# Option 1: Symlink into local plugins
mkdir -p ~/.claude/plugins/local
ln -s "$(pwd)/claude-estate" ~/.claude/plugins/local/claude-estate

# Option 2: Or just copy it
cp -r claude-estate ~/.claude/plugins/local/claude-estate
```

Make sure the scripts are executable:
```bash
chmod +x claude-estate/scripts/setup-estate.sh
chmod +x claude-estate/hooks/stop-hook.sh
```

Requires `jq` for JSON output in the stop hook:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq
```

## Usage

### Start the loop

```
/claude-estate:start
```

With a guiding prompt:

```
/claude-estate:start build a web server with authentication and tests
```

Or full autonomy (Claude decides what to work on):

```
/claude-estate:start
```

### Check status

```
/claude-estate:status
```

Shows current cycle, statistics, and the "Tell The Next Claude" handoff.

### Stop the loop

```
/claude-estate:stop
```

This is the **only** way to stop it. The ledger at `.claude/claude-estate.md` is preserved — restart anytime to pick up where you left off.

## How It Works

### The Loop

```
┌─────────────────────────────────────────┐
│  Claude reads ledger                     │
│  ↓                                       │
│  Picks next task (Future Works queue)    │
│  ↓                                       │
│  Does the work (code, tests, fixes)     │
│  ↓                                       │
│  Updates ledger (log, stats, handoff)   │
│  ↓                                       │
│  Tries to exit                           │
│  ↓                                       │
│  Stop hook intercepts → blocks exit     │
│  ↓                                       │
│  Re-injects prompt with next cycle #    │
│  ↓                                       │
│  Loop continues                          │
└─────────────────────────────────────────┘
```

### The Ledger

`.claude/claude-estate.md` is the persistent brain. Every Claude reads it, every Claude updates it. It contains:

- **Current Status** — phase, focus, momentum, cycle count
- **Session Log** — history of what happened each session
- **Worked Things** — table of everything done with files touched
- **Future Works** — prioritized task queue (Claude picks from here)
- **Statistics** — total cycles, tests added, bugs fixed, features shipped
- **Tell The Next Claude** — sacred handoff message for the next cycle

### The Stop Hook

`hooks/stop-hook.sh` is the core engine. When Claude tries to exit:

1. Checks if `.claude/claude-estate.local.md` exists (loop active?)
2. If active: increments cycle counter, re-injects prompt, blocks exit
3. If rate limited: waits 60s, then retries
4. If API overloaded: waits 30s, then retries
5. If state file removed (`/claude-estate:stop`): allows normal exit

### Work Priority

Built into the protocol — Claude follows this priority order:

1. **Broken things** — failing tests, bugs, errors
2. **Incomplete things** — half-finished features, TODOs
3. **Missing things** — no tests, no error handling
4. **Ugly things** — code smells, dead code
5. **Slow things** — performance issues
6. **New things** — features that improve the project
7. **Creative things** — surprise the user

## Files

```
claude-estate/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── start.md             # /claude-estate:start command
│   ├── stop.md              # /claude-estate:stop command
│   └── status.md            # /claude-estate:status command
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── stop-hook.sh         # The perpetual loop engine
├── scripts/
│   └── setup-estate.sh      # Loop initialization
├── LICENSE
└── README.md
```

## Battle-Tested

This isn't theoretical. Claude Estate was used to build a [from-scratch C++ browser engine](https://github.com/MercuriusDream/Vibrowser):

- **287 autonomous cycles** across 123 sessions
- **100+ hours** of autonomous runtime
- **<10 manual interventions** (steerings)
- **3,374 tests**, zero failures
- **2,440+ features**, 124 bugs fixed
- **168,360+ lines** of code
- Full CSS engine (370+ properties), JavaScript engine (QuickJS), CORS/CSP enforcement, TLS verification
- Renders real websites (Google, portfolio sites)
- [claude.ai 403'd us though](https://x.com/Mercuriusdream/status/2026732290630672682)

## Tips

- **Long sessions**: Claude Estate is designed for hours-long autonomous runs. Make sure you're on a plan that supports it (Claude Max recommended).
- **Guiding prompts**: A good prompt focuses Claude without being too restrictive. "Build a REST API with auth and tests" > "Write exactly this code in this file."
- **The ledger is everything**: If the ledger gets too large (300KB+), Claude will naturally summarize older cycles. You can also manually trim old session logs.
- **Resuming**: The ledger persists after `/claude-estate:stop`. Just `/claude-estate:start` again and Claude picks up from the "Tell The Next Claude" handoff.
- **Full autonomy mode**: Starting without a prompt lets Claude explore the project and decide what's most valuable. Useful for maintenance, refactoring, and test coverage passes.

## License

MIT

## Author

**MercuriusDream** (Wooseok Sung) — 19yo CS sophomore who spent 80% of a Claude Max weekly limit in 3 days building a browser from scratch.

- Twitter: [@Mercuriusdream](https://x.com/Mercuriusdream)
- GitHub: [MercuriusDream](https://github.com/MercuriusDream)
- Portfolio: [mercuriusdream.com](https://mercuriusdream.com)
