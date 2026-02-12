# TOOLS.md - StyleMCP Agent Tools

## CLI Tools Available

You run on Bob's Mac Studio. These CLIs are installed and available via `exec`:

| Tool | Version | Use For |
|------|---------|---------|
| `node` / `npm` / `pnpm` | Node v22 | Run/build JS/TS projects |
| `git` | system | Version control |
| `gh` | 2.86 | GitHub CLI — PRs, issues, actions, API |
| `stripe` | 1.34 | Payment testing, webhooks, customer lookup |
| `docker` | 29.1 | Container builds/deploys |
| `himalaya` | — | Email (IMAP/SMTP) |
| `curl` / `jq` | system | API calls, JSON processing |
| `ffmpeg` | — | Media processing |

## OpenClaw Tools

You also have OpenClaw-native tools (no exec needed):
- `read` / `write` / `edit` — File operations
- `web_search` / `web_fetch` — Search and scrape the web
- `browser` — Control browser profiles (use `stylemcp` profile for Twitter)
- `message` — Send Telegram messages
- `cron` — Schedule tasks
- `sessions_send` — Message other agents or Bob
- `memory_store` / `memory_recall` — Long-term memory
- `image` — Analyze images

## Project-Specific

### Website Deployment (Cloudflare Pages)
- **Auto-deploys on push to `main`** via GitHub Actions
- Manual: `wrangler pages deploy landing --project-name=stylemcp`
- Domain: stylemcp.com → CF Pages project `stylemcp`

### API Deployment (VPS)
- **Host:** 82.180.163.60
- **User:** root
- **Repo path:** `/opt/stylemcp/`
```bash
ssh root@82.180.163.60 "cd /opt/stylemcp && git pull && docker compose up -d --build"
```

### Database
- **Self-hosted Supabase:** `db-stylemcp.distinctlydeveloped.com`
- **NOT Supabase Cloud** — no `.supabase.co` URLs anywhere

### Browser Profile
- Use profile `stylemcp` (port 18804) for Twitter @style_mcp
- **Always close browser sessions when done** — no zombie Chrome windows

### Email
- Default: `himalaya` (bob@distinctlydeveloped.com)
- All accounts: `himalaya account list`

### Repo
- Local: `~/openclaw/projects/stylemcp`
- GitHub: `DistinctlyDeveloped/stylemcp` (use `gh` CLI)

## Gotchas
- **Stripe SDK v20 + serverless**: Use raw `fetch` to Stripe API instead of the Node SDK


## GitHub CLI Reference

### `gh pr list --json` valid fields
additions, assignees, author, autoMergeRequest, baseRefName, baseRefOid, body, changedFiles, closed, closedAt, closingIssuesReferences, comments, commits, createdAt, deletions, files, fullDatabaseId, headRefName, headRefOid, headRepository, headRepositoryOwner, id, isCrossRepository, isDraft, labels, latestReviews, maintainerCanModify, mergeCommit, mergeStateStatus, mergeable, mergedAt, mergedBy, milestone, number, potentialMergeCommit, projectCards, projectItems, reactionGroups, reviewDecision, reviewRequests, reviews, state, statusCheckRollup, title, updatedAt, url

**Note:** The field is `statusCheckRollup` — NOT `statusCheckRollupState`. Use exact field names or `gh pr list --json` will error.

## Pexels API (Free Stock Images)

- **Account:** bob@distinctlydeveloped.com
- **API Key:** `~/.openclaw/secrets/pexels-api-key.txt`
- **Full Creds:** `~/.openclaw/secrets/pexels-creds.txt`
- **Rate Limit:** 200 requests/hour, 20,000/month
- **Docs:** https://www.pexels.com/api/documentation/
- **Usage:** `curl -H "Authorization: KEY" "https://api.pexels.com/v1/search?query=TERM&per_page=N"`
- **License:** Free for commercial use, no attribution required
- **Shared across all agents** — any agent can use this key for blog images, landing pages, marketing content


## Hosting & Deployment Infrastructure

**All sites behind Cloudflare. No Vercel. No Supabase Cloud.**

### Cloudflare Pages (deploy via `wrangler pages deploy`)
| Project | Domain | Pages Project Name |
|---------|--------|--------------------|
| StyleMCP | stylemcp.com | stylemcp |
| FamilyCircles | familycircles.app | familycircles-app |
| MemoirCircles | memoircircles.app | memoircircles-app |
| VideoCircles | videocircles.app | videocircles-app |
| GunSafe | gunsafe.app | gunsafe-app |
| GlowScript | glowscript.ai | (CF Pages — DNS 100.0.0.0) |
| InstantContent | instantcontent.ai | (CF Pages — DNS 100.0.0.0) |
| Prmptly | prmptly.ai | (CF Pages — DNS 100.0.0.0) |
| Buzz Boosters | buzzboosters.ai | buzzboosters |

### VPS (82.180.163.60) — PM2 + nginx
| Project | Domain | Port |
|---------|--------|------|
| 3DQUO | 3dquo.com | 5000 |
| DD Marketing | distinctlydeveloped.com | 3080 |
| Umami Analytics | analytics.distinctlydeveloped.com | 3033 |

### Self-Hosted DB Endpoints (VPS)
All at db-*.distinctlydeveloped.com

### Cloudflare CLI
- `wrangler pages project list` — list all Pages projects
- `wrangler pages deploy <dir> --project-name=<name>` — deploy to CF Pages
- CF API token at `~/.openclaw/secrets/cloudflare-api-token.txt`
