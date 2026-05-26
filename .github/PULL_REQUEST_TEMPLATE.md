## What this PR changes

<!-- One or two sentences. What does it actually do, not why. -->

## Why

<!-- The change in context. Reference an audit row, an issue number, or
     the brand/voice rationale. Examples:
       - "Closes #13 — bump .btn to 44px"
       - "polish/AUDIT.md row P1-8 — AVIF/WebP for sector imagery"
       - "BRAND.md success-state rule — past tense, no celebration"
-->

## How to verify

<!-- Concrete steps. -->

- [ ] CI: polish-quality-gate green
- [ ] Visual: hard-refresh `/login.html` (and any SPA view this touches)
- [ ] Lighthouse: `scripts/run-lighthouse.sh` deltas are within tolerance
- [ ] If behind-auth: ran `scripts/smoke.spec.mjs` with throwaway test creds
- [ ] Light + dark mode look correct
- [ ] RTL (`?lang=ar` or `dir="rtl"`) still works

## Risk

<!-- What could break? Any reason to roll back fast? -->

## Polish-pass invariants this should NOT break

- [ ] No new inline `onclick=` HTML attributes (use `data-action` + delegated handler)
- [ ] CDN scripts still pinned to exact versions with `integrity=` + `crossorigin="anonymous"`
- [ ] No hardcoded Saudi greens (`#006C35` etc.) — use `var(--accent)` so white-label themes work
- [ ] tokens.css / legacy-app.css remain brace-balanced (CI checks)
- [ ] WCAG AA contrast preserved on the three text tokens

## Screenshots / diffs

<!-- Before/after, or a one-line `git diff --stat`. -->
