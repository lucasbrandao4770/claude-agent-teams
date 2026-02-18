# OSS Setup Command

> **One-time setup.** Configures GitHub CLI authentication for non-interactive use with OSS Factory templates and agent teams.

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

### Step 2: Create a Classic PAT

Guide the user to create a **Classic** Personal Access Token (NOT fine-grained — Classic PATs work best with `gh` CLI and have simpler scope management).

Tell the user:

```
To authenticate non-interactively, you need a Classic Personal Access Token.

1. Go to: https://github.com/settings/tokens (Classic tokens tab)
2. Click "Generate new token (classic)"
3. Configure:
   - Note: "Claude Code Agent Teams"
   - Expiration: No expiration (or 1 year)
   - Scopes (check these boxes):
     ✓ repo           (full control of repositories)
     ✓ workflow        (update GitHub Action workflows)
     ✓ read:org        (read org membership)
     ✓ delete_repo     (delete repositories)
     ✓ gist            (create gists)
4. Click "Generate token" and copy it (starts with ghp_)
```

Then ask the user to paste their token.

### Step 3: Add GH_TOKEN to Claude Code Settings

This is the CRITICAL step. The `GH_TOKEN` environment variable makes ALL `gh` CLI commands and `git push/pull` work without any interactive prompts — no browser auth, no device flow, ever.

Add the token to `~/.claude/settings.json` in the `env` section:

```json
{
  "env": {
    "GH_TOKEN": "ghp_<the-token-the-user-pasted>"
  }
}
```

Use the Edit tool to add the key to the existing `env` object. Do NOT overwrite other env vars.

**Why `GH_TOKEN` in settings.json:**
- Inherited by ALL Claude Code processes including teammates
- Takes absolute precedence over keyring-stored OAuth tokens
- Persists across sessions without any re-authentication
- No browser popups, no device flow, no token refresh needed

### Step 4: Configure Git Credential Helper

```bash
gh auth setup-git
```

This configures git to use `gh` as the credential helper for github.com. Combined with `GH_TOKEN`, this means `git push` and `git pull` authenticate silently via the PAT.

### Step 5: Verify Access

Run these checks to confirm everything works:

```bash
# Check 1: gh CLI uses GH_TOKEN (should show "Logged in... (GH_TOKEN)")
gh auth status

# Check 2: Can list repos (basic API access)
gh repo list --limit 3

# Check 3: Can list issues on a repo
gh issue list --repo <any-user-repo> --limit 1

# Check 4: Token has correct scopes
# gh auth status should show: 'delete_repo', 'gist', 'read:org', 'repo', 'workflow'
```

**Key verification:** `gh auth status` must show `(GH_TOKEN)` as the auth source — NOT `(keyring)` or `(oauth)`. If it shows `(keyring)`, the `GH_TOKEN` env var is not being picked up. Check that it was added correctly to `settings.json` and that the Claude Code session was restarted.

**If any check fails:**

| Symptom | Cause | Fix |
|---|---|---|
| `gh auth status` shows `(keyring)` not `(GH_TOKEN)` | Env var not loaded | Restart Claude Code session after editing settings.json |
| Missing `workflow` scope | Token created without workflow | Regenerate token with `workflow` scope checked |
| Missing `delete_repo` scope | Token created without delete_repo | Regenerate token with `delete_repo` scope checked |
| `git push` prompts for password | `gh auth setup-git` not run | Run Step 4 again |

**Only after all checks pass**, report:

```
OSS Setup Complete
==================
  GitHub CLI:    gh vX.Y.Z
  Authenticated: @username (via GH_TOKEN)
  Auth source:   Classic PAT in settings.json (non-interactive)
  Git credential: configured (gh auth setup-git)
  Scopes:        repo, workflow, read:org, delete_repo, gist

You're ready to use:
  /team oss-kickstart    Create a new open-source project
  /team oss-sprint       Work on issues from the backlog
  /team oss-company      Full company simulation

Run /oss help for the full navigation guide.
```

### Step 6: Verify GitHub MCP Plugin is Enabled

The GitHub MCP plugin and `gh` CLI complement each other:
- **GitHub MCP**: API operations (create repos, issues, PRs, labels) — authenticated via plugin
- **gh CLI + GH_TOKEN**: git operations (push, pull, branch management) + label/milestone management

Check that `"github@claude-plugins-official": true` is set in `~/.claude/settings.json`. If not, enable it.

Do NOT suggest disabling either tool — they serve different purposes and both are needed.

---

## Error Handling

- If `brew install gh` fails → suggest `curl` install from https://cli.github.com/
- If the user creates a fine-grained PAT instead of Classic → it may work but Classic is recommended for simpler scope management
- If `gh auth status` shows `(keyring)` instead of `(GH_TOKEN)` → the env var is not loaded; restart Claude Code
- If `git push` fails → run `gh auth setup-git` to configure git credential helper
- If user is behind a proxy → suggest `gh config set http_proxy <url>`

## Security Notes

- The PAT is stored in `~/.claude/settings.json` which is a local config file (not in any git repo)
- Classic PATs with no expiration are convenient but should be rotated periodically
- If the token is compromised, revoke it at https://github.com/settings/tokens and create a new one
- Never commit the token to any repository
