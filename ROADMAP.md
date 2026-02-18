# Roadmap

## v0.1.0 — Core Framework (current)

- [x] 8 team templates (code-review, debug-investigate, refactor, fullstack-feature, research-review, oss-kickstart, oss-sprint, oss-company)
- [x] `/team` command with `--dry` and `--max-mode` flags
- [x] `/oss setup` and `/oss help` commands
- [x] File ownership enforcement
- [x] Coordination patterns (Leader/Specialist, Parallel Workers, Council, Watchdog)
- [x] CI/CD pipelines (markdownlint + semantic-release)
- [x] Documentation (README, CONTRIBUTING, getting-started, creating-templates, company-mode)
- [ ] `install.sh` symlink installer
- [ ] Seed issues for initial development

## v0.2.0 — Distribution

- [ ] Claude Code plugin marketplace listing
- [ ] `npx claude-agent-teams install` support
- [ ] package.json for npm distribution
- [ ] Automated install verification

## v0.3.0 — Template Marketplace

- [ ] Community template submissions via PR
- [ ] Template quality validation (automated checks against meta-template)
- [ ] Template catalog website or GitHub Pages
- [ ] Template versioning

## Future

- [ ] Session resume for in-process teammates
- [ ] Nested teams (sub-teams within a team)
- [ ] Visual dashboard for team monitoring
- [ ] Token usage tracking and reporting
- [ ] Template composition (combine templates)
- [ ] Multi-repo support for monorepo workflows
