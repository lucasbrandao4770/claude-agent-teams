---
name: code-review
description: Multi-perspective code review with security, performance, and architecture lenses
pattern: council
team_size: 3
best_for: Thorough review of PRs or code changes from multiple angles simultaneously
token_estimate: ~800k for medium PR (50-200 lines changed)
---

# Code Review Team

## When to Use

- Reviewing a PR or set of changes that touch multiple concerns
- Pre-merge review where quality matters more than speed
- Code audit of unfamiliar or critical sections

## When NOT to Use

- Small changes (typo fix, single-line bug fix) - single session review is sufficient
- Only one concern matters (just security, just performance) - use a single subagent
- Reviewing your own code during development - just use the code-quality skill

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Synthesizer) | opus | general-purpose | Collect findings, deduplicate, write final report |
| Security Reviewer | sonnet | general-purpose | Focus on vulnerabilities, auth, injection, OWASP |
| Performance Reviewer | sonnet | general-purpose | Focus on complexity, memory, queries, caching |
| Architecture Reviewer | sonnet | general-purpose | Focus on patterns, coupling, naming, testability |

## File Ownership Guidelines

Reviewers do NOT modify code. Each writes findings to a separate file:

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | review-summary.md | All findings + all code |
| Security Reviewer | review-security.md | All code under review |
| Performance Reviewer | review-performance.md | All code under review |
| Architecture Reviewer | review-architecture.md | All code under review |

Findings files are written to the project root or a temporary directory.

## Task Decomposition

### Lead Tasks
1. Identify all files changed (via `git diff` or user input)
2. Create task assignments for each reviewer with the file list
3. Wait for all reviewers to complete
4. Read all three findings files
5. Synthesize: deduplicate, assign severity, write final report

### Security Reviewer Tasks
1. Review all changed files for security issues
2. Check for: injection vulnerabilities, auth/authz gaps, secrets in code, input validation, CSRF/XSS, insecure dependencies
3. Write findings to review-security.md with severity ratings (CRITICAL/HIGH/MEDIUM/LOW)

### Performance Reviewer Tasks
1. Review all changed files for performance issues
2. Check for: O(n^2) algorithms, N+1 queries, missing indexes, memory leaks, unnecessary allocations, missing caching opportunities
3. Write findings to review-performance.md with severity ratings

### Architecture Reviewer Tasks
1. Review all changed files for design issues
2. Check for: SOLID violations, tight coupling, poor naming, missing abstractions, test coverage gaps, code duplication, inconsistent patterns
3. Write findings to review-architecture.md with severity ratings

## Teammate Prompt Template

### Security Reviewer Prompt
```
You are a security-focused code reviewer. Your ONLY job is finding security vulnerabilities.

FILES TO REVIEW:
{file_list}

YOUR OUTPUT FILE (you own this): review-security.md

REVIEW CHECKLIST:
- SQL/NoSQL injection
- XSS and CSRF vulnerabilities
- Authentication and authorization gaps
- Secrets or credentials in code
- Input validation and sanitization
- Insecure deserialization
- Dependency vulnerabilities
- Race conditions in auth flows

FORMAT each finding as:
## [SEVERITY] Finding Title
- **File:** path/to/file.py:line
- **Issue:** What's wrong
- **Risk:** What could happen
- **Fix:** How to fix it

When done, mark your task as completed and send a summary to the lead.
Do NOT modify any source code files. You are read-only except for your findings file.
```

### Performance Reviewer Prompt
```
You are a performance-focused code reviewer. Your ONLY job is finding performance issues.

FILES TO REVIEW:
{file_list}

YOUR OUTPUT FILE (you own this): review-performance.md

REVIEW CHECKLIST:
- Algorithm complexity (watch for O(n^2) or worse)
- Database query patterns (N+1, missing indexes, full table scans)
- Memory allocation patterns (unnecessary copies, leaks)
- Caching opportunities missed
- Unnecessary I/O or network calls
- Blocking operations in async code
- Large payload handling

FORMAT each finding as:
## [SEVERITY] Finding Title
- **File:** path/to/file.py:line
- **Issue:** What's wrong
- **Impact:** Estimated performance impact
- **Fix:** How to fix it

When done, mark your task as completed and send a summary to the lead.
Do NOT modify any source code files.
```

### Architecture Reviewer Prompt
```
You are an architecture-focused code reviewer. Your ONLY job is evaluating design quality.

FILES TO REVIEW:
{file_list}

YOUR OUTPUT FILE (you own this): review-architecture.md

REVIEW CHECKLIST:
- Single Responsibility violations
- Tight coupling between modules
- Poor or inconsistent naming
- Missing or unnecessary abstractions
- Code duplication
- Test coverage gaps
- Inconsistent patterns vs project conventions
- Error handling quality

FORMAT each finding as:
## [SEVERITY] Finding Title
- **File:** path/to/file.py:line
- **Issue:** What's wrong
- **Principle:** Which design principle is violated
- **Fix:** How to fix it

When done, mark your task as completed and send a summary to the lead.
Do NOT modify any source code files.
```

## Communication Flow

```text
    Lead (Opus)
    |
    +-- assigns review scope --> Security Reviewer
    +-- assigns review scope --> Performance Reviewer
    +-- assigns review scope --> Architecture Reviewer
    |
    Security Reviewer --> writes review-security.md --> notifies Lead
    Performance Reviewer --> writes review-performance.md --> notifies Lead
    Architecture Reviewer --> writes review-architecture.md --> notifies Lead
    |
    Lead reads all 3 --> writes review-summary.md --> presents to user
```

## Success Criteria

- All three reviewers complete their analysis
- No overlap in findings (lead deduplicates)
- Final report has severity-sorted findings across all lenses
- Actionable fix suggestions for each finding

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Reviewers find overlapping issues | Lead deduplicates in synthesis |
| Too many LOW severity findings | Ask reviewers to focus on HIGH+ only |
| Reviewers try to fix code | Prompt explicitly says read-only |
| Review scope too broad | Limit to changed files only (git diff) |

## Adaptation Notes

- **Python projects:** If project has `code-reviewer.md` agent, use its instructions for the architecture reviewer
- **Full-stack projects:** Consider splitting: security reviewer handles backend, a separate one handles frontend XSS/CSRF
- **Research projects:** Replace architecture reviewer with a "reproducibility reviewer" checking data handling
- **With code-quality skill active:** Complement (not replace) automated linting with human-like review
