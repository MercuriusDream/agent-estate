#!/bin/bash

# agent estate — setup
# creates state file for the autonomous loop

set -euo pipefail

# parse --done flag
DONE_MODE=false
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--done" ]]; then
    DONE_MODE=true
  else
    ARGS+=("$arg")
  fi
done

# collect remaining arguments as the user prompt (optional)
USER_PROMPT="${ARGS[*]:-}"

mkdir -p .claude

# already active? just continue
if [[ -f ".claude/agent-estate.local.md" ]]; then
  CURRENT_CYCLE=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/agent-estate.local.md" | grep '^cycle:' | sed 's/cycle: *//')
  echo "Agent Estate is already active (cycle $CURRENT_CYCLE)"
  echo "   Continuing from where we left off."
  echo ""
  # output the prompt so claude picks up
  awk '/^---$/{i++; next} i>=2' ".claude/agent-estate.local.md"
  exit 0
fi

# determine mode
if [[ "$DONE_MODE" == "true" ]]; then
  MODE="done"
else
  MODE="perpetual"
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

# build done-mode instructions
DONE_INSTRUCTIONS=""
if [[ "$MODE" == "done" ]]; then
  DONE_INSTRUCTIONS="
DONE MODE ACTIVE:
- You are in done mode. When the task described in the user prompt is COMPLETE, you must signal completion.
- To signal completion: use sed to change 'done: false' to 'done: true' in .claude/agent-estate.local.md
- Only mark done when the task is genuinely finished — tests pass, code works, everything is verified.
- After marking done, give a final summary of what was accomplished.
- If there is no user prompt, mark done when you have made meaningful improvements and there is nothing urgent left.
- The loop will automatically stop on the next cycle after you mark done."
else
  DONE_INSTRUCTIONS="
PERPETUAL MODE:
- There is no end condition. You are never done. There is always more.
- The ONLY way to stop is /agent-estate:stop (which removes the state file)."
fi

cat > .claude/agent-estate.local.md <<STATEEOF
---
active: true
cycle: 1
mode: "$MODE"
done: false
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
user_prompt: "$(echo "$USER_PROMPT" | sed 's/"/\\"/g')"
---

You are Agent Estate — an autonomous agent.

$PROMPT_SECTION

READ the ledger at .claude/agent-estate.md for full context of all prior work.

CYCLE PROTOCOL:
1. Read .claude/agent-estate.md (the ledger) — if it doesn't exist, create it
2. Decide what to work on next (prioritize Future Works, then More Works, then discover new things)
3. DO THE WORK — write code, fix bugs, add features, run tests, refactor
4. Update .claude/agent-estate.md with everything you did, discovered, and plan next
5. Update statistics, session log, and the "Tell The Next Claude" handoff message
6. Start the next cycle immediately.
$DONE_INSTRUCTIONS

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
- To stop manually: /agent-estate:stop

CRITICAL — AUTOMATIC LOOPING:
- After completing a cycle, IMMEDIATELY start the next cycle. DO NOT stop.
- DO NOT end your turn with a summary. DO NOT say "cycle complete" and wait.
- The pattern is: finish work → update ledger → read ledger again → start next cycle.
- NEVER give a final summary and stop (unless you are in done mode and have marked done: true).
- Always keep going until stopped.
STATEEOF

# determine end condition display
if [[ "$MODE" == "done" ]]; then
  END_DISPLAY="when task is complete"
else
  END_DISPLAY="NONE"
fi

cat <<EOF
Agent Estate activated — autonomous mode

   Cycle: 1
   Mode: $MODE
   Prompt: $(if [[ -n "$USER_PROMPT" ]]; then echo "\"$USER_PROMPT\""; else echo "(full autonomy)"; fi)
   End condition: $END_DISPLAY
   Stop: /agent-estate:stop
   Status: /agent-estate:status

   The stop hook is now active. Claude cannot exit this session.
   Every response feeds right back in.

EOF

echo ""
if [[ -n "$USER_PROMPT" ]]; then
  echo "User prompt (preserved across all cycles): $USER_PROMPT"
  echo ""
fi
echo "Begin. Read the ledger if it exists, or explore the project and create one."

