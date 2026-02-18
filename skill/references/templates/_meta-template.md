# Team Template Format

Use this structure when creating new team templates via `/team create`.

## Required Frontmatter

```yaml
---
name: template-name-in-kebab-case
description: One-line description of what this team does
pattern: leader-specialist | parallel-workers | sequential-pipeline | council | watchdog
team_size: 2-5
best_for: Brief scenario description
token_estimate: e.g., "~800k for medium codebase"
---
```

## Required Sections

### When to Use
2-3 bullet points describing ideal scenarios.

### When NOT to Use
2-3 bullet points describing when this team is overkill or inappropriate.

### Team Composition

Table with columns: Role | Model | Subagent Type | Purpose

- Lead should always be `opus` model
- Workers should be `sonnet` unless trivial tasks (then `haiku`)
- Subagent types: `general-purpose` (full tools), `Explore` (read-only), `Plan` (read-only)

### File Ownership Guidelines

Describe how files should be partitioned. Include example table:

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|

CRITICAL: No two teammates should share write access to any file.

### Task Decomposition

Numbered tasks per role, each with a clear deliverable.

### Teammate Prompt Template

The exact prompt each teammate receives when spawned. Must include:
1. Role description
2. Files they OWN (write access)
3. Files they may READ (no write)
4. Specific tasks with success criteria
5. Communication instructions (report to lead via SendMessage)
6. Constraints (do not modify files outside ownership, do not create sub-teams)

### Communication Flow

ASCII diagram showing message flow between teammates.

### Success Criteria

Bullet list of what "done" looks like for this team.

### Common Pitfalls

Table: Pitfall | Mitigation

### Adaptation Notes

How `team-architect` should adjust this template for different project types:
- Python projects: ...
- Full-stack projects: ...
- Research projects: ...
- Other: ...

## Example: Minimal Template

```markdown
---
name: example-pair
description: Simple pair programming with code and test writers
pattern: parallel-workers
team_size: 2
best_for: Adding a feature with corresponding tests
token_estimate: ~400k
---

# Pair Programming Team

## When to Use
- Adding a new feature that needs unit tests
- Feature and tests can be written independently
- Clear interface between implementation and tests

## When NOT to Use
- Feature is too small for parallelization
- Tests depend on seeing the implementation first

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead | opus | general-purpose | Coordinate, define interface contract |
| Implementer | sonnet | general-purpose | Write the feature code |
| Test Writer | sonnet | general-purpose | Write tests against the interface |

## File Ownership Guidelines

| Teammate | Owns | Reads |
|----------|------|-------|
| Lead | interface spec (shared doc) | all files |
| Implementer | src/ feature files | interface spec |
| Test Writer | tests/ files | interface spec, src/ (read-only) |

## Task Decomposition

### Lead
1. Define the interface contract (function signatures, types, behavior)
2. Share contract with both workers
3. Synthesize results and verify tests pass against implementation

### Implementer
1. Implement the feature following the interface contract
2. Report completion to lead

### Test Writer
1. Write unit tests against the interface contract
2. Report completion to lead

## Success Criteria
- Implementation matches the interface contract
- Tests pass against the implementation
- No file ownership conflicts
```

**Note:** This is a minimal example. Production templates should include ALL required sections listed above, including Teammate Prompt Template, Communication Flow, and Adaptation Notes.
