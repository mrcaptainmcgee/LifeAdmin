# Roadmap

## v0.5 — Context Personalisation & Token Optimisation
- Prompt engineering with personalisation for communication style and response shaping
- Taxonomy index of terms and phrases with defined single meanings — improves inference accuracy and reduces ambiguity at execution time
- Skill responses shaped by context rather than generic templates
- Audit all skills for unnecessary data loading
- fetch skill: enforce strict column selection, no SELECT *
- review skill: cap output length per mode, never surface more than needed
- Ensure no skill loads unbounded data sets
- Establish token budget principles for all future skill development
- skill_log_id foreign key on bug_log — link failures to bug entries

## v0.6 — Goal Dependencies & Unlock Triggers
- Post-goal-completion trigger — marks goal done, checks what was blocked by it, surfaces newly unblocked items
- Dependencies between goals with unlock notifications — keeps the goal graph moving without manual tracking

## v0.7 — Cold Storage
- Separate archive.db — keeps memory.db lean and queries fast
- archive.db has its own backup and retention policy — longer intervals, less frequent than the live DB
- Archived data: completed goals, old finance logs, historical patterns
- New skill: habit-analysis — queries archive.db for long-term pattern analysis
- Cross-DB queries handled within the skill, holding two connections

## v0.8 — Meal Engine
- SQLite tables: meals, ingredients, meal_ingredients (join table), shopping_list
- Skills: meal-add, meal-plan, shopping-gen, pantry-check (optional)
- Low-executive-function day tags: quick meals, batch cook
- Open question: lightweight inference-based ingredient list vs full pantry management — decision deferred to build time

## v0.9 — Calendar Integration
- Calendar skills: entry, amend, delete
- Review skill integration
- Dependencies and triggers between calendar events, goals, and finances
- Recurring personal event notifications

## v1.0 — Skill Self-Improvement Loop
- Three skills forming a feedback circuit:
  - feedback — rate a skill interaction after it runs (1–5 + freetext)
  - review skill (weekly mode) — surfaces low-rated interactions, flags skills for update
  - skill-creator — acts on review output to refine skill files
- Depends on review skill being stable first
- skill_log provides months of execution data as signal by the time this lands

## v1.1 — Post-Stable Optimisation
- Revisit optimisation of all features since v0.6 for token efficiency at scale
- Audit fetch skill against all tables added since v0.6
- Review archive.db query patterns for cold storage efficiency
- Confirm no skill has drifted from token budget principles established in v0.5
