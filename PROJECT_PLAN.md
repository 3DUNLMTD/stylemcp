# StyleMCP Project Plan

**Owner:** Bob Builder  
**Started:** 2026-01-26  
**Status:** Active Development

---

## Vision

StyleMCP becomes the go-to brand validation tool for developers and small teams who need affordable, intelligent brand consistency — positioned below enterprise tools like Markup AI ($27.5M funded) but with real AI-powered value.

---

## Two-Track Strategy

### Track A: Price/Simplicity (Indie Dev Market)
Make StyleMCP the obvious choice for individual developers and small teams.

**Pricing Changes:**
- [ ] Free: 5,000 requests/month (up from 1,000)
- [ ] Pro: $9/month for 25,000 requests
- [ ] Team: $29/month for 100,000 requests  
- [ ] Enterprise: Custom (self-hosted option)

**Simplicity Improvements:**
- [ ] One-click "Try it now" on landing page (no signup required)
- [ ] Pre-built style pack templates (SaaS, E-commerce, Healthcare, Finance)
- [ ] Visual style pack editor (no YAML knowledge required)
- [ ] Instant setup wizard in dashboard

### Track B: AI-Powered Value
Add features that justify paying for the hosted version over self-hosting.

**AI Features:**
- [ ] Intelligent rewrites using Claude/GPT (not just word swaps)
- [ ] "Learn my voice" — upload 10 examples, system learns patterns
- [ ] Context-aware suggestions (understands marketing vs. support vs. docs)
- [ ] Tone analysis and scoring

**Integrations:**
- [ ] Slack bot (validate messages before sending)
- [ ] GitHub PR comments (automatic copy review)
- [ ] VS Code extension
- [ ] Zapier integration

**Analytics & ROI:**
- [ ] Monthly brand health report
- [ ] "Violations caught" dashboard
- [ ] Trend analysis (is brand consistency improving?)
- [ ] Export reports for stakeholders

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
1. ✅ Implement AI-powered rewrites (Claude 3.5 Haiku)
2. ✅ Update pricing tiers ($0/5k, $9/25k, $29/100k)
3. ✅ Add "Try without signup" feature (/api/demo/validate)
4. Create 4 pre-built style pack templates

### Phase 2: Value Add (Week 3-4)
1. Build "Learn my voice" feature
2. Create visual style pack editor
3. Add basic analytics dashboard
4. Implement GitHub Action improvements

### Phase 3: Integrations (Week 5-6)
1. Slack bot
2. VS Code extension
3. Zapier connector

### Phase 4: Scale (Week 7-8)
1. Performance optimization
2. Multi-region deployment
3. Enterprise features (SSO, audit logs)

---

## Daily Research Protocol

Every day, I will:

1. **Competitive Monitoring**
   - Check Markup AI, Writer, Jasper for new features
   - Monitor Product Hunt for new brand/content tools
   - Search Twitter for "brand voice AI" discussions

2. **User Research**
   - Monitor r/SaaS, r/Entrepreneur for pain points
   - Check GitHub issues on similar projects
   - Look for "brand consistency" complaints

3. **Technical Research**
   - New MCP developments
   - AI API pricing changes
   - Performance optimization techniques

4. **Self-Audit**
   - Test our own product as a user would
   - Look for UX friction points
   - Check analytics for drop-off points

---

## Known Issues (Discovered 2026-01-26)

1. **Rewrite feature is basic find-replace, not AI** — CRITICAL
2. **No reason to upgrade from Free tier** — Pricing problem
3. **Self-hosting kills SaaS value prop** — Need cloud-only features
4. **No managed style packs** — Users must write YAML
5. **No integrations** — Raw API only
6. **Marketing claims don't match reality** — "Auto-rewrite" oversells

---

## Success Metrics

- **Week 2:** AI rewrites live, new pricing active
- **Week 4:** 10 paying customers
- **Week 8:** 50 paying customers, 3 integrations live
- **Month 3:** $1,000 MRR

---

## Log

### 2026-01-26
- Created project plan
- Identified 6 critical issues
- **Completed:**
  - AI-powered rewrites via Claude 3.5 Haiku (/api/rewrite/ai)
  - New pricing: Free $0 (5k), Pro $9 (25k), Team $29 (100k)
  - Public demo endpoint (/api/demo/validate) - 10 req/hr, no signup
  - Updated landing page FAQ with differentiator messaging
  - AI rewrites gated to Pro+ tiers
- Set up daily research cron job (9am CST)
- **Next:** Deploy to production, create style pack templates, test AI rewrites
