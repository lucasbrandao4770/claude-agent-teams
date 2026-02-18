# Coordination Patterns

Five proven patterns for organizing agent teams. Each pattern is a different answer to the question: "How should teammates relate to each other?"

## Pattern 1: Leader/Specialist

**The default. Use this unless you have a specific reason not to.**

```text
        Lead (Opus)
       /     |     \
  Specialist  Specialist  Specialist
  (Sonnet)    (Sonnet)    (Sonnet)
```

**How it works:**
1. Lead decomposes work into tasks
2. Lead assigns tasks to specialist teammates
3. Specialists work independently on their domain
4. Specialists report findings back to lead
5. Lead synthesizes results

**When to use:**
- One person can plan the work, others execute
- Tasks have clear domain boundaries (security vs performance vs architecture)
- Lead needs to coordinate and synthesize

**When NOT to use:**
- All workers do the same type of work (use Parallel Workers instead)
- Tasks require heavy cross-team discussion

**Failure modes:**
- Lead bottleneck: lead gets overwhelmed coordinating. Mitigation: limit to 3-4 specialists.
- Lead does the work: lead implements instead of delegating. Mitigation: use delegate mode (Shift+Tab).
- Vague assignments: specialists waste tokens exploring. Mitigation: specific prompts with success criteria.

**Token profile:** Medium. Lead overhead is constant; scales with number of specialists.

---

## Pattern 2: Parallel Workers

```text
        Lead (Opus)
       /     |     \
  Worker A  Worker B  Worker C
  [files]   [files]   [files]
  (Sonnet)  (Sonnet)  (Sonnet)
```

**How it works:**
1. Lead partitions work into non-overlapping file sets
2. Each worker gets their partition and identical instructions
3. Workers execute independently (no cross-communication)
4. Lead collects results when all complete

**When to use:**
- Same type of work across different scopes (refactor module A, B, C)
- Tasks are truly independent (no data dependencies)
- File ownership is naturally clean

**When NOT to use:**
- Workers need to discuss or share findings
- File boundaries are unclear
- Work requires sequential ordering

**Failure modes:**
- File conflicts: two workers touch the same file. Mitigation: EXPLICIT ownership maps.
- Inconsistent approaches: workers solve the same problem differently. Mitigation: provide a pattern/example in the prompt.
- Unbalanced partitions: one worker gets 80% of the work. Mitigation: measure file counts before assigning.

**Token profile:** Most efficient. Minimal coordination overhead. Workers don't message each other.

---

## Pattern 3: Sequential Pipeline

```text
  Stage 1 ──blockedBy──> Stage 2 ──blockedBy──> Stage 3
  (Sonnet)               (Sonnet)               (Sonnet)
```

**How it works:**
1. Tasks have explicit `blockedBy` dependencies
2. Stage 2 cannot start until Stage 1 completes
3. System auto-unblocks when dependencies resolve

**When to use:**
- Order matters: design before implement, implement before test
- Output of one stage is input to the next
- Want quality gates between stages

**When NOT to use:**
- Stages could run in parallel (wasted waiting time)
- No real data dependency between stages

**Failure modes:**
- Slowest link: entire pipeline waits on the slowest stage. Mitigation: only use for genuinely sequential work.
- Broken handoff: Stage 1 output doesn't match Stage 2 expectations. Mitigation: define clear interface contracts.
- Over-sequencing: tasks that COULD run in parallel are serialized. Mitigation: check if stages truly depend on each other.

**Token profile:** Lower than parallel (fewer concurrent contexts), but slower wall-clock time.

**Note:** For most sequential work, subagents are cheaper than a full team. Use teams only if stages need to communicate beyond simple result passing.

---

## Pattern 4: Council

```text
        Lead (Opus)
       /     |     \
  Reviewer  Reviewer  Reviewer
  (lens A)  (lens B)  (lens C)
  (Sonnet)  (Sonnet)  (Sonnet)
```

**How it works:**
1. All teammates review the same material through different lenses
2. Each produces independent analysis
3. Lead synthesizes, deduplicates, and resolves conflicts
4. Optionally: teammates challenge each other's findings

**When to use:**
- Multi-perspective review (security + performance + maintainability)
- Decision-making with competing hypotheses
- Want to avoid single-reviewer blind spots

**When NOT to use:**
- Single perspective is sufficient
- The "lenses" overlap significantly (wasted duplication)

**Failure modes:**
- Echo chamber: reviewers all find the same issues. Mitigation: assign distinct, non-overlapping lenses.
- Conflict fatigue: too many disagreements overwhelm the lead. Mitigation: limit to 3 reviewers.
- Token bloat: each reviewer reads the full codebase. Mitigation: scope review to specific files/areas.

**Token profile:** Highest per-task (everyone reads the same material). Worth it for high-stakes reviews.

---

## Pattern 5: Watchdog

```text
  Worker (Sonnet) <──monitors── Watchdog (Sonnet)
       |                              |
       +── does work                  +── checks quality
       +── reports progress           +── flags issues
                                      +── can trigger rollback
```

**How it works:**
1. Worker performs the main task
2. Watchdog monitors output quality in parallel
3. If watchdog detects issues, it messages the lead or worker
4. Can trigger rollback or correction

**When to use:**
- Long-running tasks where early quality checks save tokens
- Safety-critical changes (database migrations, infrastructure)
- Want continuous quality validation without waiting until the end

**When NOT to use:**
- Short tasks (watchdog overhead exceeds benefit)
- Low-risk changes

**Failure modes:**
- False positives: watchdog flags non-issues, disrupting the worker. Mitigation: clear quality criteria.
- Double cost: watchdog reads everything the worker writes. Mitigation: only use for high-value tasks.

**Token profile:** ~2x per monitored worker. Use sparingly.

---

## Choosing a Pattern

```text
Do teammates do DIFFERENT types of work?
  |
  +-- YES --> Leader/Specialist
  |
  +-- NO (same work, different scope)
       |
       +-- Can all work in parallel? --> Parallel Workers
       |
       +-- Must work in order? --> Sequential Pipeline
       |
       +-- All review the same thing? --> Council
       |
       +-- Need quality monitoring? --> Watchdog
```

## Combining Patterns

Patterns can be mixed within a single team:
- **Leader/Specialist + Watchdog:** Add a quality monitor to a specialist team
- **Parallel Workers + Sequential Pipeline:** Workers complete phase 1 in parallel, then phase 2 starts
- **Council + Leader/Specialist:** Reviewers (council) → implementers (specialist)

Keep combinations simple. Two patterns max per team.
