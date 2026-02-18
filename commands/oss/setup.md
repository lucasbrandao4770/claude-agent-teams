# OSS Setup Command

> **One-time setup.** Guides the user through installing and authenticating the GitHub CLI (`gh`) for use with OSS Factory templates.

## Execute These Steps

### Step 1: Check `gh` CLI

```bash
which gh
```

- **If found:** Report version (`gh --version`) and skip to Step 2.
- **If missing:** Tell the user you'll install it via Homebrew:

```bash
brew install gh
```

Verify with `gh --version`. If `brew` is also missing, guide the user to https://cli.github.com/ for manual install.

### Step 2: Check Authentication

```bash
gh auth status
```

- **If authenticated:** Report the username and scopes. Skip to Step 3.
- **If not authenticated:** Guide the user through authentication.

Tell the user:

```
To authenticate, you need a GitHub Personal Access Token (fine-grained).

1. Go to: https://github.com/settings/tokens?type=beta
2. Click "Generate new token"
3. Name it: "Claude Code OSS Factory"
4. Set expiration (90 days recommended)
5. Under "Repository access" → "All repositories" (or select specific repos)
6. Under "Permissions" enable:
   - Contents: Read and Write
   - Issues: Read and Write
   - Pull requests: Read and Write
   - Actions: Read-only
   - Metadata: Read-only
7. Click "Generate token" and copy it
```

Then ask the user to paste their token. Once they provide it:

```bash
echo "<token>" | gh auth login --with-token
```

Verify with `gh auth status`.

### Step 3: Verify Access

Run these checks:

```bash
gh repo list --limit 3
```

If this succeeds, GitHub access is working. Report:

```
OSS Setup Complete
==================
  GitHub CLI:    gh vX.Y.Z
  Authenticated: @username
  Permissions:   Contents, Issues, PRs, Actions, Metadata

You're ready to use:
  /team oss-kickstart    Create a new open-source project
  /team oss-sprint       Work on issues from the backlog
  /team oss-company      Full company simulation

Run /oss help for the full navigation guide.
```

### Step 4: Optional — Disable GitHub MCP Plugin

Ask the user (via AskUserQuestion):

> Since `gh` CLI handles all GitHub operations, the GitHub MCP plugin is redundant. Want to disable it?
>
> - **Yes, disable it** — reduces noise, recommended
> - **No, keep it** — I use it for other things

If yes, guide them to remove `"github@claude-plugins-official": true` from `~/.claude/settings.json`.

---

## Error Handling

- If `brew install gh` fails → suggest `curl` install from https://cli.github.com/
- If token auth fails → check token hasn't expired, permissions are correct
- If `gh repo list` fails → token may lack the right scopes, guide re-creation
- If user is behind a proxy → suggest `gh config set http_proxy <url>`
