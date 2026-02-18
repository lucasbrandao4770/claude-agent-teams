# Team Architect Workflow Reference

Detailed reference material for the `/team` command. The command file contains the core workflow — this file provides anti-patterns, quality checklists, and adaptation notes.

---

## Anti-Patterns

| Anti-Pattern | Why Bad | Do Instead |
|---|---|---|
| Delegate team spawning to a subagent | Subagents can't use TeamCreate or interact with user | Main agent executes directly |
| Spawn without file ownership plan | Teammates clash on files | Map ownership BEFORE spawning |
| More than 5 teammates | Coordination overhead > parallelism gains | Keep it 2-4 workers |
| Vague task descriptions | Teammates waste tokens exploring | Be specific with deliverables |
| Spawn a separate "lead" teammate | Wastes tokens, can't interact with user | Main agent IS the lead |
| Lead implements instead of delegating | Wastes Opus tokens on worker tasks | Delegate execution to Sonnet workers |
| Broadcast routine updates | N messages per broadcast | Direct message only |
| Skip project agent discovery | Misses existing specialized agents | Always Glob for `.claude/agents/` |
| Use LLMs to cut releases | Unreliable, risky, unnecessary | Set up CD via GitHub Actions (semantic-release) |
| Skip feedback loops in sprint | Developers ship untested/unreviewed code | QA + Reviewer communicate directly with devs |
| Static team for phased work | Wastes tokens on idle workers | Dynamic spawn/shutdown: subagents for setup, team for creative work |
| Parallel subagents with dependencies | Task B polls/waits for Task A, wasting tokens | Run dependent subagents sequentially; only parallelize truly independent work |
| Ignoring repeated idle notifications | Teammate may be silently blocked (content filter, auth) | After 3+ idle cycles without output, investigate the teammate's logs or respawn |
| Monolith commits ("add everything") | Hard to review, revert, or understand history | Commit atomically by author/purpose (CI, docs, fixes as separate commits) |
| Disabling GitHub MCP plugin | Loses authenticated API access for issues/PRs/labels | Keep both gh CLI (git ops) AND GitHub MCP (API ops) — they complement each other |

---

## Quality Checklists

### Pre-Spawn

```
[ ] Template loaded and adapted to project context
[ ] Project agents discovered and mapped to roles
[ ] File ownership map complete with ZERO overlaps
[ ] Each teammate has clear tasks with deliverables
[ ] Success criteria defined for each task
[ ] Token budget estimated
[ ] User has confirmed the plan
```

### Post-Spawn

```
[ ] All teammates spawned successfully (check Task results)
[ ] TaskList reflects all tasks in pending state
[ ] Teammates acknowledged their roles (check messages)
```

### Completion

```
[ ] All tasks marked completed in TaskList
[ ] Lead (you) has synthesized results
[ ] Final summary presented to user
[ ] All teammates shut down via shutdown_request
[ ] TeamDelete called for cleanup
[ ] No orphaned panes (check iTerm2)
```

---

## Adaptation Notes by Project Type

### Python / Data Projects
- Workers should use `general-purpose` subagent type
- Map `data-engineer*.md` agents to backend/data roles
- For Spark projects: separate hot-path (driver) from cold-path (transformations)
- File ownership: partition by module (each worker owns a package directory)

### Full-Stack (React + FastAPI)
- Natural split: frontend worker owns `src/components/`, backend worker owns `src/api/`
- Test writer owns `tests/` directory
- Shared types/interfaces stay with lead
- Map `frontend-*.md` and `api-*.md` agents if they exist

### Research / Academic
- Map `literature-scout.md` → research scout role
- Map `citation-verifier.md` → verification role
- Scouts should search different angles (academic, industry, case studies)
- Lead synthesizes thematically, not chronologically

### Games (Godot)
- Adapt fullstack-feature: scene files → "frontend", scripts → "backend"
- File ownership by scene/node tree
- Test writer adapts to GDScript test framework

### AgentSpec
- Refactor template works well for agent file updates
- Partition by agent file (each worker owns specific agent definitions)
- Lead handles cross-cutting concerns (shared patterns, naming conventions)

### OSS Projects (oss-kickstart, oss-sprint, oss-company)
- **Prerequisites:** Run `/oss setup` first. Ensure `gh auth status` shows `workflow` scope and `gh auth setup-git` has been run.
- **Phased execution (kickstart):** Phase 1 uses SEQUENTIAL foreground subagents (scaffolder first, then configurator — configurator depends on repo existing). Phase 2 spawns team workers for creative work. Phase 3 is lead cleanup + atomic commits + push.
- **Branch isolation (sprint):** Each developer works on a separate branch (`feat/<issue>-<desc>` or `fix/<issue>-<desc>`), preventing file ownership conflicts
- **Feedback loops (sprint/company):** QA and Reviewer communicate directly with developers, not just with the lead. This creates quality multiplication.
- **Session continuity:** GitHub IS the persistence layer. Lead reads `gh issue list`, `gh pr list`, `git branch -a` at session start to recover context.
- **CD pipeline:** Releases are handled by GitHub Actions, NEVER by LLMs. The CI/CD Engineer in kickstart sets up semantic-release.
- **`--max-mode`:** Override all worker models to Opus. Useful for oss-company where CTO and Reviewer benefit most from Opus reasoning.
- **Company template:** PM handles sprint planning and tracking, CTO provides architecture oversight. Structured communication mimics a real software company.

---

## Token Budget Reference

| Team Size | Workers | Approximate Tokens | vs Single Session |
|-----------|---------|--------------------|--------------------|
| 2 workers | 2 | ~400k | 2x |
| 3 workers | 3 | ~800k | 4x |
| 4 workers | 4 | ~1.2M | 6x |

Model tiering (default): Lead = Opus (main agent), Workers = Sonnet.
This cuts costs 40-50% vs all-Opus teams.

With `--max-mode`: Lead = Opus, Workers = Opus. Maximum quality, ~2x cost increase.

| Team Size | Workers | Default Tokens | --max-mode Tokens |
|-----------|---------|---------------|-------------------|
| 3 workers | 3 | ~800k | ~1.5M |
| 4 workers | 4 | ~1.2M | ~2.2M |
| 5 workers | 5 | ~2-3M | ~4-5M |

---

## Communication Protocol

1. **Task assignments:** Use TaskCreate (visible to all teammates)
2. **Progress tracking:** Lead monitors via TaskList (NOT constant messaging)
3. **Completion:** Workers mark via TaskUpdate + SendMessage summary to lead
4. **Blocking issues:** Workers SendMessage to lead immediately
5. **Broadcasts:** NEVER unless true emergency (1 broadcast = N messages)
6. **Shutdown:** Lead sends `shutdown_request` to each worker when done
