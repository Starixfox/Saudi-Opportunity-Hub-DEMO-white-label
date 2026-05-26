# Deploy checklist — public launch readiness

_Use this list when you're ready to flip the platform from "private
demo" to "publicly indexed." Most of the work is done; this is the
sequence that confirms nothing regressed and the visibility switches
flip cleanly._

---

## Pre-deploy

### Code freeze checks

- [ ] `git status` is clean; no uncommitted changes
- [ ] `git log --oneline main..HEAD` is empty (you're on `main` and nothing dangling)
- [ ] All polish-pass commits land on `main` and pushed to `origin/main`
- [ ] No `console.log` / `console.warn` / `console.error` left in production paths
      _Quick grep:_ `grep -nE 'console\.(log|warn|error)' index.html script.js assets/*.js`
- [ ] No `TODO` / `FIXME` in critical paths
      _Quick grep:_ `grep -nE '(TODO|FIXME|XXX)' index.html script.js assets/*.js`
- [ ] No hardcoded local URLs (`localhost:5181`, `127.0.0.1`, file paths)
      _Quick grep:_ `grep -n 'localhost\|127.0.0.1' index.html *.html assets/*.js`
- [ ] No leaked private credentials (only the documented Supabase **anon** key is allowed)
      _Quick grep:_ `grep -nE '(sk_|secret_key|service_role)' . -r --exclude-dir=.git`

### Browser-side smoke (load each page in an incognito window)

- [ ] `/` (index.html) — redirects to `/login.html` when not authenticated
- [ ] `/login.html` — hero shows "Every Saudi grant, in one place.", SVG globe icon (not 🌐), mashrabiya pattern visible at low opacity in the brand panel
- [ ] `/contact.html` — subtitle reads the three-purpose version, form submits OK
- [ ] `/404.html` — opens, the new copy renders ("We couldn't find that page…")
- [ ] `/api.html` — green theme uses canonical `#006C35` everywhere (no `#007a3d` slipping in)
- [ ] `/polish/showcase.html` — 8 sections, 4 opportunity cards (3 EN + 1 AR), light/dark/RTL toggles work, `<script id="oh-opportunity-ld-json">` appears in head with valid JSON
- [ ] DevTools → Application → No service-worker / cache leftovers from prior builds

### Design system

- [ ] `assets/tokens.css` loads on every HTML page (Network tab; `200 OK`)
- [ ] `assets/styles.css` loads on every page that uses `.btn` / `.card` / `.pill`
- [ ] `--accent` resolves to `#006C35` in light, `#34d97b` in dark
- [ ] No off-canon Saudi greens remain
      _Quick grep:_ `grep -inE '#007a3d|#00a651' *.html assets/*.css` _(in dark theme `#00a651` may exist in `api.html` — confirm it's intentional)_
- [ ] White-label tenants (MISA, Monsha'at, ADIO, NEOM, SDB, Swift Solve) still render with their own accent — click each in the theme manager

### Accessibility (WCAG 2.1 AA)

- [ ] All three text tokens pass AA in both themes (already verified):
  - `--text` 17.72:1 light / 15.32:1 dark
  - `--text-muted` 7.73:1 / 7.57:1
  - `--text-faint` 4.83:1 / 5.28:1
- [ ] Touch-target AA (WCAG 2.2 SC 2.5.8, 24×24 CSS px) — verified for the
      showcase footer + theme toggle. **Best-practice 44×44 (Apple HIG,
      Material) is NOT yet met** for: theme-toggle pills (32×32), default
      `.btn` (39px tall), opp-card pill / chevron sub-buttons. Roll a
      separate `.btn-touch` variant or bump `--btn-min-height` to 44px
      in a future polish round; impacts every page that uses `.btn`.
- [ ] Run Lighthouse on `login.html` and `polish/showcase.html` — target ≥95 accessibility
- [ ] Run axe DevTools or Chrome's "Issues" panel — zero serious / critical
- [ ] Tab through `/login.html` with keyboard only — every interactive element shows a visible focus ring, tab order is sensible
- [ ] VoiceOver / NVDA sweep on `/login.html` — labels read meaningfully, form errors announced via `aria-live`

### SEO & AI visibility

- [ ] **Decision point: are you flipping the noindex switch?**
  - If **yes** (going truly public):
    - [ ] Remove `<meta name="robots" content="noindex, nofollow">` from every page (`index.html`, `login.html`, `contact.html`, `api.html`, `404.html`, `reset-password.html`)
    - [ ] Update `robots.txt`: replace `Disallow: /` with `Allow: /`
    - [ ] Submit sitemap to Google Search Console and Bing Webmaster Tools
    - [ ] Verify domain ownership in both
  - If **no** (still demo): leave robots/meta alone; the structured data still helps AI crawlers cite the platform
- [ ] Test JSON-LD with [Google's Rich Results Test](https://search.google.com/test/rich-results) on:
  - [ ] `/` (Organization + WebSite)
  - [ ] `/login.html` (Organization + WebSite)
  - [ ] `/contact.html` (Organization + ContactPage)
  - [ ] `/polish/showcase.html` (sample Grant)
- [ ] Test `hreflang` pairs with [Merkle's hreflang tag tester](https://technicalseo.com/tools/hreflang/) on `/`
- [ ] Open an opportunity panel in the live SPA → DevTools shows `<script id="oh-opportunity-ld-json">` populated and the `@type` matches the opportunity's `funding_type`
- [ ] Close the opportunity panel → the `<script id="oh-opportunity-ld-json">` element is gone (clean state)

### Performance

- [ ] Lighthouse Performance ≥85 on `/login.html` (target 95; current state untested — first run will set the baseline)
- [ ] Lighthouse Best Practices ≥95 on every public page
- [ ] No render-blocking resources flagged in the Lighthouse audit (the `<script defer>` strategy on index.html should be intact)
- [ ] Network panel: tokens.css + styles.css both `< 5 KB` gzipped (they should be)
- [ ] Network panel: no `404` requests on first load of any public page

### Security headers

- [ ] CSP `meta http-equiv` is set on every public page
- [ ] CSP allows `connect-src` only to `dshrbbnjahjcwxzvzygh.supabase.co`, `formspree.io`, `translate.googleapis.com` — nothing else
- [ ] `frame-ancestors 'none'` enforced (verify via `curl -I` if running behind a proxy; via DevTools → Response Headers otherwise)
- [ ] `X-Content-Type-Options: nosniff` present
- [ ] `Referrer-Policy: strict-origin-when-cross-origin` present
- [ ] HSTS enabled at the GitHub Pages / Cloudflare / Vercel layer (GH Pages enables it by default with custom domains)

### Subresource Integrity (SRI) on CDN scripts

`index.html` pulls four scripts from `cdn.jsdelivr.net`. A compromised
CDN could ship modified JS to every visitor. SRI prevents that.

- [ ] Pin `lucide@latest` to a specific version (e.g. `lucide@0.485.0`).
      Leaving `@latest` makes SRI impossible — the hash changes silently.
- [ ] For each pinned CDN script, fetch its SRI hash from
      `https://data.jsdelivr.com/v1/package/npm/<name>@<version>/integrity`
      or compute locally:
      ```bash
      curl -fsSL <script-url> | openssl dgst -sha384 -binary | openssl base64 -A
      ```
- [ ] Add `integrity="sha384-…"` and `crossorigin="anonymous"` to every
      `<script src="https://cdn.jsdelivr.net/…">` in `index.html`
      (`supabase-js@2`, `chart.js@4.4.1`, `lucide@<pinned>`, `jspdf@2.5.2`).
- [ ] Re-run `/login.html` and the dashboard view after the SRI changes —
      browsers silently 403 scripts whose hashes don't match. Confirm
      no console errors and that Chart.js + Lucide icons still render.

---

## Deploy

GitHub Pages serves from `main` automatically — pushing to `main` is the
deploy. Steps:

1. Final `git push origin main`
2. Wait ~30–60s for GH Pages rebuild
3. Hard-refresh the live site in an incognito window (Cmd/Ctrl-Shift-R)

If using a custom domain:

- [ ] CNAME / A records point to the GH Pages IPs
- [ ] HTTPS enforced (GH Pages "Enforce HTTPS" toggle on)
- [ ] Custom domain reflected in `<link rel="canonical">` (currently the
      `starixfox.github.io` form — update if you move to e.g.
      `opportunityhub.sa`)

---

## Post-deploy verification

Within the first 30 minutes:

- [ ] Site loads at the production URL
- [ ] `/login.html` form posts successfully to Supabase (test with a real account)
- [ ] Open one opportunity from the SPA after sign-in — JSON-LD emits, panel renders, RTL still works
- [ ] Mobile view ≤480px doesn't break (use Chrome DevTools device emulator)
- [ ] Lucide icons render (no broken-square fallbacks)
- [ ] Chart.js charts render on the dashboard / analytics views
- [ ] Theme manager (`?theme=misa`) still applies the MISA white-label correctly

Within the first 24 hours:

- [ ] Supabase logs show no spike in failed auth attempts (rate limiter holding up)
- [ ] No new errors in the browser console for normal user flows
- [ ] Search Console: no new indexing errors (if you flipped to indexable)
- [ ] Email yourself / a trusted colleague the URL — get one outside-eyes confirm
      that the brand feels right

---

## Rollback

If something is wrong:

1. **Soft rollback** — push a fix commit (preferred). GH Pages redeploys in 30–60s.
2. **Hard rollback** — `git revert <bad-commit>` then push. Don't `git reset --hard` on `main`; the history matters.
3. **Last resort** — if `main` is broken and you need a moment, push the previous green SHA to a `hotfix/restore-<date>` branch and point GH Pages settings at that branch temporarily.

The polish pass landed in 8 commits with `Polish pass:` / `Phase N:` /
`Wire OpportunitySchema` prefixes. Each is independently revertable.
