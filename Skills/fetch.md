---
name: fetch
description: "Read-only data access layer for memory.db. Called internally by other skills before any read or write operation. Never called directly by the user. 
Triggers when any other skill needs to query goals, milestones, update_log, files, or finance data from the database."
version: 1.1
---

## Purpose
Read-only data access layer for memory.db.
Called by other skills before any read or write operation.
Never writes to any database.
Never called directly by the user.

## Database
Configured path defined in orchestrator.md.

## Connection method
The FUSE-mounted path is unreliable for direct sqlite3.connect().
On every connection:
1. Copy memory.db from the mounted path to /tmp/memory_read.db
2. Connect to /tmp/memory_read.db — never connect to the mounted path directly
3. Run PRAGMA journal_mode=WAL on the /tmp connection
This is read-only. Never write to /tmp/memory_read.db.

## Queries

### All goals with current status
SELECT id, name, category, brag, target, blocked_by,
       last_updated, next_action, notes
FROM goals
ORDER BY id;

### Single goal by ID
SELECT id, name, category, brag, target, blocked_by,
       last_updated, next_action, notes
FROM goals
WHERE id = ?;

### Goals by BRAG status
SELECT id, name, brag, last_updated, next_action
FROM goals
WHERE brag = ?
ORDER BY id;

### Stale goals (not updated in 14+ days)
SELECT id, name, brag, last_updated, next_action
FROM goals
WHERE last_updated <= date('now', '-14 days')
AND brag NOT IN ('Completed')
ORDER BY last_updated ASC;

### Milestones for a goal
SELECT step, description, due, brag, start_month, end_month
FROM milestones
WHERE goal_id = ?
ORDER BY step;

### Recent update log (last N entries)
SELECT timestamp, goal_id, update_type, what_changed,
       previous_value, new_value, triggered_by
FROM update_log
ORDER BY timestamp DESC
LIMIT ?;

### Update log for a specific goal
SELECT timestamp, update_type, what_changed,
       previous_value, new_value
FROM update_log
WHERE goal_id = ?
ORDER BY timestamp DESC;

### All files
SELECT id, filename, filepath, date_added, doc_type,
       tags, goal_link, sensitive, notes
FROM files
ORDER BY date_added DESC;

### Files by goal
SELECT filename, filepath, doc_type, sensitive
FROM files
WHERE goal_link = ?
ORDER BY date_added DESC;

### Sensitive file count by goal
SELECT goal_link, COUNT(*) as sensitive_count
FROM files
WHERE sensitive = 1
GROUP BY goal_link;

### Finance log (all entries)
SELECT timestamp, category, change_type, amount, notes
FROM finance_log
ORDER BY timestamp DESC;

### Finance log by category
SELECT timestamp, change_type, amount, notes
FROM finance_log
WHERE category = ?
ORDER BY timestamp DESC;

### Finance summary (totals by category and type)
SELECT category, change_type, SUM(amount) as total
FROM finance_log
GROUP BY category, change_type
ORDER BY category;

## Error handling
If memory.db is not found at the mounted path:
  Stop immediately. Report: "memory.db not found at configured path.
  Check orchestrator.md file paths."
If copy to /tmp fails:
  Stop immediately. Report the error. Do not attempt to connect
  to the mounted path directly.
If a query returns no results:
  Return empty result clearly. Do not error.
If WAL pragma fails:
  Continue but log a warning in the response.
