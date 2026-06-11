# LifeAdmin
LifeAdmin | LLM-Agnostic | Skill-based | Persistant-Memory | AuDHD System Design

## Overview
A personal life administration system with embedded AI. Manages finances, goals, meals, and calendar events through a skill-based, LLM-agnostic architecture built on organised, legible data.
LifeAdmin runs entirely within a single folder on a dedicated always-on machine. An LLM interacts with the system by reading and writing files directly — via Claude Desktop with filesystem MCP — through a structured folder architecture. Outputs sync to OneDrive for mobile access.

> Note: `memory.db`, Excel output files, the Backup folder, and the Document Library are excluded from this repository as they contain personal data. The full SQLite schema is documented below. Finance tables are omitted as the finance schema is currently under active development.

## Architecture

```
Agent Identity (orchestrator.md)
  → LLM (Claude Desktop + Cowork)
    → Skills (fetch, review, goal-update, finance-update, file-index, backup, bug-log)
      → Composer
        → Output
```

## Stack

| Layer | Technology |
|---|---|
| Source of truth | SQLite + WAL mode (`memory.db`) |
| Presentation | Excel (generated from DB, never written to directly) |
| Config | Markdown (`orchestrator.md`, `composer.md`) |
| Sync | Robocopy via Windows Task Scheduler (outputs only, no `.db` files) |
| Execution | Claude Desktop + filesystem MCP |

## SQLite Schema

Finance tables are omitted — schema under active development in v0.4.

```sql
-- Goals
CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  brag TEXT DEFAULT '⚪ Not Started',
  target TEXT,
  blocked_by TEXT,
  finance_link INTEGER DEFAULT 0,
  last_updated TEXT,
  next_action TEXT,
  notes TEXT,
  priority TEXT DEFAULT 'Medium',
  completion_pct INTEGER DEFAULT 0
);

CREATE TABLE milestones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  goal_id TEXT NOT NULL,
  step INTEGER NOT NULL,
  description TEXT,
  due TEXT,
  brag TEXT DEFAULT '⚪ Not Started',
  start_month TEXT,
  end_month TEXT,
  FOREIGN KEY (goal_id) REFERENCES goals(id)
);

-- Files
CREATE TABLE files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename TEXT NOT NULL,
  filepath TEXT,
  date_added TEXT,
  doc_type TEXT,
  tags TEXT,
  goal_link TEXT,
  sensitive INTEGER DEFAULT 0,
  notes TEXT
);

-- Health
CREATE TABLE health_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  metric TEXT,
  value TEXT,
  notes TEXT,
  goal_link TEXT
);

-- Journal
CREATE TABLE journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  content TEXT,
  energy_level INTEGER,
  goals_mentioned TEXT
);

-- Audit
CREATE TABLE update_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  goal_id TEXT,
  update_type TEXT,
  what_changed TEXT,
  previous_value TEXT,
  new_value TEXT,
  triggered_by TEXT
);
```

## Methodologies

Built on two published frameworks:

- **ICM (Interpreted Context Methodology)** — a philosophy of folders as architecture, making systems legible to both humans and AI. [github.com/RinDig/Interpreted-Context-Methdology](https://github.com/RinDig/Interpreted-Context-Methdology)
- **MEBS Framework** — removes ambiguity from natural language prompts for more accurate and repeatable AI task execution. [zenodo.org/records/18607750](https://zenodo.org/records/18607750)

## Design Principles

### AuDHD-Informed System Design

LifeAdmin is designed from the ground up for Autism and ADHD profiles — not as an accessibility afterthought, but as the primary design constraint. 

The gap between a tool people use and a tool people abandon is almost never capability — it's friction. An unclear trigger, an invisible action, a decision required before you've even started. LifeAdmin is built around one constraint: remove every point where the system could lose you. What's left is something you can actually rely on.

This produces specific, non-negotiable UX rules:

- **Single trigger → single output.** One command does one thing. No branching mid-execution, no decisions required to start.
- **No invisible state.** If something happens without visible confirmation, it will eventually cause confusion or distrust of the system. Every action is logged.
- **Explicit over implicit.** The system says what it did. Confirmation messages are not optional.
- **Minimal surface area.** More files, tables, and configs means more cognitive overhead and more things to break. The simplest viable solution is always the default.
- **Ambiguity kills follow-through.** Unclear triggers or variable outputs cause features to be abandoned. Every skill has a single, unambiguous entry point.

### Organised Data, Not Model Capability

The reason AI fails in most organisations isn't the model — it's the context wall: fractured data landscapes where processes live in people's heads, knowledge is never documented, and there is no coherent structure for an AI to anchor to. The model hallucinates because it's reaching into fog.

LifeAdmin works because it's built on organised, legible data. Skills don't need to infer structure — the structure is already there. This is the same principle Anthropic's own skill-based architecture validates: one agent reading the right skill folder becomes whatever is needed on the fly.

The system uses AI only where it genuinely reduces executive function load — absorbing the tension between knowing what needs doing and initiating it. Everything else is structured data, markdown config, and deterministic skill execution.

## Development

Development tracked via Roadmap → Changelog.

## Future

- Homelab expansion: local Ollama inference, Tailscale networking, redundancy
- Obsidian vault: semantic memory, Smart Connections plugin, second brain capability
