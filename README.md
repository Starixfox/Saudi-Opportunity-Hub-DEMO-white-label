# Saudi Opportunity Hub — Demo (White-label)

A private demo platform that aggregates **grants, tenders, accelerators, investment programs, and fellowships** relevant to Saudi Arabia, the GCC, and internationally — spanning 15 key sectors of Saudi Arabia's Vision 2030 economy.

> **Status**: Private demo build for internal evaluation and authorised stakeholder review. Not for public distribution. Not affiliated with, endorsed by, or representative of any government, authority, or program listed.

---

## What's in this repo

| File | Purpose |
| --- | --- |
| `index.html` | Single-page app: shell, sidebar, topbar, all views, CSS, JS |
| `login.html` | Supabase email/password sign-in |
| `reset-password.html` | Password reset flow |
| `contact.html` | Standalone contact / feedback form |
| `api.html` | Public API documentation page |
| `script.js` | Shared helpers loaded by static pages |
| `api/server.js` | Express read-only REST API in front of Supabase |
| `api/package.json` | API server dependencies (`express`, `cors`) |

The frontend is **vanilla JavaScript** (IIFEs, no framework). Charts via [Chart.js](https://www.chartjs.org/), icons via [Lucide](https://lucide.dev/), data + auth via [Supabase](https://supabase.com/).

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

## Data

The dataset lives in the Supabase project `dshrbbnjahjcwxzvzygh`. Tables consumed by the frontend:

| Table | Purpose |
| --- | --- |
| `opportunities` | Public dataset of programs (title, sponsor, sectors[], type, status, eligibility_region, profiles[], etc.) |
| `user_watchlist` | Per-user saved opportunities (`{user_id, opp_id}`) |
| `user_prefs` | Per-user preferences blob (`{user_id, prefs, updated_at}`) |
| `user_searches` | Saved search filters per user |

Anon-key auth + Supabase Row Level Security gates everything user-specific.

## Internationalisation

Two complementary mechanisms ship side-by-side:

1. **Static translations** via `data-ar` / `data-en` attributes — fast, no network, covers all known UI strings.
2. **Dynamic translation** via the public Google Translate endpoint for runtime-injected strings (opportunity cards, etc.). Toggle with the language button in the topbar; cached in `localStorage` (`oh-ar-cache-v2`).

`html[dir="rtl"]` flips layout and font.

## Running locally

### Frontend

The frontend is fully static — open `index.html` in a browser, or serve the directory with any static server. It calls Supabase directly from the browser.

```bash
python3 -m http.server 8080
# then visit http://localhost:8080/login.html
```

### API server (optional)

```bash
cd api
npm install
SUPABASE_URL=https://<project>.supabase.co \
SUPABASE_ANON_KEY=<anon-key> \
npm start
```

Endpoints:

- `GET /api/opportunities` — filters: `q`, `sector`, `region`, `type`, `status`, `profile`; pagination: `page`, `limit`
- `GET /api/opportunities/:id`
- `GET /api/stats`
- `GET /api/meta`
- `GET /api/health`

## Browser support

Modern evergreen browsers (Chromium 100+, Firefox 100+, Safari 15+). The page is responsive down to ~360px and exposes a mobile bottom-tab bar under 768px.

## Accessibility

- Skip-to-content link at the top of `<body>` for keyboard / screen-reader users.
- `<noscript>` fallback explaining the JS requirement.
- ARIA labels and roles on all primary navigation, dialogs, charts, and inputs.
- Focus trap inside modals and panels; Escape dismisses them.

## Security notes

- The Supabase **anon** key is intentionally embedded in the client — that is its design contract. Database access is gated by Row Level Security policies on Supabase.
- A strict CSP locks `connect-src` to Supabase + the Google Translate endpoint and `script-src` to jsdelivr + unpkg.
- All DB-sourced strings are escaped via `esc()` before being injected as HTML.
- `noindex, nofollow` is set because this is a private demo.

## Reporting issues / contributing

Use the in-app **Feedback** form (About view) to suggest additions, corrections, or partnerships. Internal reviewers can email <jblancoapodaca@gmail.com>.

## License

Private — all rights reserved. Not for public distribution.
