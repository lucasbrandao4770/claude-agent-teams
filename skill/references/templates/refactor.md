---
name: refactor
description: Parallel safe refactoring across multiple modules with strict file ownership
pattern: parallel-workers
team_size: 2-4
best_for: Refactoring that touches 3+ modules where each module can be changed independently
token_estimate: ~600k-1.2M depending on number of modules
---

# Refactor Team

## When to Use

- Renaming/restructuring across 3+ modules
- Applying a new pattern consistently across the codebase
- Breaking a monolith into smaller modules
- Migrating from one library/API to another across multiple files

## When NOT to Use

- Refactoring a single module (single session is fine)
- Changes where modules depend on each other's internal implementation
- Refactoring that requires changing shared interfaces first

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Refactor Planner) | opus | general-purpose | Plan the refactor, partition modules, verify interfaces |
| Worker A | sonnet | general-purpose | Refactor module partition A |
| Worker B | sonnet | general-purpose | Refactor module partition B |
| Worker C (optional) | sonnet | general-purpose | Refactor module partition C |

Scale workers with the number of independent module partitions (1 worker per partition).

## File Ownership Guidelines

CRITICAL: This pattern lives or dies by clean file partitioning.

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | refactor-plan.md, interface contracts | All files |
| Worker A | All files in partition A | Interface contracts, partition B/C files |
| Worker B | All files in partition B | Interface contracts, partition A/C files |
| Worker C | All files in partition C | Interface contracts, partition A/B files |

### Partitioning Rules

1. **By directory:** Each worker owns a directory subtree (cleanest)
2. **By domain:** Each worker owns a domain's files (e.g., auth, billing, notifications)
3. **By layer:** Each worker owns a layer (models, services, API) - riskier, more interfaces

**Shared files (utils, config, types) go to the lead.** Workers must not modify shared files.

## Task Decomposition

### Lead Tasks
1. Analyze the codebase and identify the refactoring scope
2. Define the target state (what the code should look like after)
3. Partition files into non-overlapping groups
4. Define interface contracts (public APIs that must stay stable)
5. Assign partitions to workers
6. After workers complete: verify interfaces still match, run tests

### Worker Tasks (same for each, different files)
1. Read the refactor plan and interface contracts
2. Refactor ALL files in your partition following the plan
3. Maintain existing public interfaces (function signatures, exports)
4. If you need to change an interface, STOP and message the lead
5. Run tests for your partition if possible
6. Report completion with a list of changes made

## Teammate Prompt Template

### Worker Prompt
```
You are a refactoring worker. You own a specific set of files and must refactor them
according to the plan below.

REFACTOR PLAN:
{refactor_description}

YOUR FILE PARTITION (you OWN these - only you write to them):
{file_list}

INTERFACE CONTRACTS (do NOT change these signatures):
{interface_definitions}

READ-ONLY FILES (reference only, do NOT modify):
{read_only_list}

RULES:
1. Refactor only YOUR files. Do not touch files outside your partition.
2. Maintain all public interfaces (function signatures, class APIs, exports).
3. If you MUST change an interface, STOP and message the lead first.
4. Follow the refactor plan consistently.
5. Run tests if available for your partition.

When done:
1. List all files you changed in your task completion message
2. Note any interface changes you needed (should be none)
3. Report any issues or blockers to the lead
```

## Communication Flow

```text
    Lead (Opus)
    |
    +-- refactor plan + partition A files --> Worker A
    +-- refactor plan + partition B files --> Worker B
    +-- refactor plan + partition C files --> Worker C
    |
    Worker A --> completes partition A --> notifies Lead
    Worker B --> completes partition B --> notifies Lead
    Worker C --> completes partition C --> notifies Lead
    |
    Lead verifies interfaces + runs tests --> reports to user
```

## Success Criteria

- All partitions refactored according to plan
- No file ownership conflicts (zero overlap)
- All public interfaces preserved (or explicitly approved changes)
- Tests pass after refactoring
- Consistent patterns across all partitions

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Workers change shared interfaces | Prompt says STOP and ask lead |
| Unbalanced partitions (one worker gets 80% of files) | Lead measures file counts before assigning |
| Inconsistent refactoring styles | Lead provides a concrete example in the plan |
| Workers modify shared utility files | Lead owns all shared files |
| Tests break due to interface mismatch | Lead runs integration tests after all workers complete |

## Adaptation Notes

- **Python projects:** Partition by Python package (each worker owns a package directory). Shared `__init__.py` exports go to lead.
- **Full-stack projects:** Natural split: frontend worker, backend worker, shared types/API contract owned by lead
- **Data engineering:** Partition by pipeline stage or data domain
- **AgentSpec projects:** Workers can refactor agent files while lead maintains the SDD contracts
