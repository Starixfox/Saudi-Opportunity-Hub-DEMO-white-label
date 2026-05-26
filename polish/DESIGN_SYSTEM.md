# Saudi Opportunity Hub — Design System

_Companion to `assets/tokens.css` (the source of truth) and `assets/styles.css`
(foundation utilities). Read this to understand how to use them._

---

## Architecture: three layers

```
┌─ Primitive ───── --color-green-600, --space-4, --text-lg, --ease-out
│                  Raw values. Never reference from a component.
│
├─ Semantic ────── --accent, --surface, --text, --border, --shadow-md
│                  Role-bound. **These are what components reference.**
│                  Light & dark themes swap these; primitives stay still.
│
└─ Component ──── .btn-primary { background: var(--accent); ... }
                  Lives inside the component's own stylesheet. Names like
                  --kpi-bg or --opp-card-radius go here, not in tokens.css.
```

**Rule:** when authoring a component, use semantic tokens (`var(--accent)`,
`var(--surface)`). Drop down to primitives (`var(--color-green-600)`) only
when the role doesn't exist yet — and at that point, ask whether the role
should be added to `tokens.css` instead.

---

## What's where

| File | Role | When you touch it |
|---|---|---|
| `assets/tokens.css` | The single source of truth for colour, type, spacing, motion. Light + dark + RTL + reduced-motion + print. | Adding a new token; reskinning the system; adjusting a value globally. |
| `assets/styles.css` | Foundation reset + utilities (`.btn`, `.card`, `.pill`, `.skeleton`, `.bg-mashrabiya`, `.sr-only`, `.skip-link`). | Adding a primitive component reused across multiple pages. |
| Page-specific inline `<style>` | Legacy: page-specific component rules. Migrating into `styles.css` and per-component files during Phase 2 extraction. | Existing pages until refactored; new pages should avoid it. |

---

## Colour

### Saudi green is the brand. Use it sparingly.
- `--accent` (= `--color-green-600` = `#006C35`) — primary CTAs, links, active states, key statuses, sidebar active indicator.
- `--accent-soft` (10% alpha) — soft fills like hover backgrounds.
- `--accent-glow` (25% alpha) — focus rings, subtle highlight.
- **Do not** flood a hero or body background with the accent. It should
  appear in moments, not surfaces.

### Gold is the secondary accent. Treat it as a luxury.
- `--gold` (= `#C9A66B`) — premium / verified / milestone moments only.
  If everything is gold, nothing is.

### The neutral ramp is where 90% of the UI lives.
- 9 steps from `--color-neutral-50` (near-white) to `--color-neutral-900` (near-black) plus pure `0` and `950`.
- Semantic aliases: `--surface`, `--surface-raised`, `--surface-sunken`, `--bg-app`, `--bg-marketing`, `--text`, `--text-muted`, `--text-faint`.

### Status
- Open / Closed / Review have semantic colour triples (bg / text / border) tuned for both light and dark themes.

### White-label safety
- `--accent` is intentionally overridable by the existing
  `window.OH_THEMES → applyTheme()` mechanism in `index.html`. Each
  white-label tenant (MISA, Monsha'at, ADIO, NEOM, SDB, Swift Solve) sets
  its own brand colour by writing `--accent` and friends on `:root`.
  **Do not** hardcode `#006C35` in components; always use `var(--accent)`.

---

## Type

### Two families. No third unless explicitly added here.
- **Latin/body**: Inter (300-700)
- **Display**: Space Grotesk (500-700) — for headings + hero only
- **Arabic**: IBM Plex Sans Arabic — applied automatically when `dir="rtl"`
- **Mono**: JetBrains Mono — code blocks only, loaded only on pages that need it

### Scale is fluid via `clamp()`
- `--text-xs` through `--text-2xl` for body and UI
- `--text-display` for hero — scales from 2.5rem → 5.5rem with viewport
- Never hand-type `font-size: 18px` again. Pick a token.

### Headings
- `<h1>` → `--text-2xl`, font-display, semibold, tight leading, slight negative tracking
- `<h2>` → `--text-xl` … etc.
- The `.h-display` class is for hero-scale display — bigger than `<h1>`, used at most once per page.

### Eyebrow / lede
- `.eyebrow` — uppercased label above a heading, accent-coloured
- `.lede` — larger intro paragraph below a heading, muted

---

## Spacing

4px base scale: `--space-1` (4px) through `--space-32` (128px). Always use
tokens. The handful of skipped values (`--space-7`, `--space-9`, etc.) are
deliberate — if you need them, you're spacing too precisely.

---

## Shadows

Linear-style: every shadow stacks two layers (tight + diffuse). Light mode
uses low-alpha slate; dark mode boosts alpha and switches to near-black so
the shadows remain visible on dark backgrounds.

- `--shadow-xs` — keylines, divider depth
- `--shadow-sm` — buttons, small cards, default elevation
- `--shadow-md` — hovered cards, dropdowns
- `--shadow-lg` — modals, popovers
- `--shadow-xl` — major surfaces (drawer, sheet)
- `--shadow-2xl` — full overlays
- `--shadow-inner` — inset for inputs / wells

**Don't roll your own.** Six shadow tokens is the whole library.

---

## Motion

All motion uses the `--ease-out` curve by default (Linear's house curve).
Durations cap at `--duration-base` (220ms) for in-flow UI; `--duration-slow`
(320ms) for page transitions; `--duration-slower` (480ms) only for hero
reveals.

```css
.thing {
  transition: var(--transition-color), var(--transition-transform);
}
```

`prefers-reduced-motion: reduce` flattens all durations to 0ms and easings
to linear. Build accordingly — never assume animations will play.

---

## RTL

```html
<html dir="rtl" lang="ar">
```

When `dir="rtl"`:
1. `--font-sans` automatically switches to `--font-arabic` (IBM Plex Sans Arabic).
2. Letter-spacing tokens flatten to 0 (Latin tight tracking looks wrong in Arabic).
3. Components using logical CSS properties (`margin-inline-start`,
   `padding-inline-end`, `border-inline-start`) mirror automatically.
4. Components using physical properties (`margin-left`, `text-align: left`)
   **need to be migrated** — they break in RTL.

**Rule**: prefer logical properties (`*-inline-*`, `*-block-*`) over physical
(`*-left`, `*-right`, `*-top`, `*-bottom`) for everything except absolutely-
positioned overlays.

---

## Themes (white-label)

The platform supports 7 themed skins today via `window.OH_THEMES`:
default, misa, monshaat, adio, neom, sdb, swift-solve.

Each theme sets its own `--accent` and friends. The semantic-token
architecture means nothing downstream of `--accent` needs to know which
theme is active — components just read `var(--accent)`.

**When adding a new themed value** (e.g., a tenant logo), put it on the
theme object (`window.OH_THEMES['xyz']`) and let `applyTheme()` push it
into a CSS variable. Don't hardcode tenant colours in stylesheets.

---

## Adding a new component

1. Check if `.btn`, `.card`, `.pill`, or another utility in `styles.css`
   already covers it. Reuse beats reinvent.
2. If not, give it a unique class prefix (e.g., `.opp-card-`, `.kpi-`,
   `.hero-`) and put the styles in either `styles.css` (if reused) or a
   page-specific block (if not yet).
3. Reference only **semantic** tokens. If your component needs a colour
   that isn't in the semantic layer, add it to `tokens.css` first.
4. Test light + dark + RTL + reduced-motion before merge.
5. Document the component's variants and states in this file, in the
   "Components" section below (TODO during Phase 3).

---

## Components (to be filled in during Phase 3)

- [ ] Hero
- [ ] Opportunity card
- [ ] Opportunity detail panel
- [ ] Filter sidebar
- [ ] Search bar
- [ ] Pagination
- [ ] Empty state
- [ ] Error state
- [ ] 404
- [ ] Sign-in form
- [ ] Contact form
- [ ] API doc layout
- [ ] Navigation rail
- [ ] Footer

---

## What this system intentionally does NOT do

- **No CSS-in-JS runtime.** This is static CSS, hand-authored, served as
  files. The decision was deliberate: GitHub Pages, no build step, zero
  third-party styling deps.
- **No Tailwind / Bootstrap / Material.** Utilities live in `styles.css`,
  named for the role they play (`.btn-primary`, `.card`), not for the
  property they set.
- **No theme builder UI surface yet.** The 7 white-label themes are
  authored in `index.html`. A theme builder is a Phase 4+ idea.
- **No iconography token system yet.** Icons are inline SVGs sized in
  `em` so they scale with text. A Phase 3 polish task is to standardise
  on a single icon family and size scale.
