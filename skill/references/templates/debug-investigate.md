---
name: debug-investigate
description: Debug unknown issues by testing competing hypotheses in parallel
pattern: leader-specialist
team_size: 3
best_for: Bugs with unknown root cause where multiple theories need testing simultaneously
token_estimate: ~800k for typical investigation
---

# Debug Investigation Team

## When to Use

- Bug with unclear root cause (multiple plausible explanations)
- Intermittent failures that are hard to reproduce
- Performance regressions where the source is unknown

## When NOT to Use

- Root cause is known (just fix it)
- Simple error with clear stack trace (single session)
- Issue is in one file with obvious symptoms

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Hypothesis Generator) | opus | general-purpose | Analyze symptoms, generate hypotheses, evaluate evidence |
| Investigator A | sonnet | general-purpose | Test hypothesis 1 |
| Investigator B | sonnet | general-purpose | Test hypothesis 2 |

Optional: Add Investigator C for a third hypothesis if the problem space is large.

## File Ownership Guidelines

Investigators do NOT fix the bug. They gather evidence.

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | investigation-report.md, final diagnosis | All files |
| Investigator A | investigation-a.md | All source code (read-only) |
| Investigator B | investigation-b.md | All source code (read-only) |

## Task Decomposition

### Lead Tasks
1. Analyze the bug symptoms (error messages, logs, user report)
2. Generate 2-3 distinct hypotheses for the root cause
3. Assign one hypothesis per investigator
4. Wait for investigations to complete
5. Evaluate evidence from each investigator
6. Write final diagnosis with the most supported hypothesis
7. Optionally: propose a fix based on the diagnosis

### Investigator A Tasks
1. Receive hypothesis from lead
2. Gather evidence FOR and AGAINST the hypothesis
3. Run targeted tests, read relevant code, check logs
4. Write findings to investigation-a.md
5. Conclude: hypothesis SUPPORTED / REFUTED / INCONCLUSIVE with evidence

### Investigator B Tasks
1. Receive hypothesis from lead
2. Gather evidence FOR and AGAINST the hypothesis
3. Run targeted tests, read relevant code, check logs
4. Write findings to investigation-b.md
5. Conclude: hypothesis SUPPORTED / REFUTED / INCONCLUSIVE with evidence

## Teammate Prompt Template

### Investigator Prompt
```
You are a bug investigator. Your job is to TEST a specific hypothesis, NOT to confirm it.
Actively look for evidence BOTH FOR AND AGAINST the hypothesis.

HYPOTHESIS TO TEST:
{hypothesis_description}

BUG SYMPTOMS:
{symptom_description}

YOUR OUTPUT FILE (you own this): investigation-{letter}.md

INVESTIGATION PROTOCOL:
1. Read the relevant source code files
2. Look for evidence that SUPPORTS the hypothesis
3. Look for evidence that REFUTES the hypothesis
4. Run any tests that could prove/disprove the hypothesis
5. Check logs, error handling, edge cases

FORMAT your findings as:
## Hypothesis: {hypothesis}

### Evidence Supporting
- [evidence with file:line references]

### Evidence Refuting
- [evidence with file:line references]

### Tests Conducted
- [what you tested and results]

### Conclusion
SUPPORTED / REFUTED / INCONCLUSIVE
Confidence: HIGH / MEDIUM / LOW
Reasoning: [why]

IMPORTANT:
- Do NOT fix the bug. Only investigate.
- Do NOT modify any source code files.
- Be honest about inconclusive results.
- When done, mark your task completed and message the lead with your conclusion.
```

## Communication Flow

```text
    Lead (Opus)
    |
    +-- "Test: race condition in auth middleware" --> Investigator A
    +-- "Test: stale cache after deploy" --> Investigator B
    |
    Investigator A --> investigation-a.md (REFUTED) --> notifies Lead
    Investigator B --> investigation-b.md (SUPPORTED) --> notifies Lead
    |
    Lead evaluates evidence --> investigation-report.md --> presents to user
```

## Success Criteria

- Each investigator provides clear SUPPORTED/REFUTED/INCONCLUSIVE verdict
- Evidence is specific (file paths, line numbers, test results)
- Lead's diagnosis identifies the most likely root cause
- Investigation eliminates at least one hypothesis

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Confirmation bias (investigator only looks for supporting evidence) | Prompt explicitly requires evidence AGAINST |
| Hypotheses overlap (testing the same thing) | Lead generates truly distinct hypotheses |
| Investigators try to fix the bug | Prompt says investigate only, no modifications |
| All hypotheses inconclusive | Lead generates new hypotheses or escalates to user |

## Adaptation Notes

- **Python projects:** Investigators can run pytest on specific test files to gather evidence
- **Full-stack projects:** Split hypotheses by layer (frontend vs backend vs database)
- **Research projects:** Adapt for debugging data pipelines or experiment reproducibility
- **With existing agents:** If project has specialist agents, use them as investigators for their domain
