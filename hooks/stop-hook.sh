#!/bin/bash

# Claude Estate Stop Hook
# PERPETUAL — no end condition, no exit, no completion promise
# The only way to stop is /claude-estate:stop (which removes the state file)

set -euo pipefail

# ---- Configuration ----
RATE_LIMIT_WAIT=60         # seconds to wait on rate limit
OVERLOADED_WAIT=30         # seconds to wait on overloaded API

# Read stdin (hook input) — check for rate limit errors before re-injecting
HOOK_INPUT=$(cat)

STATE_FILE=".claude/claude-estate.local.md"

# No state file = no active loop — allow exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# ---- Rate limit detection ----
# Check if the session ended due to a rate limit or API overload
WAIT_SECONDS=0
WAIT_REASON=""

if echo "$HOOK_INPUT" | grep -qiE 'rate.?limit|429|too many requests|rate_limit_error'; then
  WAIT_SECONDS=$RATE_LIMIT_WAIT
  WAIT_REASON="rate limit"
elif echo "$HOOK_INPUT" | grep -qiE 'overloaded|529|overloaded_error|capacity'; then
  WAIT_SECONDS=$OVERLOADED_WAIT
  WAIT_REASON="API overloaded"
fi

# If rate limited, wait it out before re-injecting
if [[ $WAIT_SECONDS -gt 0 ]]; then
  echo "Claude Estate: $WAIT_REASON detected — waiting ${WAIT_SECONDS}s before next cycle..." >&2
  sleep "$WAIT_SECONDS"
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
CYCLE=$(echo "$FRONTMATTER" | grep '^cycle:' | sed 's/cycle: *//' || echo "0")

# If cycle is not numeric, reset to 0 instead of dying
if [[ ! "$CYCLE" =~ ^[0-9]+$ ]]; then
  CYCLE=0
fi

# Increment cycle
NEXT_CYCLE=$((CYCLE + 1))

# Extract prompt (everything after the closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

# If no prompt text, use a fallback — never die
if [[ -z "$PROMPT_TEXT" ]]; then
  PROMPT_TEXT="You are Claude Estate — perpetual autonomous agent. Read .claude/claude-estate.md for the ledger. Do work. Update the ledger. Never stop. Stop: /claude-estate:stop"
fi

# Update cycle in state file
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^cycle: .*/cycle: $NEXT_CYCLE/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# Build system message (include rate limit info if applicable)
if [[ -n "$WAIT_REASON" ]]; then
  REASON="Claude Estate cycle $NEXT_CYCLE — resumed after ${WAIT_REASON}. Read .claude/claude-estate.md and immediately start the next cycle of work. Do NOT summarize or stop — do real work now."
else
  REASON="Claude Estate cycle $NEXT_CYCLE starting. Read .claude/claude-estate.md ledger, pick the next task, do the work, update the ledger. Do NOT stop or give a summary. Start working immediately."
fi

# Block the stop, re-inject — ALWAYS (as long as state file exists)
jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "block",
    "reason": $reason
  }'

exit 0
