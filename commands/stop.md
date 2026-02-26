---
description: "Stop the active Claude Estate loop"
allowed-tools: ["Bash(test -f .claude/claude-estate.local.md:*)", "Bash(rm .claude/claude-estate.local.md)", "Read(.claude/claude-estate.local.md)"]
---

# Claude Estate — Stop

1. Check if `.claude/claude-estate.local.md` exists using Bash: `test -f .claude/claude-estate.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active Claude Estate loop found."

3. **If EXISTS**:
   - Read `.claude/claude-estate.local.md` to get the current cycle from the `cycle:` field
   - Remove the file using Bash: `rm .claude/claude-estate.local.md`
   - Report: "Claude Estate stopped (was at cycle N). The ledger at .claude/claude-estate.md is preserved — run /claude-estate:start to resume anytime."
