# Saudi Opportunity Hub — Demo (White-label)

A private demo platform that aggregates **grants, tenders, accelerators, investment programs, and fellowships** relevant to Saudi Arabia, the GCC, and internationally — spanning 15 key sectors of Saudi Arabia's Vision 2030 economy.

> **Status**: Private demo build for internal evaluation and authorised stakeholder review. Not for public distribution. Not affiliated with, endorsed by, or representative of any government, authority, or program listed.

---

## What's in this repo

| File | Purpose |
| --- | --- |
| `index.html` | Single-page app: shell, sidebar, topbar, all views |
| `login.html` | Supabase email/password sign-in |
| `reset-password.html` | Password reset flow |
| `contact.html` | Standalone contact / feedback form |
| `api.html` | Public API documentation page |
| `404.html` | Custom not-found page |
| `manifest.webmanifest` | PWA manifest (installable) |
| `robots.txt` / `sitemap.xml` | SEO basics |
| `script.js` | Shared helpers loaded by static pages |
| `assets/tokens.css` | Design tokens — single source of truth (colour, type, spacing, shadows, motion, light/dark/RTL) |
| `assets/styles.css` | Foundation utilities — reset, `.btn`, `.card`, `.pill`, `.skeleton`, `.skip-link`, `.bg-mashrabiya` |
| `assets/opportunity-schema.js` | Per-opportunity JSON-LD emitter (Grant / GovernmentService / EducationalOccupationalProgram). Called by `openPanel()` / `closePanel()` in `index.html`. |
| `polish/BRAND.md` | Brand voice — attributes, do/don't, GCC funding terminology, bilingual rules |
| `polish/DESIGN_SYSTEM.md` | Design system reference — layer model, theming, components |
| `polish/AUDIT.md` | Polish-pass audit with prioritised punch list |
| `polish/showcase.html` | Public design-system showcase + QA harness ([live](https://starixfox.github.io/Saudi-Opportunity-Hub-DEMO-white-label/polish/showcase.html)) |

The frontend is **vanilla JavaScript** (IIFEs, no framework). Charts via [Chart.js](https://www.chartjs.org/), icons via [Lucide](https://lucide.dev/), data + auth via [Supabase](https://supabase.com/).

> The `api/` folder contains an older Express proxy that is no longer deployed. The site now talks to Supabase REST (PostgREST) directly from the browser.

## Architecture

```
┌──────────────────┐      ┌──────────────────────────────┐
│  Static frontend │──────│  Supabase                    │
│  (HTML + JS)     │      │   • Auth (email/pw + OAuth)  │
│  GitHub Pages    │      │   • Postgres + RLS           │
│                  │      │   • PostgREST (rest/v1)      │
└──────────────────┘      └──────────────────────────────┘
```

## Design system

The platform's visual identity lives in a three-layer token system, all in
`assets/tokens.css`:

```
Primitive   --color-green-600, --space-4, --text-lg, --ease-out
                 ↓
Semantic    --accent, --surface, --text, --border, --shadow-md
                 ↓
Component   .btn-primary { background: var(--accent); … }
```

Components reference **semantic** tokens (`var(--accent)`, `var(--surface)`).
Primitives are only used when a semantic role doesn't exist yet — and at
that point the answer is usually to add the role to `tokens.css`, not to
hardcode.

- **Brand**: Saudi green `#006C35` (canonical) is the `--accent`. Gold
  `#C9A66B` is the secondary moment. The platform's 7-tenant white-label
  registry (`window.OH_THEMES`) overrides `--accent` per tenant, so
  components never need to know which theme is active.
- **Type**: Inter (body) + Space Grotesk (display) + IBM Plex Sans Arabic
  (automatically swapped in when `dir="rtl"`). 6-step fluid scale via
  `clamp()`.
- **Spacing**: 4px base scale, `--space-1` (4px) through `--space-32`
  (128px). The skipped values (`--space-7`, `--space-9`…) are deliberate.
- **Shadows**: Linear-style two-layer (tight + diffuse), 6 tokens. Dark
  mode boosts alpha automatically.
- **Motion**: Default ease `cubic-bezier(0.16, 1, 0.30, 1)`, default
  duration 220ms. `prefers-reduced-motion: reduce` flattens all durations
  to 0ms and easings to linear.
- **RTL**: `dir="rtl"` automatically swaps `--font-sans` to the Arabic
  family and flattens letter-spacing tokens. Use logical properties
  (`margin-inline-start`, `padding-inline-end`) for everything except
  absolutely positioned overlays.

The full reference + every component rendered in light, dark, and RTL
side-by-side lives at **[`polish/showcase.html`](polish/showcase.html)**.
Brand voice (do/don't, GCC funding terminology, bilingual rules) is in
**[`polish/BRAND.md`](polish/BRAND.md)**.

## Views

- **Home** — personalised landing: greeting, KPIs, "new this week", watchlist snapshot, sector chips.
- **Dashboard / Analytics** — KPI cards, opportunities by sector / type / status / region (Chart.js doughnuts and bars).
- **Opportunities** — filterable, sortable list with detail panel, watchlist toggle, saved searches.
- **Sectors** — chip grid that drives the opportunities filter.
- **Saved** — user watchlist mirror (Supabase-synced).
- **About** — methodology, scope tiers (Saudi / GCC / international), audience cards, feedback form.

## Workspace, settings, notifications

- **Workspace panel**: Watchlist · Saved Searches · Recent · Get Started checklist.
- **Settings modal**: Display name, role, organisation, sector interests (drives recommendations).
- **Notifications dropdown** with badge.

## Audience

| Profile | What they get |
|---|---|
| Startups / SMEs | Non-dilutive grants, accelerators, equity programs |
| Researchers / Universities | Research grants, fellowships, lab partnerships |
| Government | Tenders, partnership programs, intergovernmental schemes |
| Investors | Co-investment funds, equity programs, sovereign vehicles |
| Students | Scholarships, fellowships, training programs |

## Data

The dataset lives in the Supabase project `dshrbbnjahjcwxzvzygh`. Tables consumed by the frontend:

| Table | Purpose |
| --- | --- |
| `opportunities` | Public dataset of programs (title, sponsor, sectors[], type, status, eligibility_region, profiles[], etc.) |
| `user_watchlist` | Per-user saved opportunities (`{user_id, opp_id}`) |
| `user_prefs` | Per-user preferences blob (`{user_id, prefs, updated_at}`) |
| `user_searches` | Saved search filters per user |

Anon-key auth + Supabase Row Level Security gates everything user-specific.

The opportunity rows cover **15 sectors** (ICT, Healthcare & Life Sciences, Energy, Agriculture, Education, Financial Services, Tourism, Mining, Manufacturing, Transport & Logistics, Real Estate, Sports, Entertainment, Innovation & Entrepreneurship, Environment) and **3 region scopes** — Saudi Arabia (`SA-`), GCC (`GCC-`), Global (`GL-`).

## Internationalisation

Two complementary mechanisms ship side-by-side:

1. **Static translations** via `data-ar` / `data-en` attributes — fast, no network, covers all known UI strings.
2. **Dynamic translation** via the public Google Translate endpoint for runtime-injected strings (opportunity cards, etc.). Toggle with the language button in the topbar; cached in `localStorage` (`oh-ar-cache-v2`).

`html[dir="rtl"]` flips layout and font.

## Running locally

The frontend is fully static — open `login.html` in a browser, or serve the directory:

```bash
npx serve .
# or
python3 -m http.server 8080
# then visit http://localhost:8080/login.html
```

No backend to run — auth and data come from Supabase directly.

## Public API (Supabase REST / PostgREST)

The opportunities dataset is read directly from Supabase's auto-generated REST API. See [`api.html`](api.html) for the full reference; quick examples:

```bash
# Base URL
BASE="https://dshrbbnjahjcwxzvzygh.supabase.co/rest/v1"
KEY="<anon-key>"   # same anon key the frontend uses

# List opportunities (with filters)
curl "$BASE/opportunities?select=id,title,type,status&status=eq.open&limit=10" \
  -H "apikey: $KEY"

# Single opportunity
curl "$BASE/opportunities?id=eq.SA-001&select=*" \
  -H "apikey: $KEY" \
  -H "Accept: application/vnd.pgrst.object+json"

# Filter by sector (array contains)
curl "$BASE/opportunities?select=*&sectors=cs.{ict}&status=eq.open"
```

Useful PostgREST features: `select=` (column projection), `eq.`, `in.`, `cs.` (array contains), `ilike.` (case-insensitive search), `order=`, `limit=` / `offset=`, and the `Range` header for pagination.

## Browser support

Modern evergreen browsers (Chromium 100+, Firefox 100+, Safari 15+). The page is responsive down to ~360px and exposes a mobile bottom-tab bar under 768px.

## Accessibility

- Skip-to-content link at the top of `<body>` for keyboard / screen-reader users (the `.skip-link` utility is in `assets/styles.css`).
- `<noscript>` fallback explaining the JS requirement.
- 230+ ARIA labels and roles across navigation, dialogs, charts, and inputs.
- Focus trap inside modals and panels; Escape dismisses them.
- Every interactive element renders a `--focus-ring` (3px accent-coloured glow) on `:focus-visible`. Focus colour is theme-aware (Saudi green light, lifted green dark).
- `@media (prefers-reduced-motion: reduce)` zeroes all token durations and flattens easings; skeleton shimmer goes static at 60% opacity.
- Status pills carry redundant visual cues (icon-dot + colour + label text) so colour alone never carries meaning.

## SEO &amp; AI visibility

Even though the live demo is intentionally `noindex,nofollow` (lift via
`robots.txt` + the meta tag on each page when ready for public launch),
the structured-data surface is built so the platform is ready to be
cited by AI crawlers (ChatGPT, Perplexity, Claude) and indexed cleanly
by traditional search:

- **Head-level JSON-LD** on `index.html`, `login.html`, `contact.html`:
  `Organization` + `WebSite` (+ `ContactPage` on contact), graph-linked
  via `@id` so search engines see the publisher relationship.
- **Bilingual `hreflang`** (en, ar, x-default) declared on `index.html`.
- **Per-opportunity JSON-LD** is emitted live by `assets/opportunity-schema.js`
  whenever a user opens an opportunity panel — picks the right schema
  type (`Grant`, `MonetaryGrant`, `GovernmentService`,
  `EducationalOccupationalProgram`, `FundingScheme`) based on the
  opportunity's internal `funding_type`. Funder, area served (KSA/GCC/
  global typed as `Country` / `AdministrativeArea` / `Place`),
  `applicationDeadline`, `eligibilityCriteria`, and amount (as a
  `MonetaryAmount` defaulting to SAR) are all populated. The script is
  wired into `openPanel()` / `closePanel()` so each navigation refreshes
  the in-DOM schema.
- `SearchAction` declared in the WebSite node points crawlers at the
  in-app `#opportunities` hash route so AI assistants can model the
  platform's search surface.

## Security notes

- The Supabase **anon** key is intentionally embedded in the client — that is its design contract. Database access is gated by Row Level Security policies on Supabase.
- A strict CSP locks `connect-src` to Supabase + the Google Translate endpoint and `script-src` to jsdelivr + unpkg.
- All DB-sourced strings are escaped via `esc()` before being injected as HTML.
- `noindex, nofollow` is set because this is a private demo.
- Supabase enforces Row Level Security policies + rate limiting at the edge.

## Reporting issues / contributing

Use the in-app **Feedback** form (About view) to suggest additions, corrections, or partnerships. Internal reviewers can email <jblancoapodaca@gmail.com>.

## License

Private — all rights reserved. Not for public distribution.
