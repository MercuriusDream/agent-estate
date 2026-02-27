---
description: "Stop the active Agent Estate loop"
allowed-tools: ["Bash(test -f .claude/agent-estate.local.md:*)", "Bash(rm .claude/agent-estate.local.md)", "Read(.claude/agent-estate.local.md)"]
---

# Agent Estate — Stop

1. Check if `.claude/agent-estate.local.md` exists using Bash: `test -f .claude/agent-estate.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active Agent Estate loop found."

3. **If EXISTS**:
   - Read `.claude/agent-estate.local.md` to get the current cycle from the `cycle:` field
   - Remove the file using Bash: `rm .claude/agent-estate.local.md`
   - Report: "Agent Estate stopped (was at cycle N). The ledger at .claude/agent-estate.md is preserved — run /agent-estate:start to resume anytime."
