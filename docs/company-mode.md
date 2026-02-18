# Company Mode

The `oss-company` template simulates a full software company with six roles working together. Inspired by [ChatDev](https://github.com/OpenBMB/ChatDev), it brings structured communication, architectural oversight, and sprint management to your Claude Code sessions.

## What It Is

A team of 6 agents that mimics a real software company:

| Role | Model | Responsibility |
|------|-------|----------------|
| **CEO** (Lead) | Opus | Strategic direction, final merge decisions, user communication |
| **CTO** | Opus | Architecture review, technical direction, design decisions |
| **PM** | Sonnet | Sprint planning, progress tracking, issue management, ROADMAP updates |
| **Developer** | Sonnet | Implementation, bug fixes, feature development |
| **QA Engineer** | Sonnet | Testing, validation, bug reporting, quality gates |
| **Code Reviewer** | Opus | PR review, code quality enforcement, security audit |

The CTO and Code Reviewer default to Opus for maximum quality on architectural and review decisions. With `--max-mode`, all roles run on Opus.

## When to Use

- **Substantial development sessions** with multiple issues or a large feature
- **Maximum quality matters** -- CTO architectural review before implementation, Opus-level code review
- **Complex features** that benefit from design discussion before coding
- **Important releases** where you want structured QA and review gates

## When to Use oss-sprint Instead

| Consideration | oss-sprint | oss-company |
|---------------|-----------|-------------|
| Session scope | Quick bug fixes, routine features | Large features, important releases |
| Architecture oversight | None (lead handles everything) | CTO reviews before implementation |
| Sprint management | Lead handles | PM handles (dedicated tracking) |
| Code review quality | Sonnet reviewer | Opus reviewer |
| Decision flow | Lead decides all | PM proposes, CTO reviews, CEO approves |
| Token cost | ~1.2-1.6M | ~2-3M |
| Roadmap updates | Manual | PM updates every session |
| Best for | Daily work | Important milestones |

**Rule of thumb:** Use `oss-sprint` for your daily driver. Use `oss-company` when quality and thoroughness matter more than speed and cost.

## Communication Protocol

The company template uses structured communication that mimics a real software team. Understanding this flow is key to getting the most out of it.

### Phase 1: Sprint Planning

```text
PM reads GitHub state
  |
  +--> PM drafts sprint proposal (which issues, priority, assignments)
  |
  +--> PM shares proposal with CTO
  |
  +--> CTO reviews for technical feasibility
  |      - Are the issues independent?
  |      - What patterns should the developer follow?
  |      - Are there architectural risks?
  |      - Provides architecture notes for each issue
  |
  +--> CTO sends review back to PM
  |
  +--> PM shares approved plan with CEO
  |
  +--> CEO approves or adjusts
  |
  +--> PM assigns work to Developer with CTO's architecture notes
```

### Phase 2: Execution

```text
Developer implements following CTO's architecture notes
  |
  +--> Developer finishes --> messages PM + QA + Reviewer
  |
  +--> QA tests (parallel with Reviewer):
  |      |
  |      +--> PASS --> messages PM: "QA passed"
  |      |
  |      +--> FAIL --> messages Developer: "Bug found: {details}"
  |             Developer fixes --> messages QA: "Fixed, re-test"
  |             QA re-tests --> PASS
  |
  +--> Code Reviewer reviews (parallel with QA):
         |
         +--> APPROVE --> messages PM: "Review passed"
         |
         +--> CHANGES REQUESTED --> messages Developer: "Feedback: {details}"
                Developer addresses --> messages Reviewer: "Updated"
                Reviewer re-reviews --> APPROVE
```

### Phase 3: Merge

```text
PM confirms: QA passed + Review passed
  |
  +--> PM messages CEO: "Issue #X ready for merge"
  |
  +--> CEO creates PR and merges (or delegates routine merges to PM)
  |
  +--> PM updates issue with closing comment
  |
  +--> PM updates ROADMAP.md at session end
```

### Key Differences from oss-sprint

In `oss-sprint`, the lead (you) handles everything: triage, assignment, merge decisions, and communication. In `oss-company`:

- **PM** owns sprint planning and progress tracking, freeing the CEO for strategic decisions
- **CTO** reviews architecture before implementation, catching design issues early
- **Code Reviewer** runs at Opus level, providing higher-quality review
- Communication is structured: PM coordinates, CTO advises, CEO approves

## Token Cost

The company template is the most expensive template at approximately **2-3M tokens** per session. This breaks down as:

| Role | Model | Approximate Tokens |
|------|-------|--------------------|
| CEO (Lead) | Opus | ~200-300k |
| CTO | Opus | ~200-300k |
| PM | Sonnet | ~200-300k |
| Developer | Sonnet | ~200-300k |
| QA Engineer | Sonnet | ~200-300k |
| Code Reviewer | Opus | ~200-300k |
| Coordination overhead | -- | ~200-400k |

With `--max-mode` (all Opus), expect **~4-5M tokens**.

### Is It Worth It?

The company template pays for itself when:

- A bug in the implementation would have cost hours to find later
- The CTO catches an architectural issue before it gets baked into the codebase
- The Opus-level code review catches a security vulnerability
- Structured sprint planning prevents scope creep

For routine work, `oss-sprint` is more cost-effective.

## Tips for Getting the Most Out of It

### 1. Limit Sprint Scope

The PM should select **1-2 issues per session**, not 5. Fewer issues means deeper architecture review, more thorough QA, and better code review.

### 2. Let the Process Work

Resist the urge to bypass the PM or CTO. The structured communication exists for a reason -- it catches issues at each stage.

### 3. Use for Important Features

Save company mode for features that will be in the codebase for a long time. The extra architectural oversight and review quality pay off when code needs to be maintained.

### 4. Simplified Mode

For smaller projects where the full company feels excessive, you can ask the lead to drop the CTO role. The flow becomes: PM plans, Developer implements, QA tests, Reviewer reviews, CEO merges.

### 5. Multiple Developers

For larger sprints, ask the lead to spawn a second developer. The PM coordinates both, and QA + Reviewer handle both branches.

## Running Company Mode

### Standard Run

```text
/team oss-company
```

### Maximum Quality (All Opus)

```text
/team oss-company --max-mode
```

### Preview Plan

```text
/team oss-company --dry
```

### Prerequisites

The project must already exist on GitHub. If it does not, run `/team oss-kickstart` first to scaffold it.

You must also have the GitHub CLI configured. Run `/oss setup` if you have not done so.
