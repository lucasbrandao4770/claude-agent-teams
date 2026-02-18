# Creating Custom Templates

This guide walks you through creating your own team templates for specific workflows.

## Before You Start

Read the meta-template that defines the format all templates must follow:

```text
skill/references/templates/_meta-template.md
```

Study at least one existing template (e.g., `code-review.md` or `oss-sprint.md`) to see the format in action.

## Template Structure

Every template is a single Markdown file with YAML frontmatter followed by specific sections.

### Frontmatter (Required)

```yaml
---
name: my-template
description: One-line description of what this team does
pattern: leader-specialist
team_size: 3
best_for: Brief scenario description
token_estimate: ~800k for medium project
---
```

| Field | Description | Valid Values |
|-------|-------------|-------------|
| `name` | Kebab-case identifier | `my-template`, `api-migration` |
| `description` | One-line summary | Free text |
| `pattern` | Coordination pattern | `leader-specialist`, `parallel-workers`, `sequential-pipeline`, `council`, `watchdog` |
| `team_size` | Number of teammates (including lead) | 2-5 |
| `best_for` | When to use this template | Free text |
| `token_estimate` | Approximate total token cost | e.g., `~800k`, `~1.2M` |

### Required Sections

Your template must include these sections in order:

#### 1. When to Use

2-3 bullet points describing ideal scenarios for this team.

```markdown
## When to Use

- Working on multiple independent API endpoints simultaneously
- Each endpoint has a clear schema and can be tested independently
- Want parallel implementation with quality feedback loops
```

#### 2. When NOT to Use

2-3 bullet points describing when this team is overkill or inappropriate.

```markdown
## When NOT to Use

- Single endpoint change (a regular session is faster)
- Endpoints share complex business logic (too much cross-dependency)
```

#### 3. Team Composition

A table listing every role, model, subagent type, and purpose.

```markdown
## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead | opus | general-purpose | Coordinate, define contracts, merge |
| API Developer A | sonnet | general-purpose | Implement endpoints A, B |
| API Developer B | sonnet | general-purpose | Implement endpoints C, D |
| Test Writer | sonnet | general-purpose | Write integration tests |
```

Model choices:
- `opus` -- for the lead and roles requiring deep reasoning (architecture, complex review)
- `sonnet` -- for execution workers (implementation, testing, standard review)
- `haiku` -- for trivial tasks (formatting, simple validation)

#### 4. File Ownership Guidelines

A table mapping each teammate to the files they can write and the files they can only read.

```markdown
## File Ownership Guidelines

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | API contracts, shared types | All files |
| API Developer A | src/routes/a.ts, src/routes/b.ts | Contracts, shared types |
| API Developer B | src/routes/c.ts, src/routes/d.ts | Contracts, shared types |
| Test Writer | tests/ | All source files |
```

**Critical rule:** No two teammates may share write access to any file. If you cannot avoid it, the file must stay with the lead.

#### 5. Task Decomposition

Numbered tasks for each role, with clear deliverables.

```markdown
## Task Decomposition

### Lead Tasks
1. Define API contracts (request/response schemas) for all endpoints
2. Share contracts with developers and test writer
3. Review all implementations for consistency
4. Merge results and run full test suite

### API Developer A Tasks
1. Implement endpoints A and B following the contracts
2. Write unit tests for each endpoint
3. Message QA when ready for testing
```

#### 6. Teammate Prompt Template

The exact prompt each worker receives when spawned. Must include role description, owned files, read-only files, specific tasks, communication instructions, and constraints.

```markdown
## Teammate Prompt Template

### API Developer A Prompt

\```
You are an API developer working on endpoints A and B.

YOUR FILES (you own these):
- src/routes/a.ts
- src/routes/b.ts

READ-ONLY (reference, do NOT modify):
- src/contracts/ (API contracts defined by lead)

TASKS:
1. Implement endpoint A per the contract
2. Implement endpoint B per the contract
3. Write unit tests for both endpoints
4. Message the lead when complete

COMMUNICATION:
- Message the lead with progress updates
- If BLOCKED, message the lead immediately
- Do NOT broadcast

CONSTRAINTS:
- Do NOT modify files outside your ownership list
- Do NOT create new teams or sub-teams
- Follow project conventions
\```
```

#### 7. Communication Flow

An ASCII diagram showing how messages flow between teammates.

```markdown
## Communication Flow

\```text
    Lead (Opus)
    |
    +-- contracts --> API Dev A
    +-- contracts --> API Dev B
    +-- contracts --> Test Writer
    |
    API Dev A --> "ready" --> Lead
    API Dev B --> "ready" --> Lead
    |
    Lead triggers Test Writer --> writes tests --> reports to Lead
\```
```

#### 8. Success Criteria

Bullet list of what "done" looks like.

```markdown
## Success Criteria

- All endpoints implemented and matching contracts
- Unit tests pass for every endpoint
- Integration tests pass
- No file ownership conflicts
```

#### 9. Common Pitfalls

A table of known problems and mitigations.

```markdown
## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Developers diverge from contracts | Lead reviews for consistency |
| Test writer starts before devs finish | Use blockedBy to sequence |
```

#### 10. Adaptation Notes

How the template should be adjusted for different project types.

```markdown
## Adaptation Notes

- **Python projects:** Use FastAPI router files as ownership boundaries
- **Node projects:** Use Express router files
- **Monorepo:** Each developer owns a different package
```

## File Ownership Design

File ownership is the most critical design decision in a template. Get this wrong and teammates will create merge conflicts, undo each other's work, or waste tokens retrying.

### Principles

1. **Partition by directory or module.** The cleanest splits follow the project's directory structure.
2. **Shared files stay with the lead.** Configuration files, type definitions, and utilities that multiple workers need should be owned by the lead.
3. **Read access is free.** Any teammate can read any file. Only write access needs partitioning.
4. **Branch isolation.** For sprint-style templates, put each developer on a separate branch. This eliminates file ownership issues at the cost of sequential merging.

### Red Flags

- Two workers assigned to the same directory
- A "shared utils" file that multiple workers need to modify
- No explicit ownership table in the template

## Communication Flow Design

Good communication flow minimizes unnecessary messages and avoids bottlenecks.

### Guidelines

- Workers should message the lead on completion, not on every intermediate step.
- Direct messages between workers are fine for coordination (e.g., "I finished the contract, you can start testing").
- Never use broadcasts for routine updates.
- QA/Review loops should go directly between developer and reviewer, with the lead only notified on pass/fail.

## Testing Your Template

### Dry Run

Before using a new template for real work, always preview it:

```text
/team my-template --dry
```

This shows the full plan (roles, file ownership, tasks) without spawning any teammates. Check for:

- File ownership overlaps
- Missing tasks or unclear deliverables
- Communication flow that could create bottlenecks
- Reasonable token estimate

### First Real Run

For your first real run, choose a small project or a low-stakes task. Watch for:

- Teammates writing to files they do not own
- Communication bottlenecks (lead overwhelmed, workers idle)
- Task descriptions that are too vague (workers waste tokens exploring)

## Saving Your Template

Templates are stored in `skill/references/templates/`. Save your template as a Markdown file using the template name as the filename:

```text
skill/references/templates/my-template.md
```

The template will appear in the `/team` catalog automatically.

## Submitting via PR

To contribute your template to the project:

1. Create a branch: `feat/template-my-template`
2. Add your template file to `skill/references/templates/`
3. Update the template catalog table in all locations where it appears:
   - `skill/SKILL.md` -- the skill's decision framework (used by Claude at runtime)
   - `commands/team/team.md` -- the `/team` command catalog shown to users
   - `README.md` -- the public-facing template catalog in the repository root
4. Open a PR targeting `main`
5. CI will check your markdown for lint errors and broken links
6. Squash merge after approval
