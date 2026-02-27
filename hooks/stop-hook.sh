#!/bin/bash

# agent estate — stop hook
# blocks exit and re-injects prompt unless done or stopped
# stop: /agent-estate:stop (removes state file)
# done: claude writes done: true to state file

set -euo pipefail

# config
RATE_LIMIT_WAIT=60         # seconds to wait on rate limit
OVERLOADED_WAIT=30         # seconds to wait on overloaded

# read stdin (hook input)
HOOK_INPUT=$(cat)

STATE_FILE=".claude/agent-estate.local.md"

# no state file = no active loop, allow exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
CYCLE=$(echo "$FRONTMATTER" | grep '^cycle:' | sed 's/cycle: *//' || echo "0")
DONE=$(echo "$FRONTMATTER" | grep '^done:' | sed 's/done: *//' || echo "false")

# check if task is marked done
if [[ "$DONE" == "true" ]]; then
  echo "Agent Estate: task marked done at cycle $CYCLE — stopping loop." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# rate limit detection
WAIT_SECONDS=0
WAIT_REASON=""

if echo "$HOOK_INPUT" | grep -qiE 'rate.?limit|429|too many requests|rate_limit_error'; then
  WAIT_SECONDS=$RATE_LIMIT_WAIT
  WAIT_REASON="rate limit"
elif echo "$HOOK_INPUT" | grep -qiE 'overloaded|529|overloaded_error|capacity'; then
  WAIT_SECONDS=$OVERLOADED_WAIT
  WAIT_REASON="API overloaded"
fi

# if rate limited, wait it out
if [[ $WAIT_SECONDS -gt 0 ]]; then
  echo "Agent Estate: $WAIT_REASON detected — waiting ${WAIT_SECONDS}s before next cycle..." >&2
  sleep "$WAIT_SECONDS"
fi

# if cycle is not numeric, reset to 0
if [[ ! "$CYCLE" =~ ^[0-9]+$ ]]; then
  CYCLE=0
fi

# increment cycle
NEXT_CYCLE=$((CYCLE + 1))

# extract prompt (everything after closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

# fallback prompt if empty
if [[ -z "$PROMPT_TEXT" ]]; then
  PROMPT_TEXT="You are Agent Estate — autonomous agent. Read .claude/agent-estate.md for the ledger. Do work. Update the ledger. Stop: /agent-estate:stop"
fi

# update cycle in state file
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^cycle: .*/cycle: $NEXT_CYCLE/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# build reason message
if [[ -n "$WAIT_REASON" ]]; then
  REASON="Agent Estate cycle $NEXT_CYCLE — resumed after ${WAIT_REASON}. Read .claude/agent-estate.md and immediately start the next cycle of work. Do NOT summarize or stop — do real work now."
else
  REASON="Agent Estate cycle $NEXT_CYCLE starting. Read .claude/agent-estate.md ledger, pick the next task, do the work, update the ledger. Do NOT stop or give a summary. Start working immediately."
fi

# block exit, re-inject — always (as long as state file exists and not done)
jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "block",
    "reason": $reason
  }'

exit 0

