# Security policy

> A more machine-readable version of this policy lives at
> [`.well-known/security.txt`](.well-known/security.txt) per
> [RFC 9116](https://datatracker.ietf.org/doc/html/rfc9116).

## Reporting a vulnerability

**Email**: <jblancoapodaca@gmail.com>

Please don't open public issues for security findings. Use email so
we can coordinate disclosure responsibly.

## What to report

- Anything that could expose user accounts, watchlists, or saved searches
- RLS bypasses in the Supabase project that allow reading or writing data
  outside of the authenticated user's scope
- XSS, CSRF, or clickjacking vectors in any of the public-facing pages
  (`index.html`, `login.html`, `contact.html`, `api.html`, `404.html`,
  `reset-password.html`)
- Misconfigurations in the `Content-Security-Policy` `<meta>` tags or in
  the GitHub Pages hosting layer
- Supply-chain concerns affecting the SRI-pinned CDN scripts
  (`@supabase/supabase-js@2.45.4`, `chart.js@4.4.1`, `lucide@0.469.0`,
  `jspdf@2.5.2`) — these all carry `integrity=` and `crossorigin="anonymous"`

## Out of scope

- Social-engineering or phishing against staff
- DoS / volumetric attacks
- Findings against third-party services we link to but don't control
  (Supabase, Formspree, GitHub Pages, jsDelivr, Google Fonts)

## What we'll do

- Acknowledge receipt within **one business day**
- Triage the report within **three business days**
- Coordinate a fix and disclosure timeline with you
- Credit you publicly in the [CHANGELOG](CHANGELOG.md) if you'd like

## What we won't do

- Pay a bounty (this is a private demo; we don't run a bug-bounty programme)
- Disclose your identity without your explicit permission

## Supported versions

Only the current `main` branch is supported. There are no historical
release branches to backport into.

## Existing hardening

For context, the polish pass (see [CHANGELOG.md](CHANGELOG.md)) shipped:

- All four CDN dependencies pinned to exact versions + SRI-verified
- `Content-Security-Policy` `<meta>` tags on every public HTML page
  restricting `connect-src`, `script-src`, `style-src`, `font-src`,
  `img-src`, `frame-ancestors 'none'`, `form-action`, `object-src 'none'`
- `X-Content-Type-Options: nosniff` on every page
- `Referrer-Policy: strict-origin-when-cross-origin`
- `noindex, nofollow` on every page (demo phase)
- The Supabase **anon** key is intentionally embedded in the client — that
  is its design contract. Database access is gated by Row Level Security
  policies on Supabase. Server-side write access requires a separate
  service-role key, which is never embedded
- A CI quality gate ([`.github/workflows/polish-quality-gate.yml`](.github/workflows/polish-quality-gate.yml))
  prevents accidentally removing SRI hashes or unpinning CDN scripts
