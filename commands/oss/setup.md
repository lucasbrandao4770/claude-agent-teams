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

- **If authenticated:** Report the username and scopes. Continue to Step 3.
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
   - Administration: Read and Write (REQUIRED for repo creation)
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

### Step 3: Configure Git Credential Helper

This is CRITICAL — without this, `git push` will fail even though `gh` is authenticated:

```bash
gh auth setup-git
```

This configures git to use `gh` as the credential helper for github.com.

### Step 4: Verify Access (Comprehensive)

Run ALL of these checks. Do NOT declare success until every check passes:

```bash
# Check 1: Can list repos (basic auth)
gh repo list --limit 3

# Check 2: Can create repos (Administration permission)
# Create a temporary test repo, then delete it
gh repo create test-oss-setup-check --public --description "Temporary setup check" --clone 2>/dev/null
# If this fails, the token is missing "Administration" permission — tell the user to update their PAT

# Check 3: Can create labels (Issues permission)
gh label create "test-label" --repo <test-repo> --color 0E8A16 --description "Test" 2>/dev/null

# Check 4: Can push via git (git credential helper)
cd <test-repo> && echo "test" > test.txt && git add test.txt && git commit -m "test" && git push

# Cleanup: delete the test repo
gh repo delete <test-repo> --yes
```

**If any check fails**, tell the user EXACTLY which permission is missing and how to fix it. Common issues:

| Check Failed | Missing Permission | Fix |
|---|---|---|
| `gh repo list` fails | Token invalid or expired | Re-create token |
| `gh repo create` fails | Administration: Read and Write | Update PAT permissions |
| `gh label create` fails | Issues: Read and Write | Update PAT permissions |
| `git push` fails | `gh auth setup-git` not run | Run Step 3 again |

**Only after ALL checks pass**, report:

```
OSS Setup Complete
==================
  GitHub CLI:    gh vX.Y.Z
  Authenticated: @username
  Git credential: configured (gh auth setup-git)
  Verified:      repo create ✓  labels ✓  push ✓

You're ready to use:
  /team oss-kickstart    Create a new open-source project
  /team oss-sprint       Work on issues from the backlog
  /team oss-company      Full company simulation

Run /oss help for the full navigation guide.
```

### Step 5: Optional — Disable GitHub MCP Plugin

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
- If `gh repo create` fails → token needs "Administration: Read and Write" permission
- If `git push` fails → run `gh auth setup-git` to configure git credential helper
- If `gh repo list` fails → token may lack the right scopes, guide re-creation
- If user is behind a proxy → suggest `gh config set http_proxy <url>`
