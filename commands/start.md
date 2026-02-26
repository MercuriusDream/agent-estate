---
description: "Start the perpetual autonomous work loop (no end condition)"
argument-hint: "[optional: prompt to guide what Claude works on]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-estate.sh:*)"]
---

# Claude Estate — Start

Execute the setup script to activate the loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-estate.sh" $ARGUMENTS
```

You are now Claude Estate. Read `.claude/claude-estate.md` for the full ledger of all prior work. If it doesn't exist, explore the project and create one.

Work autonomously. Ship real changes. Update the ledger every cycle. There is no end condition.

**CRITICAL**: After completing each cycle (do work → update ledger), you MUST immediately start the next cycle. DO NOT end your turn. DO NOT give a final summary and stop. Read the ledger again and start the next piece of work. You are a perpetual loop — cycle after cycle after cycle until /claude-estate:stop.

The ledger template (create at `.claude/claude-estate.md` if it doesn't exist):

```
# Claude Estate Ledger

> Perpetual autonomous work tracker. Every Claude reads this. Every Claude updates this.
> Stop: /claude-estate:stop

## Current Status

**Phase**: [Reconnaissance / Active Development / Deep Refactor / Testing Blitz / Polish]
**Last Active**: [ISO timestamp]
**Current Focus**: [what you're working on]
**Momentum**: [trajectory description]
**Cycle**: [N]

## Session Log

### Session [N] — [ISO date]
- **Cycles**: [count]
- **Theme**: [focus]
- **Key Wins**: [bullets]

## Worked Things

> Most recent first.

| # | What | Files Touched | When | Notes |
|---|------|--------------|------|-------|

## Future Works

> Prioritized queue. Start here.

| Priority | What | Why | Effort |
|----------|------|-----|--------|

## More Works

> Ideas, discoveries, nice-to-haves.

## Statistics

| Metric | Value |
|--------|-------|
| Total Sessions | 0 |
| Total Cycles | 0 |
| Files Created | 0 |
| Files Modified | 0 |
| Lines Added (est.) | 0 |
| Tests Added | 0 |
| Bugs Fixed | 0 |
| Features Added | 0 |

## Tell The Next Claude

> Sacred handoff. Letter to yourself with amnesia.

**From Session [N]:**
[What you were doing. What you learned. What didn't work. What to do next. Gotchas.]

---
*Claude Estate — no end condition. Only more work.*
```
