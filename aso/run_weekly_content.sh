#!/bin/bash
# Weekly CONTENT AUTOPILOT — invokes Claude Code headless to publish ONE new
# high-quality guide to www.ai-manifest.com, deploy, and index it. Website-only
# by prompt guardrails; no ASC/app/social/reviews. Reversible via git.
export PATH="/Users/yageloshri/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
REPO="/Users/yageloshri/ManifestAI-Gratitude-Journal"
cd "$REPO" || exit 1
mkdir -p aso/logs aso/reports
LOG="aso/logs/content.log"
echo "=== content autopilot run $(date) ===" >> "$LOG"
PROMPT="$(cat "$REPO/aso/content_autopilot_prompt.txt")"

# Headless run. Scoped to the tools the pipeline needs; the prompt is the
# guardrail (website-only). Model kept to sonnet for weekly cost control.
# macOS has no `timeout`; use gtimeout if present, else run without a cap.
TIMEOUT_CMD="$(command -v timeout || command -v gtimeout || true)"
if [ -n "$TIMEOUT_CMD" ]; then RUN="$TIMEOUT_CMD 2400"; else RUN=""; fi
$RUN claude -p "$PROMPT" \
  --model sonnet \
  --dangerously-skip-permissions \
  --allowedTools "Bash Read Write Edit Glob Grep WebSearch WebFetch" \
  >> "$LOG" 2>&1
echo "exit=$? at $(date)" >> "$LOG"
