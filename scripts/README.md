# Polish-pass helper scripts

Scripts you can run locally to close out the polish-pass follow-up issues
([#13](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/13),
[#15](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/15),
[#16](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/16),
[#17](https://github.com/Starixfox/Saudi-Opportunity-Hub-DEMO-white-label/issues/17))
that the polish-pass agent couldn't finish without credentials or a
local image-processing toolchain.

## `run-lighthouse.sh` — closes #17

Runs Lighthouse against the live URL on `login.html` and `showcase.html`
and writes JSON + HTML reports to `polish/lighthouse/`. Needs Chrome
installed at the system default path.

```bash
./scripts/run-lighthouse.sh
```

**Current baseline** (from the polish-pass run, login.html):

| Score          | Value | Notes |
|----------------|-------|-------|
| Performance    | 97    | LCP 2.1s, TBT 0ms, CLS 0.0006 |
| Accessibility  | 96    | one missing label on the bot-detection challenge |
| Best Practices | 96    | clean |
| SEO            | 54    | `noindex,nofollow` meta (intentional for demo) + `Disallow: /` in robots.txt — both flip when the demo goes public |

## `build-sector-images.mjs` — closes #15

Downloads the Unsplash sector imagery referenced by `sectorImg()` in
`index.html`, generates AVIF + WebP variants via `sharp`, writes them
to `assets/sectors/`, and prints a `<picture>` template the SPA can
adopt. Needs `npm install sharp` once.

```bash
npm install --no-save sharp
node scripts/build-sector-images.mjs
```

Output:
- `assets/sectors/<sector>.avif`
- `assets/sectors/<sector>.webp`
- `assets/sectors/<sector>.jpg` (fallback)
- `polish/picture-template.html` — paste this `<picture>` snippet into
  the `sectorImg()` template literal

## `smoke.spec.mjs` — closes #13 + #16

Playwright spec that:
1. Logs in via Supabase using credentials from environment variables
2. Exercises every `data-action` button from the polish-pass delegation
   refactor (`open-panel`, `open-settings`, `set-route`, `new-this-week`,
   `reload`, `reset-filters`, `toggle-bookmark`, `la-compare`)
3. Asserts the expected SPA reaction (route changes, panel opens,
   modal opens)
4. Captures full-page screenshots of the dashboard / opportunities /
   sectors / saved views — both before and after a hypothetical
   `.btn { min-height: 44px }` change so the visual regression for
   issue #13 is reviewable as image diffs

```bash
npm install --no-save @playwright/test
npx playwright install chromium

# Credentials NEVER stored in repo or version-controlled config.
# Pass them in via environment for a single run:
OH_TEST_EMAIL="your@email" \
OH_TEST_PASSWORD="…" \
npx playwright test scripts/smoke.spec.mjs --headed
```

Output:
- Pass/fail summary on each of the 12 data-action paths (issue #16)
- Screenshots in `test-results/` for visual diff (issue #13)
