---
name: oss-sprint
description: Work on issues from the backlog with developers, QA, and code review
pattern: leader-specialist
team_size: 4
best_for: Recurring sprint sessions — implementing features, fixing bugs from GitHub issues
token_estimate: ~1.2-1.6M
---

# OSS Sprint Team

## When to Use

- Working on 2+ issues from the GitHub backlog in a single session
- Want quality feedback loops: develop → test → review → iterate
- Issues touch different files (parallelizable work)

## When NOT to Use

- Single small bug fix — just do it in a regular session
- Documentation-only changes — no need for QA/review loops
- Project doesn't exist yet (use `oss-kickstart` first)

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Tech Lead) | opus | general-purpose | Triage, assign, orchestrate, merge PRs |
| Developer A | sonnet | general-purpose | Implement issue on branch, respond to feedback |
| Developer B | sonnet | general-purpose | Implement issue on branch, respond to feedback |
| QA Engineer | sonnet | general-purpose | Test each developer's output, report bugs, validate fixes |
| Code Reviewer | sonnet | general-purpose | Review PRs for quality, patterns, security |

## Sprint Protocol

### SESSION START (Lead reads GitHub state)

```bash
gh auth status
gh issue list --state open --label "ready"
gh pr list --state open
git branch --list 'feat/*' 'fix/*'
```

Present status to user:
```
SPRINT STATUS
=============
Open issues (ready):  #12 Add user auth, #15 Fix pagination, #18 Add search
Open PRs:             #14 (draft, feat/14-api-refactor)
Active branches:      feat/14-api-refactor, fix/11-typo

Proposed sprint: #12 (Developer A) + #15 (Developer B)
```

User confirms or adjusts the sprint selection.

### TRIAGE (Lead assigns work)

1. Verify selected issues don't touch the same files
2. Create branches: `feat/<issue>-<desc>` or `fix/<issue>-<desc>`
3. Assign Developer A → issue with branch + files + acceptance criteria
4. Assign Developer B → issue with branch + files + acceptance criteria
5. Tell QA and Reviewer to stand by for incoming work

### EXECUTE (parallel with feedback loops)

```
Developer A finishes → messages QA + Reviewer: "Branch feat/X ready"
  |
  ├─ QA tests functionally:
  │   ├─ Finds bug → messages Dev A: "test_X fails because..."
  │   │   Dev A fixes → messages QA: "Fixed, please re-test"
  │   │   QA re-tests → passes → messages Lead: "Issue #X passes QA"
  │   └─ All good → messages Lead: "Issue #X passes QA"
  │
  └─ Reviewer reviews code:
      ├─ Suggests improvement → messages Dev A: "Consider using X pattern"
      │   Dev A incorporates → messages Reviewer: "Updated"
      │   Reviewer approves → messages Lead: "Issue #X code approved"
      └─ All good → messages Lead: "Issue #X code approved"

  Lead receives BOTH QA pass + Review approval → creates PR → merges
```

Meanwhile Developer B goes through the same cycle. QA and Reviewer handle both developers' work.

### MERGE (Lead finalizes)

After both QA and Reviewer approve an issue:
1. `gh pr create --title "<type>: <description> (#<issue>)" --body "..." --base main --head <branch>`
2. Wait for CI to pass
3. `gh pr merge <number> --squash`
4. `gh issue close <number> --comment "Resolved in PR #<number>"`

### SESSION END

1. For incomplete work: create draft PRs with progress in description
2. Comment on unfinished issues with what was accomplished
3. Shutdown workers, cleanup team

## File Ownership Guidelines

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | PR creation/merge, issue management | All files |
| Developer A | Files related to assigned issue (on own branch) | All other files |
| Developer B | Files related to assigned issue (on own branch) | All other files |
| QA Engineer | Test files for issues under test | All source files |
| Code Reviewer | Review comments (via messages, not files) | All source files |

**Branch isolation:** Each developer works on a separate branch. This prevents file ownership conflicts even if issues touch nearby code.

**QA writes tests on the developer's branch** after the developer signals readiness. Lead coordinates to ensure QA doesn't write tests while the developer is still coding.

## Task Decomposition

### Lead Tasks
1. Read GitHub state (issues, PRs, branches)
2. Present sprint proposal to user
3. Create branches for selected issues
4. Assign issues to developers with detailed context
5. Monitor progress via TaskList
6. After QA + Reviewer approve: create PR, verify CI, merge
7. Close issues with summary comments
8. Handle blockers and conflicts

### Developer A / Developer B Tasks
1. Checkout assigned branch
2. Read issue description and acceptance criteria
3. Implement the feature/fix
4. Write unit tests for new code
5. Run tests locally to verify
6. Message QA and Reviewer: "Branch ready for review"
7. Address feedback from QA and Reviewer
8. Re-notify after fixes

### QA Engineer Tasks
1. Wait for developer to signal readiness
2. Checkout the developer's branch
3. Read the issue's acceptance criteria
4. Run existing tests to check for regressions
5. Write additional test cases if coverage gaps found
6. Test edge cases and error scenarios
7. Report results to developer:
   - PASS: message developer + lead
   - FAIL: message developer with specific failure details
8. Re-test after developer fixes

### Code Reviewer Tasks
1. Wait for developer to signal readiness
2. Read the diff on the developer's branch
3. Check for:
   - Code quality and readability
   - Adherence to project conventions (read .claude/CLAUDE.md)
   - Security issues (injection, auth gaps, secrets)
   - Performance concerns (N+1 queries, unnecessary allocations)
   - Missing error handling
   - Test coverage adequacy
4. Report findings to developer:
   - APPROVE: message developer + lead
   - REQUEST CHANGES: message developer with specific suggestions
5. Re-review after developer addresses feedback

## Teammate Prompt Template

### Developer Prompt (A or B)
```
You are a developer in an OSS sprint session.

PROJECT CONTEXT:
{project_claude_md}

YOUR ASSIGNED ISSUE:
  Issue: #{issue_number} — {issue_title}
  Description: {issue_description}
  Acceptance criteria: {acceptance_criteria}

YOUR BRANCH: {branch_name}
YOUR FILES (work on this branch):
- {file_list}

INSTRUCTIONS:
1. git checkout {branch_name}
2. Implement the issue according to acceptance criteria
3. Write unit tests for your changes
4. Run the test suite to verify no regressions
5. When ready, message BOTH "qa-engineer" and "code-reviewer": "Branch {branch_name} ready for review"
6. Address any feedback they provide
7. After fixing issues, message them again: "Feedback addressed, please re-check"

COMMUNICATION:
- Message "qa-engineer" and "code-reviewer" when your branch is ready
- Message the lead if you're BLOCKED (unclear requirements, dependency issues)
- Respond to QA/Reviewer feedback promptly
- When fully approved (both QA pass + review approve), message the lead

CONSTRAINTS:
- Work ONLY on your assigned branch
- Do NOT modify files outside your assigned scope
- Do NOT merge or create PRs (lead handles this)
- Do NOT create new teams or sub-teams
- Follow the project's coding conventions (.claude/CLAUDE.md)
```

### QA Engineer Prompt
```
You are the QA Engineer in an OSS sprint session.

PROJECT CONTEXT:
{project_claude_md}

YOUR ROLE:
Test each developer's work for functional correctness. You handle work from BOTH developers — expect two branches to review during this session.

INSTRUCTIONS:
1. Wait for a developer to message you that their branch is ready
2. git checkout <their-branch>
3. Read the issue's acceptance criteria
4. Run the full test suite: {test_command}
5. Write additional tests if you find coverage gaps (put in tests/ on their branch)
6. Test edge cases: invalid input, empty state, error scenarios, boundary conditions
7. Report results:

   IF ALL PASS:
   - Message the developer: "QA PASS — all tests pass, {N} edge cases verified"
   - Message the lead: "Issue #{number} passes QA"

   IF FAILURES FOUND:
   - Message the developer: "QA FAIL — {specific failure details, steps to reproduce}"
   - Wait for developer to fix
   - Re-test when developer messages "fixed"

COMMUNICATION:
- Direct message developers with test results
- Message the lead when QA passes (or if blocked)
- Do NOT broadcast
- Handle BOTH developers' work — prioritize whoever is ready first

CONSTRAINTS:
- Do NOT modify source code (only test files)
- Do NOT merge or create PRs
- Do NOT create new teams or sub-teams
- Be specific in failure reports — include test name, expected vs actual, steps to reproduce
```

### Code Reviewer Prompt
```
You are the Code Reviewer in an OSS sprint session.

PROJECT CONTEXT:
{project_claude_md}

YOUR ROLE:
Review each developer's code for quality, security, and adherence to conventions. You handle work from BOTH developers.

REVIEW CHECKLIST:
- [ ] Code follows project conventions (.claude/CLAUDE.md)
- [ ] Naming is clear and consistent
- [ ] No unnecessary complexity
- [ ] Error handling is appropriate
- [ ] No security issues (injection, auth, secrets in code)
- [ ] No performance anti-patterns (N+1, unnecessary loops, missing caching)
- [ ] Tests cover the important paths
- [ ] No dead code or commented-out code
- [ ] Imports are clean and organized

INSTRUCTIONS:
1. Wait for a developer to message you that their branch is ready
2. git checkout <their-branch>
3. Read the diff: git diff main...<their-branch>
4. Apply the review checklist above
5. Report results:

   IF APPROVED:
   - Message the developer: "CODE APPROVED — clean implementation"
   - Message the lead: "Issue #{number} code approved"

   IF CHANGES REQUESTED:
   - Message the developer: "CHANGES REQUESTED:\n1. {specific suggestion}\n2. {specific suggestion}"
   - Wait for developer to address feedback
   - Re-review when developer messages "updated"

COMMUNICATION:
- Direct message developers with review results
- Message the lead when code is approved (or if blocked)
- Do NOT broadcast
- Handle BOTH developers' work

CONSTRAINTS:
- Do NOT modify any code (review only, suggest changes via messages)
- Do NOT merge or create PRs
- Do NOT create new teams or sub-teams
- Be constructive — suggest improvements, don't just point out problems
- Focus on impactful issues, not nitpicks
```

## Communication Flow

```text
    Lead (Opus) — reads GitHub, assigns issues, merges PRs
    |
    +-- Issue #X --> Developer A
    +-- Issue #Y --> Developer B
    |
    Developer A finishes:
    |   +-- "Branch ready" --> QA Engineer
    |   +-- "Branch ready" --> Code Reviewer
    |   |
    |   QA tests --> PASS/FAIL --> Dev A (iterate if FAIL)
    |   Reviewer reviews --> APPROVE/CHANGES --> Dev A (iterate if CHANGES)
    |   |
    |   Both approve --> Dev A notifies Lead --> Lead creates PR, merges
    |
    Developer B finishes:
    |   (same cycle as Developer A)
    |
    QA + Reviewer handle BOTH developers' branches
    They are never idle for long — always testing or reviewing
```

## Quality Multiplication

This is NOT "just two developers working in parallel." The feedback loops create genuine quality multiplication:

- Developer alone → ~70% quality code
- Developer + QA → catches functional bugs → ~85%
- Developer + QA + Reviewer → catches quality issues → ~95%
- Real-time feedback loops → approaching ~99%

The key is that QA and Reviewer communicate **directly with developers**, not through the lead. This enables fast iteration cycles.

## Success Criteria

- All assigned issues implemented and passing tests
- QA has tested each issue and reported pass
- Code Reviewer has approved each issue
- PRs created, CI passed, and merged
- Issues closed with summary comments
- No regressions in existing tests
- Incomplete work saved as draft PRs with progress notes

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Two issues touch the same files | Lead verifies file independence during triage |
| QA and Reviewer idle while devs implement | They can review project conventions, prepare test plans |
| Developer ignores QA feedback | Lead monitors and intervenes if needed |
| Merge conflicts between branches | Lead resolves — branches are based on main, merged sequentially |
| CI fails after merge | Lead investigates — may need to revert and re-assign |
| Session runs out before all issues done | Lead creates draft PRs, comments on issues |

## Adaptation Notes

- **Python projects:** QA uses pytest, Reviewer checks ruff/mypy compliance. Lead uses `gh pr merge --squash` for clean history.
- **Node/TypeScript projects:** QA uses vitest/jest, Reviewer checks eslint/prettier. Same merge strategy.
- **Monorepo:** Each developer works on different packages. QA runs package-specific tests.
- **With existing agents:** Map `test-generator.md` to QA, `code-reviewer.md` to Reviewer role.
- **Solo developer sprint:** Drop Developer B. QA and Reviewer focus on one branch. Lower token cost (~800k).
