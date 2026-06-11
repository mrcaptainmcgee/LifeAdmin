# Changelog

## v0.1 — Proof of Concept
- 9 skills built around an Excel file of goals and finances
- SQLite selected over JSON for persistent structured memory
- memory.db created; goals migrated from Excel into SQL
- Folder structure established
- Sensitivity controls: SQL flag, Private subfolder, and skill-level enforcement
- Backup system: timestamped flat files, manual deletion required, alerts when more than 3 backups are present (file deletion across the FUSE-mounted Linux sandbox is unreliable between sessions)

## v0.2 — Mini PC Migration
- Dedicated always-on mini PC provisioned
- Fresh Windows 11 install with drivers
- LifeAdmin folder moved off OneDrive to local drive — OneDrive's active sync conflicts with SQLite's exclusive file lock, creating corruption risk and write failures mid-execution. Excel output files sync individually to OneDrive via robocopy Task Scheduler job; no .db or .db-wal files touch OneDrive
- Claude Desktop installed with filesystem MCP; LifeAdmin folder set as the single allowed path
- Excel files migrated to Outputs\ folder

## v0.3 — Architecture Redesign
- System redesigned around a clean LLM-agnostic cycle: Agent Identity → Orchestrator → Skills → Composer → Output
- orchestrator.md created for identity and file paths
- composer.md created for formatting and style guidance
- 9 skills reduced to 7; session-start, weekly-review, stale-check, finance-check, and orphan-check consolidated into a single review skill with modes per context
- fetch skill added as a dedicated read-only DB access layer; WAL mode and /tmp copy pattern on every connection to handle FUSE instability and overlapping skill execution
- All skills rewritten as self-contained files with YAML front matter
- Excel files demoted to presentation layer only; memory.db is the single source of truth

## v0.4 — Baseline Testing
**In Progress**
