---
name: backup
description: "Creates a timestamped backup of memory.db to the Backup folder. Called automatically by goal-update and finance-update before any write operation. 
Can also be called directly by the user."
version: 2.0
Last updated: 2026-05-24
---

## Purpose
Creates a timestamped backup of memory.db before any write
operation. Called by goal-update and finance-update before
touching the database. Can also be invoked directly by the user.

## Source file
Configured path defined in orchestrator.md.

## Backup folder
Configured path defined in orchestrator.md.

## Naming convention
Format: memory_YYYY-MM-DD_HH-MM.db
Example: memory_2026-05-24_14-30.db

Use datetime.now() to generate the timestamp at the moment the
backup is taken. HH is 24-hour hour, MM is minutes.

## Behaviour
1. Resolve source path to memory.db via orchestrator.md
2. Ensure Backup folder exists — create it if missing
3. Generate timestamped filename using datetime.now()
4. Copy memory.db to Backup\<timestamped filename> using shutil.copy2()
5. Stamp backup file metadata with actual backup time via os.utime()
6. Run the file count check (see below)
7. Confirm backup filename and size back to the caller

## File count check
File count rolling over 3 unable to delete 4th backup due to linux sandbox in cowork being unable to delete files, windows task scheduler set up to delete 4th entry on a 3 rolling backup.

## os.utime fix
After every shutil.copy2():
  os.utime(dest_path, (time.time(), time.time()))
This ensures backup file metadata reflects actual backup time,
not the source file's modified time.

## Error handling
If source file not found:
  Stop immediately. Report: "Source file not found at configured
  path. Write operation cancelled."
If Backup folder cannot be created:
  Stop. Report the error clearly. Do not proceed.
If backup copy fails for any reason:
  Stop. Report the error. Do not proceed with the write operation.

## Return value
On success, report:
  "Backup created: [filename] ([size] bytes)"
