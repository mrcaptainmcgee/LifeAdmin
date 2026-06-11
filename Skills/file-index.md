---
name: file-index
description: "Logs documents to the files table in memory.db. Triggers when a file is uploaded to Cowork or when the user asks to index or log a document. 
Always asks the sensitivity question before indexing. Captures filename, filepath, doc_type, goal_link, sensitive flag, date_added, and optional tags and notes."
version: 1.0
Last updated: 2026-04-04
---

## Purpose
Logs documents to the files table in memory.db.
Triggered when a file is uploaded to Cowork or when
the user asks to index a document.
Always asks sensitivity question before indexing.
Never writes to Excel. No backup required — DB only.

## Trigger examples
"Index this document"
"Log this file"
"Add this to the document library"
[file uploaded to Cowork conversation]

## Execution order
1. Identify filename and filepath from upload or user input
2. Ask sensitivity question — wait for answer before proceeding
3. Collect remaining metadata — ask for any missing required fields
4. Write to files table in memory.db
5. Confirm what was indexed

## Sensitivity question
Always ask before indexing:
  "Is this file sensitive? Sensitive files are stored in
  Document Library\Private\ and will not appear in
  reviews or summaries — only counted per goal."

If yes:
  Confirm filepath is or will be in Document Library\Private\
  Set sensitive = 1

If no:
  Set sensitive = 0

## Required fields
Always capture:
- filename        — from upload or user input
- filepath        — full path within LifeAdmin\
- doc_type        — ask if not obvious from filename
                    (contract, letter, medical, financial,
                    ID, correspondence, other)
- goal_link       — ask which goal this relates to
                    (use goal ID e.g. G04). Null if none.
- sensitive       — from sensitivity question above
- date_added      — auto-set to date('now')

Optional fields (ask but accept if skipped):
- tags            — freeform keywords, comma separated
- notes           — any additional context

## DB write — files
INSERT INTO files (
  filename, filepath, date_added, doc_type,
  tags, goal_link, sensitive, notes
) VALUES (
  ?, ?, date('now'), ?, ?, ?, ?, ?
);

## Sensitive file handling
Sensitive files:
- Must live in Document Library\Private\
- Never surfaced in reviews or summaries
- Appear only as a count per goal in review output
- Confirm to user that file is marked sensitive
  and will not appear in standard reviews

## Error handling
If filename or filepath cannot be determined:
  Ask the user before proceeding.
If goal_link provided does not match any goal ID
in memory.db:
  Flag it. Ask user to confirm or correct.
  Do not block indexing — log with the provided value
  and note the mismatch.
If DB write fails:
  Report the error. Do not retry silently.

## Confirmation output
On completion, report:
- Filename indexed
- Doc type
- Goal linked: [ID] or none
- Sensitive: yes / no
- Tags: [tags] or none
- Notes: [notes] or none
- Date added: [date]
