# Saudi Opportunity Hub — Polish Pass Audit

_Branch: `polish/world-class-2026` (merged to `main` 2026-05-26) · Author: Claude Opus 4.7_

This audit is the entry point for a comprehensive polish pass targeting
"more polished than Stripe, Linear, and Vercel combined — while staying
credible to Saudi government and Vision 2030 audiences."

**Status legend** (added 2026-05-26 to keep the punch list honest):

- ✅ done — landed and verified
- ⚠️ partial — addressed for the public-page surface, SPA-side work pending
- ⏳ pending — not started in this pass

---

## TL;DR — the five things that matter

1. **There is no single design system. There are four.** `index.html`, `login.html`,
   `contact.html`, `api.html`, and `404.html` each define their own CSS-variable
   namespace, with conflicting names and even **two different Saudi greens**
   (`#006C35` everywhere except `api.html`, which uses `#007a3d`). Inside
   `index.html` alone there are *two* parallel token namespaces — `--bg-base`/
   `--accent` (lines 413-511) and `--bg`/`--green`/`--surface-2` (lines 516+).
   This is the foundation issue. Everything else is downstream.

2. **`index.html` is 25,334 lines of which ~8,700 are inline CSS.** Three `<style>`
   blocks (lines 392-8903, 21482-21523 print, 24292-24466). Body markup is
   ~12,500 lines of mostly hand-written HTML with inline event handlers (28
   instances of `onclick`/`onerror`/etc.). This is the single biggest barrier
   to "world-class polish" — every change is risky because the surface area
   is unbounded.

3. **The SEO/social meta in `index.html` is already solid** (title, description,
   OG, Twitter, canonical, theme-color, locale alternate, manifest). The site
   is intentionally `noindex,nofollow` + `Disallow: /` because it's a private
   demo. Phase 5 work should make the site *capable* of public SEO (schema,
   internal linking, content strategy) without flipping the indexing switch.

4. **`api/server.js` is in good shape** — disabled `x-powered-by`, CORS
   allowlist, manual security headers (HSTS, X-Content-Type-Options, frame
   deny, Permissions-Policy), per-IP token-bucket rate limiter, prod-fails-fast
   on missing Supabase env. Minor improvements (helmet for layered defense,
   structured logger) but not a P0 concern.

5. **Accessibility surface is already partially built** — 236 `aria-*`
   attributes, semantic heading structure, focus rings via `--shadow-focus`
   token. But there are gaps (the second `<img>` in `index.html:14674` uses
   `alt=""` for sector card art, which is borderline; we have `alert()` in
   `script.js:119` for the feedback form, which is not screen-reader-friendly;
   28 inline event handlers create keyboard-accessibility risk). WCAG 2.1 AA
   is achievable in Phase 6 without rewriting the world.

---

## Punch list

### P0 — block "world-class" claim

| # | Issue | Where | Status | Resolution |
|---|---|---|---|---|
| P0-1 | **Four divergent token namespaces** across the 6 HTML files | All HTML pages | ⚠️ partial | `assets/tokens.css` shipped as single source of truth + linked from every page (commit `644856f`). Each page's inline `<style>` still defines its own duplicates; those win on the cascade today. Removing them is the deferred 8,700-line extraction. |
| P0-2 | **~8,700 lines of inline CSS** in `index.html` | index.html:392-8903, 21482-21523, 24292-24466 | ⏳ deferred | Too risky to do inline alongside the rest of the pass. Token-wiring is in place to do this incrementally in a focused later session. |
| P0-3 | **Two Saudi greens in production** | api.html `#007a3d` | ✅ done | Restored to canonical `#006C35` (commit `644856f`). |
| P0-4 | **No IBM Plex Sans Arabic** despite RTL claims | All HTML pages | ✅ done | IBM Plex Sans Arabic loaded on every page. Satoshi removed from login/contact/api/reset-password. Font tokens unified in `tokens.css`. |
| P0-5 | **No proper RTL mirroring** beyond font-swap | All pages | ⚠️ partial | `tokens.css` swaps `--font-sans` to Arabic on `[dir="rtl"]`, flattens letter-spacing. The user has been doing the SPA RTL work in parallel (29 commits during this pass). Logical-property migration still incremental. |
| P0-6 | **Hero, opportunity listing, opportunity detail** visually generic | index.html body | ⚠️ partial | Showcase (`polish/showcase.html`) prototypes the redesigned hero (with mashrabiya motif), opportunity card, and dark/RTL variants. Login.html hero already received the redesign treatment. SPA-side swap-in deferred. |

### P1 — meaningful polish

| # | Issue | Where | Status | Resolution |
|---|---|---|---|---|
| P1-1 | `alert()` in feedback form | script.js:119 | ⚠️ moot | **Discovered during the polish pass:** `script.js` is an IIFE that never closes (`(function(){…}` at line 1 has no matching `})();`). `node --check` fails at line 609 with `SyntaxError: Unexpected end of input`. Browsers refuse to execute syntactically invalid scripts, so the `alert()` has never fired in production — the form is bound by the SPA's inline JS in `index.html` instead. P1-1 is therefore moot by observation. The deeper issue (`script.js` is dead code) is captured as N7 below. |
| P1-2 | 28 inline event handlers (`onclick=`, `onerror=`) | index.html | ⏳ pending | Real risk: tightening CSP requires this. Tracked for a focused refactor session — touches a lot of markup. |
| P1-3 | No proper loading skeletons | script.js / index.html | ⚠️ partial | Skeleton system shipped in `styles.css` (`.skeleton` + `.skeleton-container` with built-in screen-reader announcement). SPA wiring pending. Demonstrated in `polish/showcase.html`. |
| P1-4 | 131 `box-shadow:` declarations, hand-tuned | index.html | ⏳ pending | Six-token shadow system shipped in `tokens.css` (Linear-style two-layer). Migration depends on the inline-CSS extraction (P0-2). |
| P1-5 | 1,089 hex color literals | index.html | ⏳ pending | Same dependency — falls out of P0-2 extraction. |
| P1-6 | No JSON-LD beyond what GH Pages infers | All HTML | ✅ done | Organization + WebSite + ContactPage on head; per-opportunity `Grant` / `GovernmentService` / `EducationalOccupationalProgram` / `FundingScheme` via `assets/opportunity-schema.js`, wired into `openPanel`/`closePanel`. Graph-linked via `@id`. |
| P1-7 | No bilingual hreflang | index.html head | ✅ done | `<link rel="alternate" hreflang="{en,ar,x-default}">` on `index.html`. Sitemap also carries `xhtml:link rel="alternate"` for the root. |
| P1-8 | No `<picture>`/AVIF/WebP for sector imagery | index.html:14674 | ⏳ pending | Performance-only concern; pre-requires a sector-image inventory. |
| P1-9 | Inline `<script>` in `<head>` doing auth check, blocking render | index.html:7-56 | ⏳ pending | Architectural — the auth check is intentionally synchronous to gate render. Splitting it needs care. |

### P2 — quality-of-life

| # | Issue | Where | Status | Resolution |
|---|---|---|---|---|
| P2-1 | Hardcoded Supabase URL/key in two places | index.html:20-21, api/server.js:88-91 | ⏳ pending | Anon key is fine (RLS-gated by design); the duplication is the smell. |
| P2-2 | DOM queries by `aria-label` text | script.js:13-23 | ⏳ pending | Real fragility. Better fix in the same pass that handles P1-2. |
| P2-3 | `audit-*/` and `enrichment-*/` weren't gitignored | repo root | ✅ done | Commit `1757e64`. |
| P2-4 | No `.well-known/security.txt` | repo root | ⏳ pending | Cheap to add when a public launch is imminent. |
| P2-5 | Logo path falls through to `onerror` swatch fallback when asset missing | index.html:14674, theme manager | ⏳ pending | Works today; aesthetic upgrade. |
| P2-6 | No print stylesheet pass beyond a tiny block | index.html | ⏳ pending | Government users print briefs. Audit-flagged, low risk to add. |
| P2-7 | No `prefers-reduced-motion` audit | index.html CSS | ✅ done | Token-level coverage: `tokens.css` collapses all durations to 0ms and easings to linear under reduced-motion. `styles.css` skeleton goes static. Inline-CSS pieces in `index.html` still need a sweep — falls out of P0-2. |

### Issues found AFTER the initial audit

| # | Issue | Where | Status | Resolution |
|---|---|---|---|---|
| N1 | `--text-faint` token failed WCAG 2.1 AA contrast | tokens.css | ✅ done | Light bumped from `#a1a1aa` (2.56:1) to `#71717a` (4.83:1); dark from `#5b6480` (3.14:1) to `#7c89ab` (5.28:1). Probed via in-browser sRGB→linear-light calc. |
| N2 | "Unlock Saudi Arabia's investment landscape" in login.html — forbidden phrasing per BRAND.md | login.html | ✅ done | Rewritten to "Every Saudi grant, in one place." |
| N3 | 🌐 emoji on language toggle violates BRAND.md no-emoji rule | login.html | ✅ done | Replaced with inline SVG globe. |
| N4 | "Message sent!" + filler thanks copy on contact form | contact.html | ✅ done | Tightened to BRAND.md success pattern ("Message sent." + concrete SLA). |
| N5 | `sitemap.xml` missed the showcase page and lacked `xhtml:link` alternates | sitemap.xml | ✅ done | Showcase added; root entry now carries hreflang alternates. |
| N6 | CDN scripts have no SRI hashes | index.html | ⏳ pending | Hashes need real bytes at deploy time. Captured as a step in `polish/DEPLOY_CHECKLIST.md`. |
| N7 | `script.js` is dead code (IIFE never closed, syntax-errors at line 609, never executes in browsers) | script.js | ⏳ decision-needed | The file has been unparsable since 2024 per `git log`. Production behaviour comes entirely from `index.html`'s inline JS. Two options: **(a)** close the IIFE and dedupe whatever it tries to bind against the SPA's existing handlers; **(b)** delete the file and the `<script src="script.js">` reference in `index.html`. (a) is risky without behind-auth testing; (b) is cleaner but needs a quick code-review of what script.js _intended_ to provide vs what the SPA already does. |

---

## Page-by-page snapshot

### `/` (`index.html`) — auth-gated SPA
- 25,334 lines · 3 inline `<style>` blocks · 28 inline handlers · 43 `<h*>` tags
- Token set #1 (`--bg-base`, `--accent`) at lines 413-511 — semantic, well-organized
- Token set #2 (`--bg`, `--green`, `--surface-2`, `--pill-grant`) at lines 516+ — looks like a later attempt at the same job, never reconciled
- Saudi green `#006C35` is the canonical accent; sophisticated 7-theme white-label system (default/misa/monshaat/adio/neom/sdb/swift-solve) is genuinely impressive — the platform's secret weapon. Polish must preserve it.
- Light + dark mode wired correctly via `[data-theme]` and `prefers-color-scheme`
- Fluid type scale via `clamp()` already exists (lines 480-485) — keep it.

### `/login.html` — public, pre-auth
- Cream warm bg `#fdf8f2`, gold `#C9A66B`, deep green — visually distinct from index.html
- Satoshi (Fontshare) + Inter + Noto Kufi Arabic
- CSP is properly locked down here (line 11) — index.html lacks the same `<meta http-equiv="Content-Security-Policy">`
- Verdict: looks lovely in isolation, breaks brand consistency in context

### `/contact.html` — public form (Formspree)
- Same token set as login.html (good — already a mini-system between these two)
- CSP-locked, Noto Kufi Arabic loaded

### `/api.html` — public docs
- Stripe-inspired (and intentionally so) — own light/dark tokens, JetBrains Mono
- Uses `#007a3d` for green instead of `#006C35` — **brand bug**
- Otherwise the most polished page in the repo today

### `/404.html` — error
- Cream bg from login family but uses Inter+Space Grotesk like index.html
- Token surface is thin (8 vars); not aligned to either family

### `/reset-password.html` — auth
- Not deeply audited yet; will fold into Phase 2 token consolidation

---

## Brand-voice snapshot (pre-Phase 2)

From scanning `index.html` body copy, README, and the theme `tagline`s:

- **Tone is professional, restrained, and Vision-2030-anchored.** Taglines like
  "Aligned with Vision 2030", "Financing the Future of Saudi Arabia",
  "Building the future. NEOM." set a confident, formal register.
- **Bilingual is structural, not afterthought.** Every theme has `labelAr`,
  `taglineAr`, `navNameAr`. The platform was built with EN/AR parity in mind.
- **No exclamation marks, no AI-slop "Oops!"** Already a discipline.
- **Avoid Western startup voice** ("crush it", "rocket", emoji explosions).
  Government readers see that as low-trust.
- **Use Saudi/GCC funding lexicon**: grant, tender, accelerator, fellowship,
  RFP, RDIA, KAUST, Monsha'at, Misk, MISA, MoF, PIF, NEOM, SDB. These are
  proper nouns and must be capitalised correctly.

---

## Phase 5 reframe — what SEO + AI visibility means for a `noindex` demo

The site is intentionally hidden:
- `robots.txt`: `Disallow: /`
- All pages: `<meta name="robots" content="noindex, nofollow">`

So Phase 5 should:
1. **Make the site capable of ranking** — add schema, canonical hreflang
   pairs, internal linking, content strategy doc
2. **Leave the kill switch in place** — do not flip noindex; that's the
   user's strategic call when the demo becomes a launch
3. **Treat AI visibility (ChatGPT/Perplexity) as the more interesting
   surface** — these crawlers respect noindex less consistently, and
   the GovernmentService/Grant schema is what helps them cite the platform

---

## What I'll do next (Phase 2 plan)

1. Write `polish/BRAND.md` — voice, do/don't, EN/AR rules, terminology
2. Build `assets/tokens.css` as the **single** source of truth — light + dark,
   neutral ramp, two accents, type scale, spacing, radii, shadows, motion
3. Build `assets/styles.css` — extracted from `index.html`'s 8,700 inline lines,
   consuming tokens. Behaviour identical, structure cacheable
4. Replace per-page token namespaces in login/contact/api/404 with imports
   from `tokens.css` (preserving each page's visual character via composition)
5. Write `polish/DESIGN_SYSTEM.md` documenting it

Then Phase 3 is where the visible "polish" happens.

---

## Stop-and-think note for the human reviewer

The user's brief asks for the entire 35-step plan executed end-to-end in
one pass. Realistically the work spans many hours and several conversation
turns. This audit is checkpoint #1. Every meaningful change from here on
gets its own commit on `polish/world-class-2026` so progress is durable
and reviewable, and so the work can resume from any commit.
