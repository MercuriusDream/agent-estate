---
description: "Show Agent Estate loop status and ledger summary"
allowed-tools: ["Read(.claude/agent-estate.local.md)", "Read(.claude/agent-estate.md)"]
---

# Agent Estate — Status

1. Check if the loop is active by reading `.claude/agent-estate.local.md`. If it doesn't exist, say "Agent Estate is not currently active."

2. If active, show:
   - Current cycle number
   - Started at timestamp
   - The preserved prompt from the state file

3. Read `.claude/agent-estate.md` (the ledger) and show:
   - Current Status section
   - Statistics table
   - The most recent "Tell The Next Claude" entry
   - Top 3 items from Future Works
