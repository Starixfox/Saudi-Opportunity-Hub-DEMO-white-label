# Saudi Opportunity Hub — Polish Pass Audit

_Branch: `polish/world-class-2026` · Date: 2026-05-26 · Author: Claude Opus 4.7_

This audit is the entry point for a comprehensive polish pass targeting
"more polished than Stripe, Linear, and Vercel combined — while staying
credible to Saudi government and Vision 2030 audiences."

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

| # | Issue | Where | Why it matters |
|---|---|---|---|
| P0-1 | **Four divergent token namespaces** across the 6 HTML files | index.html, login.html, contact.html, api.html, 404.html, reset-password.html | No single source of truth for color/type/spacing. Brand looks subtly different on every page. |
| P0-2 | **~8,700 lines of inline CSS** in `index.html` | index.html:392-8903, 21482-21523, 24292-24466 | Cannot be cached, makes diffs unreadable, blocks performance work (no critical CSS strategy possible). |
| P0-3 | **Two Saudi greens in production** | `#006C35` (canonical) vs `#007a3d` (api.html:52) | Brand integrity. Government audience will notice. |
| P0-4 | **No IBM Plex Sans Arabic** despite RTL claims; mix of Satoshi/Inter/Noto Kufi Arabic/Space Grotesk loaded ad-hoc per page | login.html:21-25 vs index.html:385 vs api.html:18 | Typography is a brand-identity primary. Each page reads as a different product. |
| P0-5 | **No proper RTL mirroring** beyond font-swap | All pages | "Stays credible to Saudi government audiences" requires real RTL: mirrored layouts, mirrored icons where directional, logical CSS properties (`margin-inline-start`), proper bidi text handling. |
| P0-6 | **Hero, opportunity listing, opportunity detail** are visually generic — no Vision 2030 or Saudi visual culture motif yet | index.html body | This is "the part the user wants to be surprised by." |

### P1 — meaningful polish

| # | Issue | Where | Why it matters |
|---|---|---|---|
| P1-1 | `alert()` in feedback form | script.js:119 | Not screen-reader-friendly; breaks design language. Replace with inline `aria-live` region. |
| P1-2 | 28 inline event handlers (`onclick=`, `onerror=`) | index.html | Mixes structure and behaviour; can't be CSP-tightened (currently allows `'unsafe-inline'`). Move to delegated listeners. |
| P1-3 | No proper loading skeletons; relies on JS-injected containers | script.js:51-58 (`ensureContainer`) | Loading flash looks unprofessional. Skeletons + intentional empty states needed. |
| P1-4 | 131 `box-shadow:` declarations, mostly hand-tuned | index.html | Soft Linear-style shadows are a brand cue; current values are inconsistent. Consolidate to 4-5 tokens. |
| P1-5 | 1,089 hex color literals (many duplicated between dark/light) | index.html | Tokenise everything that isn't a one-off accent. |
| P1-6 | No JSON-LD beyond what GitHub Pages might infer | All HTML | Even for noindex'd demo, schema preps for future. Organization + WebSite + Grant/GovernmentService per opportunity. |
| P1-7 | No bilingual hreflang | index.html head | `og:locale:alternate` exists but no `<link rel="alternate" hreflang>`. |
| P1-8 | No `<picture>`/AVIF/WebP for sector imagery | index.html:14674 | Sector card images load eager-ish via `loading="lazy"` only. |
| P1-9 | Inline `<script>` in `<head>` doing auth check, blocking render | index.html:7-56 | Pushing TTI later than necessary. Defer non-critical, inline only the auth boot. |

### P2 — quality-of-life

| # | Issue | Where | Why it matters |
|---|---|---|---|
| P2-1 | Hardcoded Supabase URL/key in two places | index.html:20-21, api/server.js:88-91 | Anon key + RLS is the design, but having it twice in source is a refactor smell. |
| P2-2 | DOM queries by `aria-label` text | script.js:13-23 | Brittle to copy changes. Use `data-*` hooks for behaviour, keep `aria-label` for users. |
| P2-3 | `audit-*/` and `enrichment-*/` weren't gitignored | repo root | Fixed in commit `9822564` on this branch. |
| P2-4 | No `.well-known/security.txt` | repo root | Not strictly required for a demo, but signals seriousness to government auditors. |
| P2-5 | Logo path falls through to `onerror` swatch fallback when asset missing | index.html:14674, theme manager | Works, but a real `<picture>` with AVIF + low-quality placeholder is the polished move. |
| P2-6 | No print stylesheet pass beyond a tiny block (lines 21482-21523) | index.html | Government users may print briefs. Bonus polish. |
| P2-7 | No `prefers-reduced-motion` audit | index.html CSS | 131 box-shadows and `--transition` token need a reduced-motion respect pass. |

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
