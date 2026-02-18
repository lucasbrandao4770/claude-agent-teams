# Token Economics

Agent teams consume significantly more tokens than single sessions. This guide helps you make informed cost decisions.

## Cost Model

### Base Formula

```
Total tokens = lead_tokens + (N * avg_worker_tokens) + coordination_overhead
```

Where:
- `lead_tokens`: ~150-200k (Opus, coordination + synthesis)
- `avg_worker_tokens`: ~100-200k per worker (Sonnet, execution)
- `coordination_overhead`: ~10-20% on top (messages, task management)

### Benchmarks (community-validated)

| Team Size | Approximate Total | vs Single Session | Monthly Cost* |
|-----------|-------------------|-------------------|---------------|
| Solo | ~200k tokens | 1x | baseline |
| 2 teammates | ~400k tokens | 2x | 2x baseline |
| 3 teammates | ~800k tokens | 4x | 4x baseline |
| 4 teammates | ~1.2M tokens | 6x | 6x baseline |
| 5 teammates | ~1.6M tokens | 8x | 8x baseline |

*Actual cost depends on your plan and model mix.

### Model Tiering (the biggest cost lever)

| Role | Model | Why |
|------|-------|-----|
| Lead | Opus | Needs strong reasoning for decomposition, synthesis, coordination |
| Workers | Sonnet | Executes well-defined tasks; Opus would be wasted |
| Trivial tasks | Haiku | Quick validation, formatting, simple checks |

**Impact:** Using Sonnet workers instead of Opus workers reduces total cost by ~40-50%.

To set model per teammate: specify `model: sonnet` or `model: haiku` in the Task tool when spawning.

## When Teams Are Worth It

### ROI Calculation

```
Team is worth it when:
  time_saved_hours * your_hourly_value > token_cost_dollars
```

### High-ROI Scenarios (use teams)

| Scenario | Time saved | Token cost | Verdict |
|----------|-----------|------------|---------|
| 3-lens code review of large PR | 2-3 hours | ~800k tokens | Worth it |
| Debug unknown root cause | 1-4 hours | ~800k tokens | Worth it |
| Refactor 5 modules simultaneously | 3-5 hours | ~1.2M tokens | Worth it |
| Full-stack feature (UI+API+tests) | 4-8 hours | ~800k tokens | Worth it |
| Literature review (20+ sources) | 3-6 hours | ~1M tokens | Worth it |

### Low-ROI Scenarios (avoid teams)

| Scenario | Time saved | Token cost | Verdict |
|----------|-----------|------------|---------|
| Fix known bug in one file | 0 hours | ~400k tokens | Waste |
| Write one unit test | 0 hours | ~400k tokens | Waste |
| Simple refactor (rename variable) | 0 hours | ~400k tokens | Waste |
| Sequential task (A then B then C) | Minimal | ~800k tokens | Use subagents |

## Optimization Strategies

### 1. Clear, Specific Prompts (saves ~30% tokens)

```text
BAD:  "Review the authentication code"
GOOD: "Review src/auth/jwt.py and src/auth/middleware.py for:
       1. Token expiration handling
       2. CSRF protection
       3. Session fixation risks
       Report findings in a markdown table with severity ratings."
```

Specific prompts reduce exploration tokens (workers don't waste time figuring out what to do).

### 2. File Ownership Eliminates Retry Tokens

When two teammates conflict on a file, one must redo their work. This doubles tokens for that task. Clear ownership prevents retries entirely.

### 3. Right-Size the Team

Most tasks need 3 teammates (lead + 2 workers). Adding a 4th worker gives diminishing returns unless the work naturally splits into 3+ independent partitions.

### 4. Use Subagents for Simple Delegation

If a worker just needs to do a focused task and report back (no cross-talk needed), a subagent costs ~50% less than a teammate for the same work.

### 5. Shutdown Idle Teammates Early

Teammates consume tokens even when idle (context window stays loaded). Shut down teammates as soon as their tasks are complete:

```
Ask the researcher teammate to shut down
```

### 6. Delegate Mode for the Lead

Use Shift+Tab to enable delegate mode. This prevents the lead from implementing tasks itself (which defeats the purpose of having a team and wastes Opus tokens on execution work).

## Anthropic's Multi-Agent Research Findings

From Anthropic's engineering blog on their multi-agent research system:

- Multi-agent Opus lead + Sonnet subagents outperformed single-agent Opus by **90.2%**
- **Token usage alone explains 80% of performance variance** (more tokens = better results)
- Parallel execution (3-5 subagents) reduces research time by up to **90%**
- The system uses ~15x tokens compared to chat for equivalent tasks
- **Coding tasks currently benefit less** than research tasks from this architecture

Key takeaway: Teams are an investment. They cost more tokens but produce significantly better results for tasks that benefit from parallel exploration. The key is choosing the RIGHT tasks.

## Cost Monitoring

During a team session, watch for:
- A teammate spinning on a task (high token burn, no progress) - redirect or shut down
- The lead doing work instead of delegating - enable delegate mode
- Unnecessary broadcasts (each costs N messages) - switch to direct messages
- Teammates reading files they don't need - tighten the file ownership scope
