---
name: review
description: "Read-only review and summary skill. Triggers on prompts like run a full review, what needs attention, catch me up, weekly review, review my finances, what is stale, or file-to-goal check. 
Supports modes: full, urgent, finance, stale, file-to-goal check, unindexed. Never writes to any file or database. Output delivered in Cowork chat only."
version: 1.1
---

## Purpose
Read-only. Fetches data from memory.db via the fetch skill
and surfaces a structured review in the Cowork chat.
No files created. No writes to any database.
Can be triggered on desktop or via Dispatch on mobile.

## Modes
/review full               — complete review of everything
/review urgent             — at-risk and stale goals only
/review finance            — finance summary for both users
/review stale              — goals not updated in 14+ days
/review file-to-goal check — files in index with no matching goal
/review unindexed          — files in Document Library not present in index

## Trigger examples
"Run a full review"
"What needs attention"
"Catch me up"
"Weekly review"
"Review my finances"
"What's stale"

## /review full
Calls fetch for:
- All goals with current BRAG status and next action
- All milestones per goal
- Stale goals (14+ days)
- Finance summary (totals by category and type,
  both users together)

Output structure:
1. Goals by BRAG status
   - Red: list with next action and days since updated
   - Amber: list with next action and days since updated
   - Green: list with next action
   - Blue (completed): list only
   - Not started: list only
2. Blocked goals — flagged as a dedicated section, not inline.
   Show what each is blocked by.
3. Stale goals — flagged prominently. Show last updated
   date and how many days ago.
4. Milestones — per in-progress goal, show all steps
   with BRAG status and due date
5. Finance summary — both users side by side,
   totals by category and change type

## /review urgent
Calls fetch for:
- Goals where brag = 'Red'
- Goals where brag = 'Amber'
- Stale goals (14+ days)
- Blocked goals

Output structure:
1. Red goals — next action, days since updated
2. Amber goals — next action, days since updated
3. Stale goals — last updated, days since updated
4. Blocked goals — what each is blocked by

## /review finance
Calls fetch for:
- Full finance_log
- Finance summary (totals by category and type)

Output structure:
1. Recent entries — last 10, both users together
2. Totals by category — income, expenses, debt payments
3. Per-user totals
4. Combined total

## /review stale
Calls fetch for:
- Goals not updated in 14+ days
- Excludes completed goals

Output structure:
- Goal ID, name, BRAG, last updated, days since updated
- Next action if set
- Ordered oldest first

## /review file-to-goal check
Calls fetch for:
- All files in files table
- All goal IDs in goals table

Output structure:
- Files where goal_link does not match any active goal ID
- Files where goal_link is null or empty
- Count of orphaned files
- Suggest: re-link or remove from index

## /review unindexed
Calls fetch for:
- All filepath values in files table

Also scans:
- Document Library\ — returns filenames of any file not
  present in files table
- Document Library\Private\ — returns count only,
  no filenames surfaced

Output structure:
- List of unindexed files in Document Library\ with filename
  and inferred type where possible
- Count of unindexed files in Document Library\Private\
  (no filenames surfaced)
- Total unindexed count across both
- Suggest: run file-index for each unindexed file
- Nothing written to any file or database

## Blocked goals
In any mode that surfaces blocked goals, always flag
them in a dedicated section with this format:
  BLOCKED: [Goal ID] [Goal name]
  Blocked by: [blocked_by value]
Never show blocked goals only inline — always called
out explicitly regardless of BRAG status.

## Stale threshold
14 days. Any goal not updated in 14+ days and not
completed is considered stale. Always show number of
days since last update, not just the date.

## Output format
Prose introduction summarising the state of play.
Structured sections with bullet points per goal.
Full output — nothing omitted or truncated.
Delivered in Cowork chat only. No files created.

## Error handling
If fetch returns no goals:
  Report: "No goals found in memory.db. Check database."
If fetch returns no finance entries:
  Report: "No finance entries found." Continue with
  goals section.
If memory.db not found:
  Stop. Report path error from fetch skill.
