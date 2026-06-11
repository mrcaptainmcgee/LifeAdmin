@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  cleanup_backups.bat
REM  Keeps the 3 most recent memory.db backups.
REM  Deletes oldest files when count exceeds 3.
REM  Schedule: daily via Task Scheduler.
REM  Update BACKUP_DIR to match your local LifeAdmin\Backup\ path.
REM ============================================================

set BACKUP_DIR=C:\path\to\LifeAdmin\Backup

REM Count .db files in Backup folder
set COUNT=0
for %%F in ("%BACKUP_DIR%\memory_*.db") do set /a COUNT+=1

REM If 3 or fewer, nothing to do
if %COUNT% LEQ 3 goto :done

REM Calculate how many to delete (COUNT - 3)
set /a DELETE_COUNT=COUNT-3

REM Delete oldest files first (sorted ascending by name = oldest first)
REM memory_YYYY-MM-DD_HH-MM.db sorts correctly alphabetically
set DELETED=0
for /f "tokens=*" %%F in ('dir /b /a-d /o:n "%BACKUP_DIR%\memory_*.db"') do (
    if !DELETED! LSS %DELETE_COUNT% (
        del "%BACKUP_DIR%\%%F"
        set /a DELETED+=1
    )
)

:done
exit /b 0
