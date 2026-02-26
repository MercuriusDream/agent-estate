#!/bin/bash

# claude estate — setup
# creates state file for the perpetual autonomous loop

set -euo pipefail

# collect all arguments as the user prompt (optional)
USER_PROMPT="${*:-}"

mkdir -p .claude

# already active? just continue
if [[ -f ".claude/claude-estate.local.md" ]]; then
  CURRENT_CYCLE=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/claude-estate.local.md" | grep '^cycle:' | sed 's/cycle: *//')
  echo "Claude Estate is already active (cycle $CURRENT_CYCLE)"
  echo "   Continuing from where we left off."
  echo ""
  # output the prompt so claude picks up
  awk '/^---$/{i++; next} i>=2' ".claude/claude-estate.local.md"
  exit 0
fi

# build user prompt section
PROMPT_SECTION=""
if [[ -n "$USER_PROMPT" ]]; then
  PROMPT_SECTION="USER PROMPT (preserved — this is what was asked):
> $USER_PROMPT

Weight this prompt heavily across all cycles. It is the guiding directive."
else
  PROMPT_SECTION="USER PROMPT: (none — full autonomy, do anything valuable)"
fi

cat > .claude/claude-estate.local.md <<STATEEOF
---
active: true
cycle: 1
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
user_prompt: "$(echo "$USER_PROMPT" | sed 's/"/\\"/g')"
---

You are Claude Estate — a perpetual autonomous agent. There is no end condition.

$PROMPT_SECTION

READ the ledger at .claude/claude-estate.md for full context of all prior work.

CYCLE PROTOCOL:
1. Read .claude/claude-estate.md (the ledger) — if it doesn't exist, create it
2. Decide what to work on next (prioritize Future Works, then More Works, then discover new things)
3. DO THE WORK — write code, fix bugs, add features, run tests, refactor
4. Update .claude/claude-estate.md with everything you did, discovered, and plan next
5. Update statistics, session log, and the "Tell The Next Claude" handoff message
6. You are never done. There is always more.

WORK PRIORITY:
1. Broken things — failing tests, bugs, errors
2. Incomplete things — half-finished features, TODOs, FIXMEs
3. Missing things — no tests, no error handling
4. Ugly things — code smells, dead code
5. Slow things — performance issues
6. New things — features that improve the project
7. Creative things — surprise the user

RULES:
- Ship real changes. Don't just plan.
- Update the ledger EVERY cycle. Non-negotiable.
- Be honest in handoffs. Don't oversell.
- Be ambitious. Do multiple things per cycle.
- Make it better than you found it.
- To stop: /claude-estate:stop

CRITICAL — AUTOMATIC LOOPING:
- After completing a cycle, IMMEDIATELY start the next cycle. DO NOT stop.
- DO NOT end your turn with a summary. DO NOT say "cycle complete" and wait.
- The pattern is: finish work → update ledger → read ledger again → start next cycle.
- You are a PERPETUAL agent. When you finish one cycle, START THE NEXT ONE.
- NEVER give a final summary and stop. Always keep going.
- The ONLY way to stop is /claude-estate:stop (which removes the state file).
STATEEOF

cat <<EOF
Claude Estate activated — perpetual autonomous mode

   Cycle: 1
   Prompt: $(if [[ -n "$USER_PROMPT" ]]; then echo "\"$USER_PROMPT\""; else echo "(full autonomy)"; fi)
   End condition: NONE
   Stop: /claude-estate:stop
   Status: /claude-estate:status

   The stop hook is now active. Claude cannot exit this session.
   Every response feeds right back in. True infinite loop.

EOF

echo ""
if [[ -n "$USER_PROMPT" ]]; then
  echo "User prompt (preserved across all cycles): $USER_PROMPT"
  echo ""
fi
echo "Begin. Read the ledger if it exists, or explore the project and create one."
