# StyleMCP Project Memory

## Standards (Non-Negotiable)
- **Production quality always** — customers demand it
- **No shortcuts, no deferrals** — fix issues when identified, not "later"
- **Constant innovation** — always looking for ways to improve
- **Best products on the internet** — that's the bar

---

**Repo:** ~/openclaw/projects/stylemcp (GitHub: DistinctlyDeveloped/stylemcp)  
**Live:** https://stylemcp.com  
**Started:** 2026-01-26  

## What It Is

MCP server + REST API for brand voice validation and enforcement. Validates text against style packs (tone, vocabulary, patterns) and can rewrite violations automatically.

**Core Features:**
- Validate text against brand rules → score + violations
- AI-powered rewrites (Claude 3.5 Haiku) for Pro+ tiers
- Style packs (YAML configs): SaaS, Healthcare, Finance, E-commerce, Legal, Real Estate, Education, Government
- MCP integration for Claude Desktop/Cursor
- GitHub Action for CI/CD copy review

**Pricing:**
- Free: 5,000 req/mo
- Pro: $9/mo (25k req, AI rewrites)
- Team: $29/mo (100k req)

## Current Status

**What's Working:**
- REST API (validate, rewrite, packs) ✅
- **NEW: AI Output Validation API** ✅
- **NEW: Analytics Dashboard API** ✅
- MCP server ✅
- 8 industry packs deployed ✅
- Landing page with live demo ✅
- GitHub Action ✅

**What's Not:**
- Twitter @style_mcp has 0 followers after 4 days

**Auth Status (Feb 12 - MIGRATED):**
- ✅ Migrated to self-hosted Supabase at `db-stylemcp.distinctlydeveloped.com` (commit 4ba5ec4)
- All 8 auth files updated (auth.js, login/signup/dashboard/docs/pricing/status/auth-debug.html)
- Self-hosted anon key deployed
- GitHub OAuth configured on self-hosted instance (Feb 11)

## Bugs & Issues

### Fixed (Jan 28)
- **Pack validation rules not triggering** — Zod schema rejected `personPov: "second-or-third"` and `contractions: "discouraged"`, causing entire voice.yaml to fall back to empty defaults. Fixed by expanding enum values in schema.

### Open
- ALL CAPS regex in legal pack triggers incorrectly on normal text
- Chrome extension needs icons before Web Store submission

## Recent Work

### Feb 12 - Auth Migration Complete
- Migrated all auth to self-hosted Supabase (db-stylemcp.distinctlydeveloped.com)
- Updated 8 files with new URL and anon key
- Removed stale logout localStorage reference
- Cleaned Stripe keys from git history
- Pushed: commit 4ba5ec4

### Feb 4 - QC Scan
- Removed redundant server-layer pack cache in HTTP server; rely on `loadPack()` TTL/invalidation cache so pack edits show up without restart
- Added `?noCache=1` support to `/api/demo/validate` for cache-busting when needed
- Demo responses now include `packWarnings` when pack loads with warnings
- Pushed: commit `8476d02`

### Feb 3 - QC Scan
- Fixed ESLint error: removed unused `crypto` import from `src/server/http.ts`
- Consolidated auth: removed `legacyAuthMiddleware` in HTTP server (billing-aware `authMiddleware` is authoritative)
- Restored timing-safe legacy API key compare in `src/server/middleware/auth.ts` via `timingSafeEqual`
- Checks: `npm run build` ✅, `npm test` ✅, `npm audit --omit=dev` ✅
- Improved packs listing cache: added TTL + directory mtime invalidation + in-flight dedupe to avoid stale results and duplicate FS reads (`src/utils/pack-loader.ts`)
- Pushed: commits `764ec80`, `92a3fed`

### Feb 2 - Auth System Implementation
- **Fixed dashboard infinite loading** — login/signup had fake auth that didn't create Supabase sessions
- Implemented real `signInWithPassword` and `signUp` flows
- Dashboard now auto-creates user profiles on first login
- Graceful fallbacks when profiles table or RPC functions don't exist
- OAuth buttons enabled (GitHub/Google) — need provider setup in Supabase dashboard
- Deployed: login.html, signup.html, dashboard.html

### Feb 2 - Performance Optimization
- **NEW: Regex precompilation cache** (commit 2537db1)
  - WeakMap-based caching for compiled voice validation regexes
  - Precompiles forbidden words, vocabulary rules, and doNot patterns on first use
  - Significant performance improvement for repeated validation calls
  - Properly handles global regex `lastIndex` state reset
  - Reviewed and approved by DeepSeek code review

### Feb 2 - QC & Cleanup
- **QC Scan completed (3:00 PM):** TypeScript ✅, ESLint 28 warnings, Website ✅, API ✅
- Fixed 9 ESLint errors in `ai-output-validator.ts` (commit 60e4e45)
  - Removed unused imports: `loadPack`, `getPacksDirectory`, `join`
  - Prefixed unused parameters/variables with underscore convention
- Current linting: 28 warnings (all `@typescript-eslint/no-explicit-any`)
- Website functioning: https://stylemcp.com (483ms load), API `/validate` sub-second response
- **Security audit:** 4 moderate vulnerabilities in dev dependencies (esbuild/vite) - not production affecting
- **System Status:** Stable and production-ready

### Feb 2 - AI Enhancement Sprint
- **NEW: AI Output Validation** - `/api/ai-output/validate` endpoint for validating AI-generated content
- **NEW: Analytics Dashboard** - `/api/analytics/usage` endpoint for usage tracking
- Added comprehensive AI concern detection (voice drift, compliance risks, tone issues)
- Enhanced competitive positioning vs Acrolinx/Grammarly Business
- Created extensive test suite for AI validation scenarios
- Addressed 2026 market trends: AI trust validation, enterprise analytics

### Jan 28
- Created Legal, Real Estate, Education, Government packs
- Fixed vocabulary rules bug (enum values)
- Scaffolded Chrome extension (needs icons)

### Jan 27
- Added tone adjustment to existing packs
- Updated demo page with all 8 packs

### Jan 26
- Implemented AI-powered rewrites
- Updated pricing tiers
- Created public demo endpoint

## Infrastructure

**NO Vercel. NO Supabase Cloud. Everything on Cloudflare + VPS.**

**Static Website (Cloudflare Pages):**
- Deployed via `wrangler pages deploy landing --project-name=stylemcp`
- Auto-deploys on push to `main` via GitHub Actions
- Domain: stylemcp.com → CF Pages project `stylemcp`

**API Server (VPS 82.180.163.60):**
- Repo lives at `/opt/stylemcp/`
- Runs via Docker on port 3000
- nginx proxies `/api/*` → `http://127.0.0.1:3000`
- SSE endpoint at `/api/mcp/sse` has long timeouts configured

**Database:**
- Self-hosted Supabase at `db-stylemcp.distinctlydeveloped.com`
- **NOT** Supabase Cloud — no `orbliwjewqlnnutykozw.supabase.co` or any `.supabase.co` URLs
- Dashboard.html still has stale Supabase Cloud references — NEEDS FIXING

**Deployment:**
- Website: Push to `main` → GitHub Actions auto-deploys to CF Pages
- API: SSH to VPS, `cd /opt/stylemcp && git pull && docker compose up -d --build`

## Architecture Notes

- **Pack loading:** `src/utils/pack-loader.ts` loads manifest.yaml → voice.yaml, etc.
- **Validation:** `src/validator/rules/voice.ts` checks vocabulary.rules, forbidden, doNot patterns
- **Schemas:** `src/schema/voice.ts` — if voice.yaml fails Zod validation, entire voice falls back to empty defaults (silent failure!)

## Next Steps

1. Chrome extension icons → Web Store submission
2. VS Code extension
3. User auth + dashboard
4. "Learn my voice" feature

## Core Principle: Production Quality (from Robert, Feb 7 2026)
Always take the BEST route for long-term project success, not the fast route. We are NOT spinning up MVPs — we are building production-ready projects. No shortcuts, no "good enough for now." Quality and longevity over speed.

## Core Principle (from Robert, Feb 7 2026)
When you find a problem, fix it immediately. Don't defer. Don't call it "cosmetic" or "not blocking." Fix it in the same session you found it. No excuses.

## Core Principle: Verify Your Work (from Robert, Feb 7 2026)
Don't call it done until you've confirmed it actually works. Build it, test it, verify it — in the same session. Don't commit without building. Don't deploy without checking. Don't say "shipped" without confirming it's actually working.
