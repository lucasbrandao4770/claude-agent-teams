---
name: agent-teams
description: Best practices and templates for Claude Code agent teams. Activates when user mentions "agent team", "swarm", "multi-agent", "parallel agents", wants to parallelize work across multiple Claude instances, or runs /team command. Provides decision framework, coordination patterns, pre-built team templates, and DOs/DONTs. Do NOT activate for simple subagent delegation or single-session work.
---

# Agent Teams

Best practices framework for coordinating multiple Claude Code instances as a team. Includes decision framework, coordination patterns, and pre-built templates accessible via `/team`.

## Should You Use a Team?

```text
Is the task decomposable into 3+ independent subtasks?
  |
  +-- NO --> Single session or subagents (stop here)
  |
  +-- YES
       |
       +-- Can subtasks work on DIFFERENT files?
            |
            +-- NO --> Single session with plan mode
            |
            +-- YES
                 |
                 +-- Will time savings justify ~4x token cost?
                      |
                      +-- NO --> Subagents (parallel, cheaper)
                      |
                      +-- YES --> USE AN AGENT TEAM
```

### Quick Lookup

| Scenario | Team? | Why |
|----------|-------|-----|
| Multi-lens code review (security + perf + arch) | YES | Parallel independent analysis |
| Debug unknown root cause (multiple hypotheses) | YES | Competing investigations avoid bias |
| Full-stack feature (frontend + backend + tests) | YES | Natural file ownership split |
| Refactor across 4+ modules | YES | Each teammate owns a module |
| Literature review (multiple search angles) | YES | Parallel scouts, lead synthesizes |
| Fix a known bug in one file | NO | Too small, sequential |
| Write one test file | NO | Single session is faster |
| Sequential pipeline (A must finish before B) | NO | Subagents are cheaper |
| Same-file edits from multiple people | NO | Conflict risk too high |
| Task solvable in under 10 minutes | NO | Coordination overhead exceeds benefit |

### Teams vs Subagents

| | Subagents | Agent Teams |
|---|---|---|
| Context | Own window, results return to caller | Own window, fully independent |
| Communication | Report back to main agent only | Teammates message each other directly |
| Coordination | Main agent manages all work | Shared task list, self-coordination |
| Best for | Focused tasks where only result matters | Complex work requiring discussion |
| Token cost | Lower (~2x for 3 agents) | Higher (~4x for 3 agents) |

**Rule of thumb:** If workers only need to report results back, use subagents. If workers need to share findings or coordinate, use a team.

## Team Size

| Size | When | Model Strategy |
|------|------|---------------|
| 2 | Simple split (code + tests) | Opus lead + 1 Sonnet |
| 3 | Sweet spot for most tasks | Opus lead + 2 Sonnet |
| 4-5 | Large tasks with natural partitions | Opus lead + 3-4 Sonnet |

- NEVER more than 5 teammates. Coordination overhead exceeds gains.
- Aim for 5-6 tasks per teammate.
- Always use Opus for the lead (coordination, reasoning) and Sonnet for workers (execution). This cuts costs significantly.

## Coordination Patterns

| Pattern | When | Structure |
|---------|------|-----------|
| Leader/Specialist | Default. Lead decomposes, specialists execute | Hub-and-spoke |
| Parallel Workers | Same task type, different scopes | Workers get file partitions |
| Sequential Pipeline | Order matters (A feeds B feeds C) | Chain with blockedBy |
| Council | Decision-making, multi-perspective review | All propose, lead selects |
| Watchdog | Long-running, safety-critical | Worker + dedicated monitor |

**Start with Leader/Specialist.** It is the most reliable and easiest to debug.

For detailed descriptions, diagrams, and failure modes: see `references/coordination-patterns.md`

## File Ownership (CRITICAL)

**NEVER let two teammates edit the same file.** This is the single most important rule.

Before spawning any team:
1. List ALL files the team will touch
2. Assign each file to exactly ONE teammate
3. Include the ownership map in every teammate's initial prompt
4. If a teammate needs info from another's file, they READ (never write)

```text
GOOD: Teammate A owns src/api/, Teammate B owns src/components/
BAD:  Both teammates modify src/utils.py
```

## Communication Protocol

- Use TaskCreate for task assignments (shared, visible to all)
- Teammates mark completion via TaskUpdate + SendMessage to lead
- Lead monitors via TaskList (NOT constant messaging)
- NEVER broadcast unless truly team-wide emergency
- One broadcast = N messages (costs scale with team size)

## Template System

Pre-built team configurations available via `/team` command:

| Template | Pattern | Size | Best For |
|----------|---------|------|----------|
| code-review | Council | 3 | Multi-perspective code review |
| debug-investigate | Leader/Specialist | 3 | Bug with unknown root cause |
| refactor | Parallel Workers | 2-4 | Safe cross-module changes |
| fullstack-feature | Leader/Specialist | 3 | New feature with UI + API + tests |
| research-review | Parallel Workers | 3-4 | Literature review and synthesis |
| oss-kickstart | Leader/Specialist | 3 | Create a new OSS project from scratch |
| oss-sprint | Leader/Specialist | 4 | Work on GitHub issues (daily driver) |
| oss-company | Leader/Specialist | 5 | Full company simulation (max quality) |

### Using Templates

```
/team                          List available templates
/team code-review              Start code review team (adapts to project)
/team refactor --dry           Preview without spawning
/team oss-sprint --max-mode    Sprint with all Opus workers
/team create                   Create new template (guided)
```

Templates auto-adapt to the current project by discovering agents in `.claude/agents/` and mapping them to template roles.

**`--max-mode` flag:** Override all worker models to Opus for maximum quality. Applies to any template.

**OSS Factory templates:** The `oss-*` templates are designed for open-source project workflows. They use GitHub (issues, PRs, branches, Actions) as the persistence layer for session continuity. Setup: `/oss setup`. Guide: `/oss help`.

Custom templates: See `references/templates/_meta-template.md`

## DOs

1. **Assign file ownership BEFORE spawning** - Map every file to one owner
2. **Use Opus lead + Sonnet workers** - Significant cost savings (use `--max-mode` for all-Opus when quality matters most)
3. **Give specific initial prompts** - Include role, owned files, tasks, success criteria
4. **Define success criteria per task** - "Tests pass" not "looks good"
5. **Shutdown teammates when done** - Saves tokens, clean state
6. **Check for project-specific agents first** - Prefer specialized over generic
7. **Read GitHub state at sprint start** - `gh issue list`, `gh pr list`, `git branch -a` recover context from previous sessions

## DONTs

1. **Let two teammates write the same file** - Guaranteed conflicts
2. **Spawn more than 5 teammates** - Diminishing returns
3. **Use teams for tasks solvable in under 10 minutes** - Overhead exceeds benefit
4. **Send broadcasts for routine updates** - Direct message the lead instead
5. **Forget to clean up** - Always TeamDelete when finished
6. **Expect session resumption** - Teams are single-session, experimental (OSS templates use GitHub state for continuity instead)
7. **Nest teams** - Not supported (one team per session)
8. **Run dependent subagents in parallel** - If task B needs task A's output, run them sequentially. Parallel subagents polling/waiting wastes tokens.
9. **Assume idle teammates are working** - Idle may mean silently blocked (content filter, auth failure). If idle 3+ times without output, investigate or respawn.
10. **Include secrets in teammate prompts** - use placeholder names (e.g., `${{ secrets.API_KEY }}`). Tokens go in env vars or settings.json

## Known Issues

### iTerm2 Pane Cleanup Bug (GitHub #24385)

When using `teammateMode: "tmux"` with iTerm2, teammate panes may survive after shutdown/TeamDelete. The internal `it2 session close` call lacks the `-f` flag, causing silent failure in non-interactive context.

**Workaround:** Close orphaned panes manually with Cmd+W, or run `~/.claude/scripts/team-cleanup.sh` after each team session.

### Content Filtering Blocking Teammate Writes

Teammates may hit API-level content filtering (`Output blocked by content filtering policy`) when writing certain files. This is **not** a permissions or code issue — it's the safety filter blocking output generation. The teammate appears to be working (stays in_progress, rejects shutdown) but keeps going idle without producing files.

**Symptoms:** Teammate goes idle repeatedly without creating files. Task stays in_progress. Shutdown requests get rejected with "I'm still working."

**Affected content:** Code of conduct files, security-related templates, any text discussing sensitive topics.

**Workaround:** Shut down the stuck teammate and either (a) write the file yourself, (b) spawn a fresh subagent with a rephrased prompt, or (c) write a simpler version of the file.

### gh CLI Auth — Use GH_TOKEN, Not OAuth

The `gh` CLI's default OAuth browser flow (`gh auth login`) creates tokens (`gho_` prefix) that expire and require interactive re-authentication — completely incompatible with long-running agent team sessions.

**Solution:** Use a **Classic PAT** (`ghp_` prefix) set as `GH_TOKEN` in `~/.claude/settings.json`. This:
- Never expires (or has long expiry you control)
- Never prompts for browser auth
- Is inherited by ALL Claude Code processes including teammates
- Takes absolute precedence over keyring-stored OAuth tokens

**Setup:** Run `/oss setup` which guides through creating a Classic PAT with scopes (`repo`, `workflow`, `read:org`, `delete_repo`, `gist`) and adding it to settings.json.

**Verification:** `gh auth status` should show `(GH_TOKEN)` — if it shows `(keyring)` or `(oauth)`, the env var is not loaded. Restart the Claude Code session.

**Still required:** `gh auth setup-git` must be run once to configure git's credential helper to use `gh` (which reads `GH_TOKEN`).

## Limitations

- **Experimental feature** behind `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var
- No session resume for in-process teammates
- One team per session
- No nested teams (teammates cannot create sub-teams)
- Lead is fixed for the session lifetime
- Teammates start with lead's permission mode
- Split panes require tmux or iTerm2
- iTerm2 pane cleanup may fail silently (see Known Issues above)

## Token Cost Awareness

| Team Size | Approximate Tokens | vs Single Session |
|-----------|--------------------|-------------------|
| 2 teammates | ~400k | 2x |
| 3 teammates | ~800k | 4x |
| 4 teammates | ~1.2M | 6x |
| 5 teammates | ~1.6M | 8x |

Detailed cost modeling and optimization: see `references/token-economics.md`

## References

- Coordination patterns deep dive: `references/coordination-patterns.md`
- Token economics and cost modeling: `references/token-economics.md`
- Team architect workflow (anti-patterns, checklists): `references/team-architect-workflow.md`
- Team templates: `references/templates/`
- Meta-template for custom templates: `references/templates/_meta-template.md`
- Command: `~/.claude/commands/team/team.md`
- Official repo: https://github.com/lucasbrandao4770/claude-agent-teams
