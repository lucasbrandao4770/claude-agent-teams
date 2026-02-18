# Contributing to claude-agent-teams

Thank you for your interest in contributing! This guide covers everything you need to get started.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- [Git](https://git-scm.com/) installed
- [Node.js](https://nodejs.org/) (for markdownlint — linting only)
- Agent teams feature enabled via environment variable:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Add this to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist across sessions. Without this variable set, the `/team` command and all teammate spawning will not work.

## Dev Setup

```bash
# Clone the repo
git clone https://github.com/lucasbrandao4770/claude-agent-teams.git
cd claude-agent-teams

# Install the plugin locally
./install.sh

# Install the markdown linter (for local validation)
npm install -g markdownlint-cli
```

After running `install.sh`, the skill, commands, and scripts are symlinked into `~/.claude/`, so any edits you make in the repo are reflected immediately.

## Branch Naming

Create branches from `main` using the following format:

| Prefix | Use Case |
|--------|----------|
| `feat/<description>` | New feature or template |
| `fix/<description>` | Bug fix |
| `docs/<description>` | Documentation changes |
| `chore/<description>` | Maintenance, CI, tooling |

Examples:

```bash
git checkout -b feat/add-monorepo-template
git checkout -b fix/cleanup-script-path
git checkout -b docs/improve-quickstart
```

## Commit Format

This project uses [Conventional Commits](https://www.conventionalcommits.org/). Every commit message must follow this format:

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

| Type | Purpose | Version Bump |
|------|---------|-------------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `docs` | Documentation changes | None |
| `chore` | Maintenance, CI, tooling | None |
| `refactor` | Code restructure (no behavior change) | None |
| `test` | Adding or updating tests | None |

A `BREAKING CHANGE` in the commit footer triggers a **major** version bump.

### Examples

```bash
git commit -m "feat: add monorepo team template"
git commit -m "fix: correct symlink path in install.sh"
git commit -m "docs: add troubleshooting section to README"
```

## Lint Before Pushing

Run the markdown linter locally before pushing:

```bash
markdownlint '**/*.md' --ignore node_modules --ignore CHANGELOG.md
```

The linter configuration is in `.markdownlint.json` at the repo root. Link checking runs automatically in CI on pull requests.

## Pull Request Process

1. **Branch** from `main` using the naming convention above
2. **Implement** your changes
3. **Lint** locally with `markdownlint`
4. **Open a PR** targeting `main`
5. **CI must pass** (markdownlint + link check)
6. **Squash merge** into `main`

After merge, `semantic-release` automatically creates a GitHub Release based on your commit messages.

## Adding a New Template

Team templates live in `skill/references/templates/`. To create a new one:

1. Read `skill/references/templates/_meta-template.md` for the required structure
2. Create your template file: `skill/references/templates/<name>.md`
3. Include the YAML frontmatter (`name`, `description`, `pattern`, `team_size`, `best_for`, `token_estimate`)
4. Define: team composition, file ownership, task decomposition, teammate prompts, communication flow, success criteria
5. Test with `/team <name> --dry` to verify the plan looks correct
6. Open a PR with a description of the use case your template addresses

## Project Structure

```
claude-agent-teams/
  skill/
    SKILL.md                              Main skill file (decision framework, patterns)
    references/
      coordination-patterns.md            Coordination pattern deep dives
      token-economics.md                  Cost modeling and optimization
      team-architect-workflow.md          Anti-patterns and checklists
      templates/
        _meta-template.md                 Template for creating templates
        code-review.md                    Code review team
        debug-investigate.md              Debug investigation team
        refactor.md                       Refactoring team
        fullstack-feature.md              Full-stack feature team
        research-review.md                Research review team
        oss-kickstart.md                  OSS project creation
        oss-sprint.md                     OSS sprint (daily driver)
        oss-company.md                    OSS company simulation
  commands/
    team/
      team.md                             /team command implementation
    oss/
      setup.md                            /oss setup command
      help.md                             /oss help command
  scripts/
    team-cleanup.sh                       Cleanup orphaned panes/sessions
```

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.
