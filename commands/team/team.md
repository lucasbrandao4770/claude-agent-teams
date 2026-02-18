# Team Command

> **CRITICAL:** You are now the Team Architect. Execute these instructions DIRECTLY in the main session. Do NOT delegate to a subagent — subagents cannot spawn teams or interact with the user.

## Parse Input

- `/team` (no args) → **List Templates**
- `/team <template>` → **Spawn Team** (with confirmation)
- `/team <template> --dry` → **Dry Run** (show plan, stop)
- `/team <template> --max-mode` → **Spawn Team** with all workers using Opus
- `/team <template> --dry --max-mode` → **Dry Run** showing Opus workers
- `/team create` → **Create Template** (guided)

### `--max-mode` Flag

When `--max-mode` is present in the args, ALL workers spawn with `model: "opus"` instead of `model: "sonnet"`. This overrides the template's default model assignments for workers.

- Default: Lead = Opus, Workers = Sonnet (cost-effective)
- `--max-mode`: Lead = Opus, Workers = Opus (maximum quality)

Apply to the `model` parameter in every Task tool spawn call in Step 5.

---

## List Templates

Show this catalog and suggest the most relevant template for the current project:

| Template | Pattern | Size | Best For |
|----------|---------|------|----------|
| code-review | Council | 3 | Multi-perspective code review |
| debug-investigate | Leader/Specialist | 3 | Bug with unknown root cause |
| refactor | Parallel Workers | 2-4 | Safe cross-module changes |
| fullstack-feature | Leader/Specialist | 3 | New feature with UI + API + tests |
| research-review | Parallel Workers | 3-4 | Literature review and synthesis |
| oss-kickstart | Leader/Specialist | 3 | Create a new OSS project from scratch |
| oss-sprint | Leader/Specialist | 4 | Work on issues from GitHub backlog |
| oss-company | Leader/Specialist | 5 | Full company simulation (max quality) |

Usage: `/team <name>`, `/team <name> --dry`, `/team <name> --max-mode`, `/team create`

---

## Spawn Team

YOU are the team lead. You coordinate, synthesize, and interact with the user. Only workers get spawned as teammates. Follow these steps IN ORDER.

### Step 1: Load Template

Read `~/.claude/skills/agent-teams/references/templates/<template-name>.md`

If the template doesn't exist, tell the user and show the catalog.

### Step 2: Discover Project Context

Run these in parallel:
- Read `.claude/CLAUDE.md` if it exists (project conventions)
- Glob `.claude/agents/**/*.md` (project-specific agents)
- Glob project source directories to understand the file structure

For each template role, check if a matching project agent exists:

| Template Role | Look for Agent File |
|---|---|
| Security Reviewer | `security-*.md`, `code-reviewer.md` |
| Performance Reviewer | `performance-*.md`, `spark-*.md` |
| Architecture Reviewer | `code-reviewer.md`, `architect.md` |
| Frontend Developer | `ui-*.md`, `frontend-*.md` |
| Backend Developer | `data-engineer*.md`, `api-*.md` |
| Research Scout | `literature-scout.md`, `researcher-*.md` |
| Test Writer | `test-generator.md`, `testing-*.md` |

If found: include agent's instructions in the teammate's spawn prompt.
If not found: use template's default role description.

### Step 3: Build File Ownership Map

- List ALL files the team will touch
- Assign each file to exactly ONE teammate
- **VERIFY: no file appears in two ownership lists**
- Shared files (config, types, utils) stay with you (the lead)
- Map to actual project paths, not template placeholders

### Step 4: Present Plan and Confirm

Show the user the complete plan before spawning:

```
TEAM PLAN: <template-name>
===========================
Pattern: <pattern>
Estimated tokens: <estimate>

YOU (Lead, Opus):
  Role: <lead role from template>
  Owned files: <your files>

TEAMMATES:
  1. <Worker name> (Sonnet) — <role>
     Files: <owned files>
     Tasks: <task list>
  2. <Worker name> (Sonnet) — <role>
     Files: <owned files>
     Tasks: <task list>

PROJECT AGENTS DISCOVERED:
  - <agent>.md → mapped to <role>
  - (none found) → using template defaults
```

Then ask the user to confirm using AskUserQuestion:
- "Spawn team" — proceed to Step 5
- "Adjust plan" — ask what to change, revise, re-present
- "Cancel" — exit

If `--dry` flag: show plan and STOP. Do not ask to confirm.

### Step 5: Spawn

Execute in order:

1. **TeamCreate** with descriptive team name
2. **TaskCreate** for each task — include clear deliverables and success criteria
3. **TaskUpdate** with `addBlockedBy` for dependent tasks (e.g., synthesis blocked by reviews)
4. **Spawn each worker** via `Task` tool:

```
Task tool parameters:
  subagent_type: "general-purpose"   (or from template)
  team_name:     "<team-name>"
  name:          "<role-name>"       (e.g., "security-reviewer")
  model:         "sonnet"            (default — or "opus" if --max-mode flag is set)
  prompt:        <built from Teammate Prompt Template below>
```

**OSS templates with phased execution (oss-kickstart):** Before Step 5 team spawn, run Phase 1 subagents (foreground, via Task tool WITHOUT team_name) for setup work. Lead receives summaries, then spawns team workers for Phase 2.

### Step 6: Monitor and Synthesize

- Track progress via `TaskList`
- When teammates complete tasks, they'll message you
- When ALL workers are done:
  1. Read their output files
  2. Synthesize findings (deduplicate, sort by severity)
  3. Present final summary to user
  4. Shutdown teammates: `SendMessage` with type `shutdown_request`
  5. `TeamDelete` for cleanup

---

## Teammate Prompt Template

Every spawned worker receives this structure in their prompt:

```
## Your Role
{role_description_from_template}

## Project Context
{conventions_from_claude_md}

## Your Files (YOU OWN THESE — only you write to them)
- {file1}
- {file2}

## Read-Only Files (reference, do NOT modify)
- {file3}

## Your Tasks
1. {task_with_clear_deliverable}
2. {task_with_clear_deliverable}

## Success Criteria
- {criterion_1}
- {criterion_2}

## Communication
- Mark tasks completed via TaskUpdate when done
- Send a brief summary to the lead via SendMessage
- If BLOCKED, message the lead immediately
- Do NOT broadcast — direct message only

## Constraints
- Do NOT modify files outside your ownership list
- Do NOT create new teams or sub-teams
- Stay focused on your assigned tasks
- If you need to change a shared interface, STOP and message the lead
```

---

## Create Template

1. Read `~/.claude/skills/agent-teams/references/templates/_meta-template.md`
2. Ask user: "What type of work?", "How many teammates (2-5)?", "Which coordination pattern?"
3. Generate template following meta-template structure
4. Save to `~/.claude/skills/agent-teams/references/templates/<name>.md`
5. Confirm creation and show usage

---

## Pre-Spawn Checklist

Verify before spawning:
- [ ] Task is decomposable into 2+ independent subtasks
- [ ] Subtasks work on DIFFERENT files
- [ ] File ownership map has ZERO overlaps
- [ ] Each teammate has clear tasks with deliverables
- [ ] User has confirmed the plan

## References

- Templates: `~/.claude/skills/agent-teams/references/templates/`
- Coordination patterns: `~/.claude/skills/agent-teams/references/coordination-patterns.md`
- Token economics: `~/.claude/skills/agent-teams/references/token-economics.md`
- Anti-patterns & checklists: `~/.claude/skills/agent-teams/references/team-architect-workflow.md`
- Skill: `~/.claude/skills/agent-teams/SKILL.md`
