# claude-agent-teams

Turn Claude Code into a software engineering team.

[![CI](https://github.com/lucasbrandao4770/claude-agent-teams/actions/workflows/ci.yml/badge.svg)](https://github.com/lucasbrandao4770/claude-agent-teams/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/lucasbrandao4770/claude-agent-teams)](https://github.com/lucasbrandao4770/claude-agent-teams/stargazers)

## What is this?

A plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that adds multi-agent team coordination. Instead of working with a single Claude session, you can spawn a team of specialized agents that work in parallel -- each with their own role, file ownership, and communication channel.

The plugin provides:

- **8 pre-built team templates** for common workflows (code review, debugging, full-stack features, and more)
- **OSS Factory** -- a complete open-source project lifecycle powered by agent teams (scaffold, sprint, ship)
- **File ownership enforcement** -- no two teammates edit the same file, eliminating merge conflicts
- **Coordination patterns** -- Leader/Specialist, Parallel Workers, Council, and more
- **Cost-aware defaults** -- Opus lead + Sonnet workers by default, with `--max-mode` for all-Opus when quality matters most

## Quickstart

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Agent teams enabled: `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### Install

```bash
git clone https://github.com/lucasbrandao4770/claude-agent-teams.git
cd claude-agent-teams
./install.sh
```

The install script symlinks the skill, commands, and scripts into `~/.claude/` so Claude Code can discover them automatically.

### First team

```bash
# Start Claude Code in any project
claude

# List available templates
/team

# Preview a team plan without spawning
/team code-review --dry

# Spawn a code review team
/team code-review
```

### Validate locally

```bash
# Lint markdown files
markdownlint '**/*.md' --ignore node_modules --ignore CHANGELOG.md
```

## Template Catalog

| Template | Pattern | Team Size | Best For |
|----------|---------|-----------|----------|
| `code-review` | Council | 3 | Multi-perspective code review (security + performance + architecture) |
| `debug-investigate` | Leader/Specialist | 3 | Bugs with unknown root cause -- competing hypotheses in parallel |
| `refactor` | Parallel Workers | 2-4 | Safe cross-module refactoring with strict file ownership |
| `fullstack-feature` | Leader/Specialist | 3 | New features spanning frontend, backend, and tests |
| `research-review` | Parallel Workers | 3-4 | Literature reviews, tech evaluations, competitive analysis |
| `oss-kickstart` | Leader/Specialist | 3 | Create a new open-source project from scratch |
| `oss-sprint` | Leader/Specialist | 4 | Work on GitHub issues with develop-test-review loops |
| `oss-company` | Leader/Specialist | 5 | Full company simulation (CEO, CTO, PM, Dev, QA, Reviewer) |

### Usage

```
/team                              List available templates
/team <template>                   Spawn a team (with confirmation)
/team <template> --dry             Preview the plan without spawning
/team <template> --max-mode        All workers use Opus (maximum quality)
/team create                       Create a custom template (guided)
```

### Flags

**`--dry`** -- Preview the team plan (roles, file ownership, tasks) without spawning any agents. Use this to verify the plan looks right before committing tokens.

**`--max-mode`** -- Override all worker models to Opus instead of Sonnet. Use this when quality matters more than cost (e.g., critical code review, important releases). Default behavior uses Opus for the lead and Sonnet for workers, which cuts token costs significantly.

## OSS Factory

The `oss-*` templates provide a complete open-source project lifecycle:

```
/oss setup              One-time GitHub CLI setup and authentication
/oss help               Show all available OSS commands and workflow
```

### Workflow

```
1. /oss setup                 Install and authenticate gh CLI (once)
2. /team oss-kickstart        Scaffold a new project (repo, docs, CI/CD, conventions)
3. /team oss-sprint           Daily driver -- pick issues, implement, test, review, merge
4. /team oss-company          Full company simulation for important sessions
```

### How it works

**`oss-kickstart`** creates a project from zero: GitHub repo, project scaffold, README, CONTRIBUTING, CI/CD pipelines, coding conventions, labels, milestones, and seed issues. Three workers (Doc Writer, CI/CD Engineer, Conventions Writer) work in parallel after the lead sets up the repo.

**`oss-sprint`** is the daily driver. The lead reads GitHub state (open issues, PRs, branches), proposes a sprint, and spawns developers + QA + code reviewer. Developers implement issues on branches, QA tests, reviewer reviews, and the lead merges PRs. Feedback loops run in real-time.

**`oss-company`** is the premium experience. A virtual company with CEO, CTO, PM, Developer, QA, and Code Reviewer. The CTO provides architecture oversight, the PM manages the sprint, and quality gates ensure production-ready code.

### Session continuity

GitHub is the persistence layer. Each sprint session reads open issues, PRs, and branches to recover context from previous sessions. No custom state files needed.

## Token Cost Awareness

| Team Size | Approximate Tokens | vs Single Session |
|-----------|--------------------|-------------------|
| 2 teammates | ~400k | 2x |
| 3 teammates | ~800k | 4x |
| 4 teammates | ~1.2M | 6x |
| 5 teammates | ~1.6M | 8x |

Use `--dry` to preview the plan and estimate cost before spawning. Use `--max-mode` only when the task warrants it.

## File Ownership

The single most important rule: **never let two teammates edit the same file.** Before spawning any team, the lead:

1. Lists all files the team will touch
2. Assigns each file to exactly one teammate
3. Includes the ownership map in every teammate's prompt

If a teammate needs information from another's file, they read it (never write). This eliminates merge conflicts entirely.

## Known Limitations

- Agent teams are an **experimental feature** behind the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var
- Maximum 5 teammates per team
- One team per session (no nested teams)
- No session resume for in-process teammates (OSS templates use GitHub state instead)
- Split panes require iTerm2 or tmux
- iTerm2 pane cleanup may fail silently -- run `scripts/team-cleanup.sh` after sessions

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, branch naming, commit format, and PR process.

## License

[MIT](LICENSE)
