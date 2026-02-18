# OSS Help Command

> Show the user the navigation guide below. Do NOT execute anything — this is purely informational.

Display this to the user:

```
OSS FACTORY — Available Tools
==============================

SETUP (one-time):
  /oss setup                Configure GitHub CLI and authentication

TEAM TEMPLATES (via /team command):
  /team oss-kickstart       Create a new open-source project from scratch
  /team oss-sprint          Work on issues from the backlog (daily driver)
  /team oss-company         Full company simulation (maximum quality)

FLAGS:
  --dry                     Preview team plan without spawning
  --max-mode                All workers use Opus (quality over cost)

WORKFLOW:
  1. /oss setup             (once — install gh, authenticate)
  2. /team oss-kickstart    (once per project — scaffold, docs, CI/CD)
  3. /team oss-sprint       (every work session — implement, test, review)

SESSION CONTINUITY:
  GitHub is the persistence layer. Each sprint session reads open issues,
  PRs, and branches to recover context. No custom state files needed.

RELEASE STRATEGY:
  GitHub Actions handles releases automatically via CD pipeline.
  LLMs write code and open PRs — pipelines cut releases.

EXAMPLES:
  /team oss-kickstart                     # Scaffold a new project
  /team oss-sprint --dry                  # Preview sprint plan
  /team oss-sprint --max-mode             # Sprint with all Opus workers
  /team oss-company --max-mode            # Full company, all Opus

Run /oss setup to get started, or /team <template> to launch a team.
```
