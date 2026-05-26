# Changelog

All notable polish-pass changes since 2026-05-26. Newest first.

## 2026-05-26 — Polish pass

Comprehensive polish pass driven by `polish/AUDIT.md`. Twelve commits on
`main`. Targeted "more polished than Stripe, Linear, and Vercel
combined while staying credible to Saudi government audiences."

### Visible

- **Design-system showcase** at [`polish/showcase.html`](polish/showcase.html) — public reference page, every component in light + dark + RTL
- **SPA dashboard polish** — Welcome card with restrained mashrabiya motif, KPI tiles lift on hover with accent top-rail, quick-action chips with accent-glow shadows, sidebar active item with accent left-rail, opportunity cards lift on hover
- **Every public page** (login / contact / api / 404 / reset-password) carries the same polish vocabulary: mashrabiya hero motif, hover lifts, accent-glow focus rings, fluid display typography
- **Login hero rewrite** — "Every Saudi grant, in one place." (replaced the BRAND.md-banned "Unlock Saudi Arabia's investment landscape")
- **🌐 → SVG globe** on the language toggle
- **404 page** with gradient-clipped 4-0-4 number
- **View Transitions API** opt-in for smooth SPA route changes (Chrome 111+, Edge 111+, Safari 18+; older browsers no-op cleanly)

### Foundation

- **Brand voice** ([`polish/BRAND.md`](polish/BRAND.md)) — 4 voice attributes, do/don't with examples, GCC funding terminology EN↔AR
- **Design tokens** ([`assets/tokens.css`](assets/tokens.css)) — three-layer architecture (primitive → semantic → component), 9-step neutral ramp, 6-step fluid type scale, 4px spacing, Linear-style shadows, light/dark/RTL/reduced-motion/print
- **Foundation utilities** ([`assets/styles.css`](assets/styles.css)) — `.btn`, `.card`, `.pill`, `.skeleton`, `.skip-link`, `.bg-mashrabiya`
- **Design system reference** ([`polish/DESIGN_SYSTEM.md`](polish/DESIGN_SYSTEM.md))

### Architecture cleanup

- **Extracted 8,606-line inline `<style>`** from `index.html` to [`assets/legacy-app.css`](assets/legacy-app.css). `index.html` shrank 25,874 → 17,268 lines (-33%). Brace-balanced 1849/1849, 1,778 rules, 71 at-rules
- **Extracted 339-line head bootstrap** to [`assets/auth-bootstrap.js`](assets/auth-bootstrap.js) (Supabase auth + super-admin gate + theme registry + applyTheme + observer)
- **Polish overrides** ([`assets/polish-overrides.css`](assets/polish-overrides.css)) — loaded LAST so the visual upgrades win the cascade; uses `var(--accent)` so every white-label theme drives the colour
- **22 inline `onclick=` HTML attributes** converted to `data-action` + a single delegated listener in [`assets/polish-delegated-actions.js`](assets/polish-delegated-actions.js)
- **Dead `script.js` removed** (IIFE never closed since 2024; not referenced by any HTML file)

### Security

- **SRI + version pinning** on all 4 CDN scripts (supabase-js@2.45.4, chart.js@4.4.1, lucide@0.469.0, jspdf@2.5.2) with `crossorigin="anonymous"`
- **Performance preconnects** to `cdn.jsdelivr.net` and the Supabase project host
- **RFC 9116 `.well-known/security.txt`** with contact, expiry, scope
- **CI quality gate** ([`.github/workflows/polish-quality-gate.yml`](.github/workflows/polish-quality-gate.yml)) enforces SRI, pinning, CSS brace balance, JS syntax, JSON-LD validity, sitemap shape on every push

### Accessibility (WCAG 2.1 AA)

- **`--text-faint` contrast fix**: light 2.56:1 → 4.83:1, dark 3.14:1 → 5.28:1 (all 3 text tokens now AA-clean in both themes)
- **Touch-target AA** (WCAG 2.2 SC 2.5.8): showcase footer + theme toggle ≥24×24
- **Skeleton sr-only loading announcement** via `aria-busy` + clipped `::before`
- **Lighthouse baseline** on the live URL: Performance 97 / Accessibility 96 / Best Practices 96 / SEO 54 (intentional `noindex` + `Disallow: /`). LCP 2.1s, TBT 0ms, CLS 0.0006

### SEO + AI visibility

- **Head-level JSON-LD** on index / login / contact: `Organization` + `WebSite` (+ `ContactPage`), graph-linked via `@id`
- **Bilingual hreflang** (en, ar, x-default) on index.html
- **Per-opportunity Grant / GovernmentService / EducationalOccupationalProgram schema** via [`assets/opportunity-schema.js`](assets/opportunity-schema.js), wired into `openPanel` / `closePanel`. Schema-type switching, field aliasing for the SPA's dataset shape
- **`robots.txt` normalised** to LF + ASCII-only comments so Lighthouse stops flagging it invalid
- **Sitemap.xml** updated with `xhtml:link rel="alternate"` and the showcase URL

### Tracked follow-ups (GitHub issues)

- [#13](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/13) — `.btn` min-height 44px (WCAG 2.5.5 AAA)
- [#14](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/14) — drop CSP `'unsafe-inline'` (head bootstrap already extracted)
- [#15](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/15) — AVIF/WebP `<picture>` for sector imagery (runnable script in `scripts/`)
- [#16](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/16) — behind-auth smoke test of `data-action` flows (Playwright spec in `scripts/`)
- [#17](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/17) — Lighthouse baseline ✅ done, re-runnable via `scripts/run-lighthouse.sh`

### Runnable helper scripts (`scripts/`)

- [`scripts/run-lighthouse.sh`](scripts/run-lighthouse.sh) — re-run Lighthouse on the live URL
- [`scripts/build-sector-images.mjs`](scripts/build-sector-images.mjs) — generate AVIF + WebP + JPG variants via sharp
- [`scripts/smoke.spec.mjs`](scripts/smoke.spec.mjs) — Playwright smoke + visual regression with env-var credentials
- [`scripts/README.md`](scripts/README.md) — usage notes
