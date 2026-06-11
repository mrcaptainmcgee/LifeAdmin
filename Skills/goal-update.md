---
name: goal-update
description: "Updates goal and milestone data in memory.db and reflects changes in the Excel Goals tracker. 
Triggers when the user wants to change any field on a goal or milestone including BRAG status, next action, notes, target, or blocked_by. Always calls backup before writing."
version: 1.1
Last updated: 2026-04-18
---

## Purpose
Updates goal and milestone data in memory.db, then
reflects changes in the Excel Goals tracker.
Always calls backup before any write.
Always calls fetch to get current state before updating.
Always logs every change to update_log.

## Trigger examples
"Update goal X BRAG to Amber"
"Mark goal X as complete"
"Add a note to goal X"
"Update milestone 3 on goal X"
"Change next action on goal X"

## Execution order
1. Call fetch — get current state of the goal
2. Call backup — back up memory.db before any write
3. Copy memory.db to /tmp — all reads and writes in
   steps 4–6 run against /tmp copy
4. Write update to /tmp copy (goal or milestone)
5. If the update changed a milestone's brag status →
   recalculate completion_pct (see below)
6. Write to update_log in /tmp copy
7. Verify write — query the written row before closing connection
8. Copy /tmp back to mounted path — if this fails, stop
   and report immediately
9. Reflect changes in Excel Goals tracker
10. Confirm what was changed

## Updatable fields

### Goals table
- name
- category
- brag
- target
- blocked_by
- finance_link
- last_updated (auto-set to today on every update)
- next_action
- notes

### Milestones table
- description
- due
- brag
- start_month
- end_month

## DB write method
All DB operations run against a /tmp copy to avoid FUSE
mount instability.
On every write:
1. Copy memory.db from mounted path to /tmp/memory_write.db
2. Connect to /tmp/memory_write.db — never connect to
   mounted path directly
3. Run PRAGMA journal_mode=WAL
4. Execute all reads and writes (goals/milestones/update_log)
   in one session
5. Verify — query the written row before closing connection
6. Close connection
7. Copy /tmp/memory_write.db back to mounted path
8. If copy-back fails:
     Stop immediately. Report: "DB write succeeded in /tmp
     but copy-back failed — [error]. Mounted memory.db may
     be stale. Do not update Excel."
     Do not silently continue.

## DB write — goals
UPDATE goals
SET [field] = ?,
    last_updated = date('now')
WHERE id = ?;

## DB write — milestones
UPDATE milestones
SET [field] = ?
WHERE goal_id = ? AND step = ?;

## Auto-recalculate completion_pct after milestone brag change
Trigger: any write that changes a milestone's brag field.
Run BEFORE closing the DB connection, in the same transaction.

SQL to run (replace [goal_id] with the actual goal ID):

UPDATE goals
SET completion_pct = (
  SELECT ROUND(
    SUM(CASE WHEN brag = 'Complete' THEN 1 ELSE 0 END) * 100.0 /
    NULLIF(COUNT(*), 0), 0
  )
  FROM milestones WHERE goal_id = '[goal_id]'
),
last_updated = date('now')
WHERE id = '[goal_id]';

Rules:
- If the goal has 0 milestones, NULLIF returns NULL →
  set completion_pct = 0 instead
- Always update last_updated in the same statement
- Run AFTER the milestone write, BEFORE committing
- Include the resulting completion_pct in the confirmation output

## DB write — update_log
INSERT INTO update_log (
  timestamp, goal_id, update_type,
  what_changed, previous_value, new_value, triggered_by
) VALUES (
  datetime('now'), ?, ?, ?, ?, ?, 'Cowork'
);

## Excel Goals tracker
Path configured in orchestrator.md.

Update the relevant goal row with all changed fields.
In the update log sheet, show the last 10 entries only
from update_log — ordered by timestamp DESC, limit 10.
Do not truncate the DB log — DB keeps everything.
Excel shows last 10 for clarity.

## Error handling
If fetch returns no matching goal:
  Stop. Report: "Goal [id] not found in memory.db."
If backup fails:
  Stop. Do not write. Report the error.
If DB write fails:
  Stop. Do not update Excel. Report the error.
If copy-back to mounted path fails:
  Stop immediately. Report the error. Do not update Excel.
If Excel write fails:
  Report the error. DB is already updated — flag the
  discrepancy so it can be resolved manually.

## Confirmation output
On completion, report:
- Goal ID and name
- Field(s) changed
- Previous value → new value
- Completion % (if milestone brag was updated): X% complete
- Backup taken: [filename]
- Excel updated: yes
