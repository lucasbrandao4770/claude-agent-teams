# Getting Started

Install claude-agent-teams and run your first multi-agent team in minutes.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and working
- GitHub account (for OSS templates)
- Agent teams feature enabled:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Add this to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist across sessions.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/lucasbrandao4770/claude-agent-teams.git
cd claude-agent-teams
```

### 2. Run the Installer

```bash
./install.sh
```

This creates symlinks from the repository files into `~/.claude/`, making the skill and commands available in any Claude Code session:

- `~/.claude/skills/agent-teams/` -- Skill definition and references
- `~/.claude/commands/team/` -- `/team` command
- `~/.claude/commands/oss/` -- `/oss setup` and `/oss help` commands
- `~/.claude/scripts/team-cleanup.sh` -- Cleanup utility

### 3. Verify Installation

Start a new Claude Code session and run:

```text
/team
```

You should see the template catalog:

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

If the catalog appears, installation is complete.

## Your First Team

### Dry Run (Preview Only)

Before spawning a real team, preview what the plan would look like:

```text
/team code-review --dry
```

This shows the team composition, file ownership map, and task assignments without spawning any teammates. Use this to understand how teams work before committing tokens.

### Run a Code Review Team

Navigate to a project with code changes (a branch with a PR, or staged changes) and run:

```text
/team code-review
```

The framework will:

1. **Discover your project** -- reads `.claude/CLAUDE.md` and checks for existing agents in `.claude/agents/`
2. **Build a plan** -- assigns file ownership and creates tasks for 3 reviewers (security, performance, architecture)
3. **Ask for confirmation** -- shows you the plan before spawning
4. **Spawn workers** -- creates 3 Sonnet teammates, each reviewing through a different lens
5. **Synthesize results** -- collects findings, deduplicates, and presents a unified review

### Max Mode

For maximum quality, use `--max-mode` to run all workers on Opus:

```text
/team code-review --max-mode
```

This costs more tokens but produces higher-quality analysis.

## OSS Workflow

The OSS templates (`oss-kickstart`, `oss-sprint`, `oss-company`) are designed for open-source project workflows using GitHub as the persistence layer.

### 1. Setup (One-Time)

```text
/oss setup
```

This guides you through installing and authenticating the GitHub CLI (`gh`). It verifies that you can create repos, manage issues, and push code.

### 2. Create a New Project

```text
/team oss-kickstart
```

This scaffolds a new open-source project from scratch: repository, documentation, CI/CD pipelines, coding conventions, issue templates, and seed issues.

### 3. Daily Work

```text
/team oss-sprint
```

This reads your GitHub backlog, proposes a sprint plan, and spawns developers + QA + code reviewer to work on 2 issues in parallel with quality feedback loops.

### 4. Full Company Mode

For important features or when you want the full collaborative experience:

```text
/team oss-company --max-mode
```

See [Company Mode Guide](company-mode.md) for details.

### Navigation Guide

Run `/oss help` at any time for a quick reference of all OSS commands and workflow.

## Split Panes

Agent teams work best with split panes so you can see each teammate's activity. Two backends are supported:

- **iTerm2** (macOS) -- set `teammateMode: "tmux"` in `~/.claude/settings.json`, or use the CLI flag `--teammate-mode tmux`
- **tmux** -- same setting, works on any terminal

Each teammate gets its own pane. The lead (your main session) stays in the original pane.

## Cleanup

After a team session, orphaned panes may remain (known issue with iTerm2). Clean them up:

```bash
~/.claude/scripts/team-cleanup.sh
```

Or close panes manually with Cmd+W (macOS).

## Next Steps

- [Creating Custom Templates](creating-templates.md) -- build your own team configurations
- [Company Mode Guide](company-mode.md) -- deep dive into the full company simulation
- Read `skill/SKILL.md` for the complete framework reference
