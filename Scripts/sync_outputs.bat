@echo off
REM ============================================================
REM  LifeAdmin — Outputs Sync
REM  Mirrors Outputs folder to OneDrive every 1 minute via Task Scheduler.
REM  Excludes all database files to prevent OneDrive sync conflicts.
REM  Update SOURCE and DEST to match your local paths.
REM ============================================================

set SOURCE="C:\path\to\LifeAdmin\Outputs"
set DEST="C:\path\to\OneDrive\LifeAdmin Outputs"

robocopy %SOURCE% %DEST% /E /MIR /XF *.db *.db-wal

REM ============================================================
REM  Flags:
REM  /E   — copy all subfolders including empty ones
REM  /MIR — mirror source to destination (deletes from dest if deleted from source)
REM  /XF  — exclude file types: *.db and *.db-wal (SQLite databases)
REM ============================================================
