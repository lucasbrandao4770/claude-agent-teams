---
name: oss-kickstart
description: Create a new open-source project from scratch with docs, CI/CD, and conventions
pattern: leader-specialist
team_size: 3
best_for: Starting a brand new open-source project from zero
token_estimate: ~800k-1.2M
---

# OSS Kickstart Team

## When to Use

- Starting a brand new open-source project from zero
- Need full project scaffold: repo, docs, CI/CD pipeline, coding standards
- Want a project that's ready for contributors from day one

## When NOT to Use

- Project already exists and just needs features (use `oss-sprint`)
- Quick personal script or throwaway prototype
- Private/internal project that won't have contributors

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Orchestrator) | opus | general-purpose | Coordinate, review output, final commits, push |
| Doc Writer | sonnet | general-purpose | README, CONTRIBUTING, CODE_OF_CONDUCT, issue/PR templates, ROADMAP |
| CI/CD Engineer | sonnet | general-purpose | GitHub Actions CI + CD pipelines (lint, test, release) |
| Conventions Writer | sonnet | general-purpose | CLAUDE.md, coding standards, PR review checklist |

## Phased Execution

**This template uses a phased approach: subagent setup first, then team spawn.**

### Phase 1: Setup via Sequential Foreground Subagents

Before spawning the team, the Lead delegates heavy setup work to subagents to keep its context clean.

**IMPORTANT: These run SEQUENTIALLY, not in parallel.** The GitHub Configurator depends on the repo existing (created by the Scaffolder). Only use parallel subagents when tasks are truly independent.

**Pre-check:** Before running any subagent, verify `gh auth status` succeeds. If not, tell the user to run `/oss setup` first and STOP.

#### Subagent 1 (first): "Repository Scaffolder"
```
Tasks:
  1. Verify: gh auth status (FAIL → tell user to run /oss setup, STOP)
  2. Verify: gh auth setup-git (ensure git can push via gh credentials)
  3. Verify: gh auth status shows 'workflow' scope (FAIL → run: gh auth refresh -h github.com -s workflow)
  4. gh repo create --public <name> --clone (or use existing repo)
  4. Create project skeleton based on tech stack:
     - Python: pyproject.toml, src/<pkg>/__init__.py, tests/, .gitignore
     - Node: package.json, src/index.ts, tests/, .gitignore
     - Generic: README.md placeholder, LICENSE, .gitignore
  5. Create LICENSE file (MIT by default, ask user if different)
  6. git add -A && git commit -m "chore: initial scaffold"
  7. git push -u origin main
  Return: project structure summary (tree output)
```

#### Subagent 2 (after Scaffolder completes): "GitHub Configurator"
```
Tasks:
  1. Create default labels via gh:
     gh label create "ready" --color 0E8A16 --description "Ready for development"
     gh label create "in-progress" --color 1D76DB --description "Currently being worked on"
     gh label create "needs-review" --color FBCA04 --description "Needs code review"
     gh label create "bug" --color D73A4A --description "Something isn't working" --force
     gh label create "feature" --color A2EEEF --description "New feature request"
     gh label create "docs" --color 0075CA --description "Documentation improvements"
     gh label create "chore" --color BFD4F2 --description "Maintenance tasks"
  2. Create initial milestone: gh api -X POST repos/{owner}/{repo}/milestones -f title="v0.1.0" -f description="Initial release"
  3. Configure repo settings via gh api (use -F for booleans):
     - Issues enabled
     - Wiki disabled
     - Discussions disabled (keep it simple)
     - Allow squash merge (prefer), disable rebase/merge commit
     - Delete branch on merge
  Return: configuration summary
```

**Lead receives summaries from both subagents, NOT execution details.**

### Phase 2: Team Spawn (Parallel Creative Work)

After Phase 1 completes, the Lead spawns 3 workers for parallel creative work.

### Phase 3: Cleanup

After all workers finish:
1. Lead reviews all output for consistency
2. Lead fixes cross-references (e.g., test commands in README match CI config)
3. Lead commits in ATOMIC commits grouped by author/purpose — NOT one monolith:
   - `feat: add CI/CD pipelines` (ci-cd-engineer's files)
   - `docs: add project conventions and guides` (conventions-writer's files)
   - `docs: add README and CONTRIBUTING` (doc-writer's files)
   - `docs: add code of conduct, issue templates, roadmap` (remaining docs)
4. Lead pushes to main
5. Lead creates seed issues for initial development work
6. Lead creates v0.1.0 milestone assignments
7. Shutdown workers, cleanup team

**IMPORTANT:** If `git push` fails with "workflow scope" error, run `gh auth refresh -h github.com -s workflow` and retry.

## File Ownership Guidelines

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | Seed issues, milestone, final commit | All files |
| Doc Writer | README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, .github/ISSUE_TEMPLATE/, .github/PULL_REQUEST_TEMPLATE.md, ROADMAP.md | Project scaffold, conventions |
| CI/CD Engineer | .github/workflows/ci.yml, .github/workflows/release.yml | Project scaffold (for test/lint commands) |
| Conventions Writer | .claude/CLAUDE.md (project), docs/coding-standards.md, docs/pr-review-checklist.md | Project scaffold, CI config |

## Task Decomposition

### Lead Tasks
1. Gather project info from user: name, description, tech stack, license preference
2. Run Phase 1 subagents (scaffold + GitHub config)
3. Create project brief for all workers (shared context)
4. Spawn workers with brief + specific assignments
5. Review all output for consistency
6. Fix cross-references between docs, CI, and conventions
7. Commit, push, create seed issues

### Doc Writer Tasks
1. Read project brief and scaffold structure
2. Write README.md: project name, badges, description, quickstart, usage, contributing link, license
3. Write CONTRIBUTING.md: how to set up dev environment, branch naming, commit format, PR process
4. Write CODE_OF_CONDUCT.md: Contributor Covenant (standard)
5. Write .github/ISSUE_TEMPLATE/bug.md: bug report form
6. Write .github/ISSUE_TEMPLATE/feature.md: feature request form
7. Write .github/PULL_REQUEST_TEMPLATE.md: PR checklist
8. Write ROADMAP.md: v0.1.0 goals, future vision
9. Message CI/CD Engineer: "What are the test and lint commands?" (for README accuracy)
10. Message Conventions Writer: "What's the commit format?" (for CONTRIBUTING accuracy)

### CI/CD Engineer Tasks
1. Read project brief and scaffold structure
2. Write .github/workflows/ci.yml:
   - Triggers: on PR to main
   - Steps: checkout, setup language, install deps, lint, format check, test, type-check
   - Matrix: test on multiple OS/versions if applicable
3. Write .github/workflows/release.yml:
   - Triggers: on push to main (merge), manual dispatch
   - Steps: semantic-release → version bump → CHANGELOG → GitHub Release
   - Conventional commits: feat → minor, fix → patch, BREAKING CHANGE → major
4. Reply to Doc Writer with test/lint commands
5. Message Conventions Writer: "CI requires these checks: [list]" (for CLAUDE.md accuracy)

### Conventions Writer Tasks
1. Read project brief and scaffold structure
2. Write .claude/CLAUDE.md for the project:
   - Project description and architecture
   - File structure explanation
   - Coding standards (naming, formatting, imports)
   - Testing conventions
   - Git workflow (branch naming, commit format, PR process)
   - CI/CD pipeline explanation
3. Write docs/coding-standards.md: detailed style guide
4. Write docs/pr-review-checklist.md: what reviewers should check
5. Reply to Doc Writer with commit format conventions
6. Reply to CI/CD Engineer confirming CI requirements match conventions

## Teammate Prompt Template

### Doc Writer Prompt
```
You are the Documentation Writer for a new open-source project.

PROJECT BRIEF:
{project_brief}

YOUR FILES (you own these — only you write to them):
- README.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- .github/ISSUE_TEMPLATE/bug.md
- .github/ISSUE_TEMPLATE/feature.md
- .github/PULL_REQUEST_TEMPLATE.md
- ROADMAP.md

READ-ONLY (reference, do NOT modify):
- All scaffold files (pyproject.toml, package.json, src/, etc.)
- .github/workflows/ (CI/CD Engineer owns these)
- .claude/CLAUDE.md, docs/ standards (Conventions Writer owns these)

INSTRUCTIONS:
1. Write professional, welcoming documentation
2. README should have: badges (CI, license), clear quickstart, usage examples
3. CONTRIBUTING should reference the exact dev setup, branch naming, and commit format
4. Issue templates should be concise but capture necessary info
5. ROADMAP should outline v0.1.0 goals and future vision
6. IMPORTANT: Ask the CI/CD Engineer for the exact test/lint commands before finalizing README
7. IMPORTANT: Ask the Conventions Writer for the commit format before finalizing CONTRIBUTING

COMMUNICATION:
- Message "ci-cd-engineer": ask for test/lint commands
- Message "conventions-writer": ask for commit format and branch naming
- When done, mark tasks completed and message the lead with a summary
- If BLOCKED, message the lead immediately

CONSTRAINTS:
- Do NOT modify files outside your ownership list
- Do NOT create new teams or sub-teams
- Stay focused on documentation — leave code conventions to the Conventions Writer
```

### CI/CD Engineer Prompt
```
You are the CI/CD Engineer for a new open-source project.

PROJECT BRIEF:
{project_brief}

YOUR FILES (you own these — only you write to them):
- .github/workflows/ci.yml
- .github/workflows/release.yml

READ-ONLY (reference, do NOT modify):
- All scaffold files (to determine language, test runner, linter)
- README.md, CONTRIBUTING.md (Doc Writer owns these)
- .claude/CLAUDE.md, docs/ (Conventions Writer owns these)

INSTRUCTIONS:
1. CI pipeline (.github/workflows/ci.yml):
   - Trigger on pull_request to main
   - Steps: checkout → setup language → install deps → lint → format → test → type-check
   - Use caching for dependencies
   - Fail fast on lint/format errors

2. CD pipeline (.github/workflows/release.yml):
   - Trigger on push to main (merged PRs) + manual workflow_dispatch
   - Use semantic-release or equivalent for the language:
     - Python: python-semantic-release
     - Node: semantic-release
   - Auto-generate CHANGELOG.md
   - Create GitHub Release with auto-generated notes
   - Publish to package registry if applicable (PyPI/npm)
   - Use conventional commits: feat → minor, fix → patch, BREAKING CHANGE → major

3. Reply to Doc Writer when they ask for test/lint commands
4. Share CI requirements with Conventions Writer for CLAUDE.md accuracy

COMMUNICATION:
- Reply to "doc-writer" with test/lint commands when asked
- Message "conventions-writer": share what CI checks for
- When done, mark tasks completed and message the lead with a summary
- If BLOCKED, message the lead immediately

CONSTRAINTS:
- Do NOT modify files outside your ownership list
- Do NOT create new teams or sub-teams
- Do NOT add secrets — use placeholder names (e.g., ${{ secrets.PYPI_TOKEN }})
- Keep pipelines simple and fast
```

### Conventions Writer Prompt
```
You are the Conventions Writer for a new open-source project.

PROJECT BRIEF:
{project_brief}

YOUR FILES (you own these — only you write to them):
- .claude/CLAUDE.md (project-level Claude Code instructions)
- docs/coding-standards.md
- docs/pr-review-checklist.md

READ-ONLY (reference, do NOT modify):
- All scaffold files (to understand project structure)
- .github/workflows/ (CI/CD Engineer owns these)
- README.md, CONTRIBUTING.md (Doc Writer owns these)

INSTRUCTIONS:
1. CLAUDE.md should include:
   - Project description and purpose
   - Architecture overview
   - File structure with explanations
   - Coding standards summary (formatting, naming, imports)
   - Testing conventions (how to run, what framework, coverage expectations)
   - Git workflow (branch naming: <type>/<issue>-<desc>, commit format: conventional)
   - CI/CD explanation (what runs on PR, what runs on merge)
   - Key commands cheat sheet

2. docs/coding-standards.md:
   - Language-specific style guide
   - Naming conventions (files, functions, classes, variables)
   - Import ordering
   - Error handling patterns
   - Documentation requirements

3. docs/pr-review-checklist.md:
   - Code quality checks
   - Test coverage requirements
   - Security considerations
   - Documentation updated
   - CI passes

4. Reply to Doc Writer with commit format and branch naming when asked
5. Confirm CI requirements match conventions after hearing from CI/CD Engineer

COMMUNICATION:
- Reply to "doc-writer" with commit format and branch naming when asked
- Reply to "ci-cd-engineer" confirming conventions match CI requirements
- When done, mark tasks completed and message the lead with a summary
- If BLOCKED, message the lead immediately

CONSTRAINTS:
- Do NOT modify files outside your ownership list
- Do NOT create new teams or sub-teams
- Make CLAUDE.md comprehensive but concise — this is what future AI sessions will read
```

## Communication Flow

```text
    Lead (Opus)
    |
    |-- Phase 1: Subagents (parallel)
    |   +-- Scaffolder → creates repo skeleton → returns summary
    |   +-- Configurator → sets up GitHub → returns summary
    |
    |-- Phase 2: Workers (parallel with cross-talk)
    |   +-- project brief --> Doc Writer
    |   +-- project brief --> CI/CD Engineer
    |   +-- project brief --> Conventions Writer
    |   |
    |   Doc Writer <--> CI/CD Engineer: share test/lint commands
    |   Doc Writer <--> Conventions Writer: share commit format, branch naming
    |   CI/CD Engineer <--> Conventions Writer: share CI requirements
    |   |
    |   All 3 report completion to Lead
    |
    |-- Phase 3: Cleanup
    |   Lead reviews, fixes inconsistencies, commits, pushes
    |   Lead creates seed issues + milestone
```

## Success Criteria

- GitHub repository created with proper scaffold
- README has badges, quickstart, and accurate commands
- CONTRIBUTING references the actual commit format and branch naming
- CI pipeline runs lint + test + type-check on PRs
- CD pipeline auto-releases on merge to main with CHANGELOG
- CLAUDE.md accurately describes the project for future AI sessions
- Labels and milestone created on GitHub
- Seed issues created for v0.1.0 work
- Branch protection configured on main
- No file ownership conflicts between workers

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Docs reference wrong test commands | Doc Writer asks CI/CD Engineer before finalizing |
| CLAUDE.md doesn't match actual CI config | Conventions Writer confirms with CI/CD Engineer |
| README badges point to wrong workflows | Lead reviews cross-references in Phase 3 |
| CD pipeline has wrong package registry | CI/CD Engineer reads scaffold to detect language |
| Seed issues are too vague | Lead writes specific, actionable issues with acceptance criteria |
| Branch protection not set | GitHub Configurator subagent handles this in Phase 1 |

## Adaptation Notes

- **Python projects:** Scaffolder creates pyproject.toml with ruff, pytest, mypy. CI uses `pip install -e ".[dev]"`. CD uses python-semantic-release.
- **Node/TypeScript projects:** Scaffolder creates package.json with eslint, vitest/jest. CI uses `npm ci`. CD uses semantic-release.
- **Monorepo:** Adjust CI to detect changed packages. Each package gets its own release config.
- **Rust projects:** Scaffolder creates Cargo.toml. CI uses cargo clippy + cargo test. CD uses cargo-release.
- **No CD needed:** Skip release.yml. Some projects are libraries distributed differently.
