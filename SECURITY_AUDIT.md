# Security Audit — 2026-05-19

Pre-launch security review of the Saudi Opportunity Hub. Scope: frontend, auth flow, admin path, Supabase RLS, key/secret exposure, HTTP/browser protections, common web-app risks.

Status: **5 Critical + 2 High issues found, all fixed in code/policy.** Lower-severity items and manual-launch checks listed at the bottom.

---

## 1. Architecture map

| Layer | What's there |
|---|---|
| Hosting | GitHub Pages static (`index.html`, `login.html`, `reset-password.html`, `contact.html`, `api.html`, `404.html`, `script.js`) |
| Auth | Supabase Auth (email + password, OAuth Google/Microsoft hooks present). Login redirects to `index.html`; `index.html` redirects to `login.html` if no session. |
| Data | Supabase Postgres (`dshrbbnjahjcwxzvzygh`) accessed directly from browser via PostgREST + anon key (intentional). |
| Admin gate | `is_admin()` SQL function returns `true` if the caller's row in `user_prefs.role = 'admin'`. Frontend mirrors this into `window.__ohIsAdmin` to show/hide UI (UI-only, RLS enforces the real boundary). |
| "Super-admin" | Hardcoded `__OH_OWNER_UID` constant in `index.html` (UID `72f017e5-…61548`). UI-only gate for the Theme Manager card. Not a security boundary on its own. |
| Tables (10 in `public`) | `profiles`, `user_prefs`, `user_searches`, `user_watchlist`, `user_folders`, `folder_items`, `activity_log`, `opportunities`, `opportunities_archive`, `opportunities_review` |
| Headers | Static-hosted → no custom HTTP headers. CSP via `<meta http-equiv>` on every HTML page. |
| Legacy API | `api/server.js` (Express proxy, not deployed) — `helmet`-style headers, rate limit, CORS allowlist, input sanitization. Read-only. |

---

## 2. Findings

### CRITICAL

#### C1. Self-promotion to admin via `user_prefs.role` *(fixed)*

**Path.** `is_admin()` reads `user_prefs.role`. The `user_prefs_self` policy allowed any signed-in user to INSERT/UPDATE their own row (correct ownership), but the policy had no column-level restriction. So a normal user could call:

```sql
INSERT INTO user_prefs (user_id, role) VALUES (auth.uid(), 'admin')
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
```

…and immediately satisfy `is_admin()`. With that, they gained:
- INSERT / UPDATE / DELETE on `opportunities`
- SELECT on every user's `profiles`, `user_prefs`, `user_watchlist`
- Theme-manager writes to other users' `user_prefs`

The same vector existed on `profiles.role` via "Users can update own profile" (column-unrestricted).

**Fix.** Migration `2026_05_19_security_hardening.sql` installs a `BEFORE INSERT/UPDATE` trigger on both `user_prefs` and `profiles` that clamps the `role` column:
- non-admin INSERT → `role := 'user'`
- non-admin UPDATE → `NEW.role := OLD.role`
- `auth.uid() IS NULL` (service_role / MCP) → passthrough so the platform owner can still be bootstrapped or rotated

The function is `SECURITY DEFINER` so it can verify caller-is-admin even if RLS would otherwise hide the answer.

**Verify.** Sign in as a normal user and try `UPDATE user_prefs SET role='admin' WHERE user_id = auth.uid()`. The row will be re-written with the old `role` value; the role does not change. Same for `UPDATE profiles SET role='admin' WHERE id = auth.uid()`.

#### C2. `profiles` publicly readable via wildcard admin policy *(fixed)*

**Path.** Policy `"Admin can read all profiles"` was `roles=public, qual=true`. With permissive policies OR'd, this overrode the per-user policy. Anonymous requests with just the anon key could enumerate **every user's email, first/last name, organisation, last_active**.

**Fix.** Dropped, replaced with `admin_select_all_profiles` (`roles=authenticated, qual=is_admin()`). `"Users can view own profile"` (`auth.uid() = id`) remains.

**Verify.** Without a session, `GET /rest/v1/profiles?select=*` returns `[]`. With a non-admin session, only the caller's own row. With an admin session, all rows.

#### C3. `activity_log` publicly readable AND deletable *(fixed)*

**Path.** `"Admin can read all activity"` and `"Admin can delete activity"` both had `roles=public, qual=true`. Anonymous requests could read every user's action history and DELETE the table.

**Fix.** Dropped both. Added `admin_select_all_activity` and `admin_delete_activity` (both `is_admin()`). Added `user_select_own_activity` so a regular user can see their own log (no such policy existed before — the only working SELECT was the broken admin one).

**Verify.** Without session: SELECT returns `[]`, DELETE returns 0 rows. With user session: SELECT returns only that user's rows. With admin session: SELECT returns all rows.

#### C4. `opportunities_review` and `opportunities_archive` publicly readable *(fixed)*

**Path.** Both had `*_public_read` policies (`roles=public, qual=true`). The review queue is supposed to be internal triage (rejected/in-review programs, including the AI digest output before manual approval). Archive contains opportunities removed from the public dataset. Both were readable by any browser hitting the REST API.

**Fix.** Dropped both `*_public_read` policies. Added admin-only SELECT and ALL policies on each.

**Verify.** Without/with non-admin session: both tables return `[]`. With admin session: full read/write.

#### C5. `"Only admins can set user themes"` policy had `WITH CHECK (true)` *(fixed)*

**Path.** That policy let any admin UPDATE *any column* on *any user's* `user_prefs` row. Combined with C1, an attacker who promoted themselves could promote others or scramble their preferences. Even with C1 fixed, this is over-broad (admins shouldn't be able to silently change another user's saved search filters or notification settings).

**Fix.** Dropped, replaced with `admin_update_any_user_prefs` (still permits admin UPDATE for the theme-management feature) AND the role trigger now blocks role-column writes regardless of which policy let the UPDATE through. If you want admins to be restricted to *only* the `theme` column going forward, harden this further with a per-column trigger.

### HIGH

#### H1. Frontend CSP allowed dynamic-code-execution permission *(fixed)*

**Path.** `index.html` CSP included the unsafe-eval permission. There are zero dynamic-code-execution calls in the codebase, so this was wasted attack surface.

**Fix.** Removed from index.html CSP. Also added `frame-ancestors 'none'` (clickjacking), `base-uri 'self'` (base-tag injection), `form-action 'self' https://formspree.io`, `object-src 'none'`, plus `X-Content-Type-Options: nosniff` and `Referrer-Policy: strict-origin-when-cross-origin` via `<meta>`.

**Verify.** Open DevTools → Network → reload `index.html`. The CSP header (via meta) no longer lists the unsafe-eval permission. Page still renders and Chart.js / Lucide / jsPDF still work.

#### H2. `login.html`, `reset-password.html`, `contact.html`, `api.html`, `404.html` had no CSP *(fixed)*

**Path.** Only `index.html` had CSP/security meta tags. The unauthenticated entry pages had nothing — any inline script injected by an upstream proxy or via a future code regression would execute freely.

**Fix.** Added a CSP appropriate to each page's actual dependencies (Supabase + jsdelivr + Google Fonts + Fontshare for the auth pages; just Google Fonts for 404; Supabase + Fontshare for api.html; Formspree for contact.html). Also added `X-Content-Type-Options: nosniff` and the referrer policy.

**Verify.** View source on each page — CSP meta tag is present and references only the domains that page actually uses.

### MEDIUM

#### M1. `profiles.role` and `user_prefs.role` are two parallel admin signals

Both columns exist, both can hold `'admin'`. `is_admin()` only consults `user_prefs.role`. The frontend ever-so-slightly inconsistently looks at one or the other. The trigger now protects both, but the recommendation is to pick one source of truth and remove the other. The migration leaves both because removing a column is a larger refactor and the live frontend reads both.

#### M2. Frontend admin gating relies on a global flag (`window.__ohIsAdmin`)

A motivated user with DevTools can flip `window.__ohIsAdmin = true` and see the admin sidebar render. This is **not** a security issue right now — every actual admin operation goes through Supabase RLS, which is the real boundary. But the *appearance* of admin UI revealing data could be misread as a leak. Worth noting in QA: "admin UI visible" ≠ "admin data accessible". RLS will continue to return `[]` for anything the user isn't entitled to.

#### M3. `contact.html` POSTs to Formspree without CAPTCHA or rate limit

The form is reachable without auth, with no bot friction. Formspree itself has spam filtering, but if abused it could exhaust the Formspree quota. Consider adding a hCaptcha / honeypot, or moving the form behind auth.

#### M4. Anon-key embedded in HTML (by design, but worth re-stating)

Supabase's design contract puts the anon key in the browser. With the policy fixes above, the worst an attacker can do with the anon key alone (no session) is read `opportunities` (intentionally public). Everything else returns `[]` or `401`.

### LOW

#### L1. `__OH_OWNER_UID` is a hardcoded constant in `index.html`

Not a security boundary (RLS enforces the real one) but means rotating the platform owner requires a code change. Acceptable for a single-owner demo.

#### L2. `opportunities.review_notes` now contains AI-generated commentary

After the URL-finder batch run, every previously-missing-URL row has an `AUTO[...]: <source> | <notes>` string in `review_notes`. Since `opportunities` is public-read, those notes are public. They contain prosaic strings like "WebFetch blocked; URL confirmed via search" — nothing sensitive — but if you later use `review_notes` for genuinely internal commentary, restrict that column or move it to a private table.

#### L3. The legacy `api/server.js` falls back to the embedded anon key if env vars are missing

Documented intentionally (its README warns it's not deployed), but `NODE_ENV=production` will refuse to start without env vars, which is the right belt-and-braces.

#### L4. `script.js` contains demo opportunities with `sector: 'Innovation & Entrepreneurship'` etc.

Old display labels — superseded by the canonical 17 keys. Cosmetic, no security impact.

---

## 3. What I verified directly

| Area | How verified | Result |
|---|---|---|
| RLS enabled on all `public` tables | `pg_tables.rowsecurity` via MCP | all 10 tables have RLS on |
| No `service_role` key anywhere in repo | `grep -r service_role` | Only matches are in `api.html` body text ("contact us for a service-role key") |
| Anon key only used as anon | Inspected JWT payload: `"role":"anon"` | confirmed |
| `target="_blank"` always paired with `rel="noopener noreferrer"` | grep | all 7 occurrences |
| `esc()` usage | grep — 151 calls in `index.html`, identical HTML-escape implementation each time | consistent |
| No dynamic-code-execution usage | grep for the two relevant patterns | zero matches |
| `is_admin()` function definition | `pg_get_functiondef` | Reads `user_prefs.role`, SECURITY DEFINER, `search_path = public` — good |
| `auth.uid() IS NULL` whitelist works for MCP/service_role | Bootstrap insert succeeded after trigger creation | confirmed |
| `opportunities_review` / `_archive` block anon | Confirmed `pg_policies` shows admin-only now | confirmed |
| Password min length client-side | `login.html` `minlength="8"` + JS `length < 8` check | confirmed — but server-side enforcement is a Supabase project setting |

---

## 3a. §4 verifications I actually ran (2026-05-19, post-fix)

Each test was run inside a `BEGIN ... ROLLBACK` so nothing persisted. Spoofed sessions use `SET LOCAL ROLE` + `SET LOCAL request.jwt.claims` — the same mechanism PostgREST uses when a real client presents a JWT.

| Test | Method | Result |
|---|---|---|
| Anon access to user data | `SET ROLE anon` + count every user-data table | **All 9 user tables: 0 rows.** `opportunities` returned 1217 (intentional public read). |
| Self-promotion as non-admin (INSERT path) | Spoofed as a non-admin UID, `INSERT user_prefs(user_id, role) VALUES (uid, 'admin') ON CONFLICT UPDATE` | Insert accepted; **`role` clamped to `'user'`** by trigger. |
| Self-promotion via `profiles.role` | Same spoof, `UPDATE profiles SET role='admin' WHERE id=uid` | UPDATE accepted; **`role` reverted to `'user'`** by trigger. |
| `is_admin()` after both attempts | Same session | **`false`** |
| Horizontal IDOR — read another user's `profiles` / `user_prefs` / `user_watchlist` / `user_searches` / `user_folders` / `activity_log` | Spoofed as User A, queried User B's rows | **All 0 rows.** Self-row sanity SELECT: 1 row. |
| Cross-user INSERT into `user_watchlist(user_id=B, …)` from A's session | Spoofed A | Affected 0 rows (RLS WITH CHECK blocked it). |
| Non-admin write to `opportunities` (INSERT, UPDATE, DELETE) | Spoofed non-admin | All affected 0 rows. `SA-001.status` unchanged before/after. |
| Non-admin SELECT on `opportunities_review` | Spoofed non-admin | 0 rows. |
| Admin sanity — `is_admin()`, full reads | Spoofed as the owner UID `72f017e5-…61548` | `is_admin()` = `true`. Saw 16 profiles, 9 user_prefs, 19 activity_log, 37 opportunities_review, 15 opportunities_archive, 28 user_watchlist (full dataset, as intended). |
| Supabase Auth — email confirmation | `auth.users` snapshot | 15 of 16 confirmed; **0 unconfirmed-but-signed-in users.** Strong evidence confirmation is enabled at the project level. |
| OAuth providers actually configured | `auth.identities` group by provider | Only `email`. **Google/Microsoft SSO buttons in `login.html` are not wired** — they will return an error if clicked. Flagged in §4.2 below. |

All Critical/High exploit paths are closed in the live database.

## 4. What I did NOT verify (manual checks for you before launch)

1. **Supabase Auth project settings** (in dashboard, not source-controlled):
   - Password minimum length is set to ≥ 8 (matches frontend).
   - `Email confirmations` is **on** (signup currently falls through to `goToApp()` if the response includes a session — fine for normal flow, but if confirmations are off in the dashboard, an attacker can sign up with someone else's email and get instant access. Verify `Auth → Settings → Confirm email` is enabled.).
   - Allowed redirect URLs is set to **only** `https://starixfox.github.io/Saudi-Opportunity-Hub-DEMO-white-label/*` (open-redirect prevention).
   - Rate limiting enabled on sign-in / sign-up / reset endpoints.
2. **OAuth providers** (Google, Microsoft). `login.html` calls `signInWithOAuth` but the providers may not be wired in the dashboard. If you don't intend to enable them, hide the SSO buttons rather than leaving them returning errors.
3. **Test the full role-escalation block as an actual non-admin user**. The MCP/service_role I used to apply the fix bypasses the trigger by design. Spin up a fresh test account and confirm:
   - `update user_prefs set role='admin' where user_id=auth.uid()` — succeeds but role unchanged
   - `update profiles set role='admin' where id=auth.uid()` — succeeds but role unchanged
   - `insert into user_prefs(user_id, role) values (auth.uid(), 'admin')` — inserted with `role='user'`
   - After all of the above, `SELECT is_admin()` still returns `false`.
4. **Try the OWASP-style horizontal IDOR**: with two test accounts, try fetching User B's `user_prefs`, `user_watchlist`, `user_folders`, `folder_items`, `user_searches`, `activity_log` from User A's session. All should return `[]`.
5. **Try vertical from anon**: open an Incognito window, open DevTools → Network and try `GET /rest/v1/profiles`, `/activity_log`, `/opportunities_review`, `/opportunities_archive`. All should return `[]` now.
6. **Confirm the platform owner bootstrap worked end-to-end**: sign in as the owner UID and verify the admin sidebar appears and admin views render data.
7. **Run an HTTPS check** on the deployed origin (`securityheaders.com` or equivalent) — GitHub Pages provides HSTS automatically but verify.
8. **`contact.html` abuse**: this is the only unauthenticated form. Decide if you want a hCaptcha / honeypot before launch.

---

## 5. Remaining risks / recommendations

- **Single source of truth for role.** Drop one of `profiles.role` or `user_prefs.role`. Recommendation: keep `user_prefs.role` (it's what `is_admin()` already uses) and remove `profiles.role`.
- **Audit `review_notes` content policy.** If you ever want truly private admin notes, add an `admin_notes` column and restrict it to admin-only via a column-level RLS pattern (or move to a separate `opportunities_admin` table).
- **Consider `pgaudit` or Supabase logs retention** if you need a tamper-evident audit trail beyond `activity_log`.
- **CSP can be hardened further** by removing inline-script permission from `script-src` — but doing so requires extracting all ~25k lines of inline JS in `index.html` to external files and adding a nonce or hash. Big refactor, defer.
- **Brute-force / enumeration on auth** — Supabase has default protections; verify them in the dashboard.
- **The legacy `api/server.js`** is left in the repo but not deployed. If you don't intend to deploy it, consider deleting it or moving it to a separate repo to avoid confusion.

---

## 6. Files changed in this audit

| File | Change |
|---|---|
| `supabase/migrations/2026_05_19_security_hardening.sql` | NEW — applied to live DB via MCP; same SQL committed for source-control audit trail |
| `index.html` | CSP: removed dynamic-code permission; added `frame-ancestors`, `base-uri`, `form-action`, `object-src`. Added `X-Content-Type-Options` and `Referrer-Policy` meta tags. |
| `login.html` | Added CSP + `X-Content-Type-Options` + `Referrer-Policy` meta tags |
| `reset-password.html` | Same |
| `contact.html` | Same |
| `api.html` | Same |
| `404.html` | Same |

No code was pushed. The DB migration is **live** (applied via MCP); the file changes are local and ready for your review.

---

## 7. Post-audit follow-ups (2026-05-19, second pass)

Three items from §4 (manual checks) and §5 (recommendations) handled in a follow-up pass.

### 7.1 OAuth buttons in `login.html` — no longer clickable when not configured

The Google and Microsoft SSO buttons used to call `signInWithOAuth(...)` regardless of whether the provider was actually wired in Supabase Auth. Verifying via `auth.identities` showed zero non-email identities, so both providers were unwired — clicking either button would have surfaced a Supabase error.

**Change.**
- Added an `OH_OAUTH = { google: true, microsoft: false }` config block at the top of the login script. The owner left Google enabled (provider will be wired in the Supabase dashboard before launch); Microsoft stays disabled until wired. Operator flips a flag to `true` after wiring the provider in Supabase Auth → Providers.
- New `markProviderUnavailable(btn, label)` decorates each unwired button with `aria-disabled="true"`, `disabled`, `tabindex="-1"`, a translated `title`/`aria-label`, and a small inline "Not available / غير متاح" caption. Visual styling (gray, no hover lift, not-allowed cursor) added in CSS.
- Click handlers now early-return when the flag is `false`, so even programmatic clicks no-op.
- `switchLang()` re-applies `title`/`aria-label` for elements decorated with `data-title-en` / `data-title-ar` so the disabled-button tooltip language tracks the rest of the page.

**Verify.** Open `login.html`. Both SSO buttons render grayed out with "Not available" / "غير متاح" caption. Hover shows the explanatory tooltip in the current language. Clicking does nothing (no network request, no console error). Toggle language — caption + tooltip update.

To re-enable: configure the provider in Supabase Auth, then flip the matching `OH_OAUTH.<provider>` flag to `true`.

### 7.2 `profiles.role` removed — `user_prefs.role` is now the only role source

The audit (§5 M1) flagged the two parallel `role` columns. Code-side audit found exactly one reader of `profiles.role` (`index.html:11769`, in the admin Registered-Users table) — every other admin code path already consulted `user_prefs.role`, including `is_admin()`.

**Change.**
- `index.html:11769`: `var role = p.role || pr.role || 'user'` → `var role = pr.role || 'user'`. Comment points at the deprecation migration.
- New migration `supabase/migrations/2026_05_19_drop_profiles_role.sql`:
  1. Idempotent re-bootstrap of the owner's admin status in `user_prefs` (belt-and-braces).
  2. Drop the now-orphan `protect_profiles_role` trigger (it would error after the column is gone).
  3. `ALTER TABLE public.profiles DROP COLUMN IF EXISTS role;`
  4. `COMMENT ON TABLE public.profiles` records that adding a role column back is forbidden.
- Migration applied live via MCP. Confirmed via `information_schema.columns` that `profiles.role` no longer exists; the owner's `user_prefs.role = 'admin'` survived.

The `protect_user_prefs_role` trigger stays in place — it's the load-bearing escalation guard now.

**Verify.**
```sql
-- Should return false / 'admin'
SELECT
  EXISTS(SELECT 1 FROM information_schema.columns
         WHERE table_schema='public' AND table_name='profiles' AND column_name='role'),
  (SELECT role FROM public.user_prefs WHERE user_id = '<owner uid>');
```

### 7.3 `contact.html` bot protection — honeypot + min-fill-time

The contact form is the only unauthenticated POST in the app. Formspree has its own spam filtering, but the form was reachable by automated tools with no front-end friction at all.

**Change.** Two layers added in `contact.html`, both fail-soft (the bot sees the same "success" UI as a real user, so it can't iterate against an error signal):

1. **Honeypot field** — a visually-hidden, off-screen `<input name="website">` with `tabindex="-1"`, `aria-hidden="true"`, `autocomplete="off"`. Humans never see it. Most form-spam bots auto-fill every input. If non-empty at submit, the submission is dropped (no Formspree POST) and the user sees the success state.
2. **Min-fill-time gate** — records `Date.now()` when the script first runs. Submits arriving in under 2 seconds are dropped (humans physically can't fill three fields plus a dropdown that fast; bots paste-and-submit instantly). Same fail-soft success UI.

Both events log a console warning so legitimate users misclassified by the time gate are debuggable.

**Verify.**
- Open `contact.html`, view source, confirm the off-screen honeypot div is present at the top of the form.
- Submit the form with everything else filled but a value in `#contact-website` (use DevTools to set `document.getElementById('contact-website').value = 'http://x'` then submit) — the form will show the success state but the Network tab will show no Formspree POST and the console will log `[contact] honeypot tripped`.
- Fill the form normally in under 2 seconds (use DevTools' Fill Form, or paste each field rapidly) — same fail-soft success, console logs `submission faster than humanly possible`.
- A real user submission (>2 s, honeypot empty) still hits Formspree as before.

### 7.4 Residual risk + when to escalate to a real CAPTCHA

Honeypot + time-gate stops casual form-spam bots (Selenium/Puppeteer scripted submissions, basic credential stuffing harvesters). What they will NOT stop:

- A targeted attacker who reads the source, skips the honeypot, and waits 2 s before submitting.
- A human spammer typing real input.

If you ever see real abuse landing in your inbox, the next step is hCaptcha or Cloudflare Turnstile — both have a CSP-friendly script and a server-side verify hop. Formspree also supports its own CAPTCHA toggle in the form dashboard; that's the lowest-effort upgrade and worth enabling if abuse appears.

### 7.5 Files changed in this follow-up pass

| File | Change |
|---|---|
| `index.html` | `:11769` switched from `p.role \|\| pr.role` to `pr.role` only |
| `login.html` | OAuth `OH_OAUTH` flags + `markProviderUnavailable()` + CSS for `aria-disabled` SSO buttons + language sync for tooltips |
| `contact.html` | Honeypot field + min-fill-time gate, both fail-soft into the existing success UI |
| `supabase/migrations/2026_05_19_drop_profiles_role.sql` | NEW — applied live; drops `profiles.role` after `index.html` stopped reading it |
| `SECURITY_AUDIT.md` | This §7 section |

---

## 8. Advisor sweep (2026-06-11) — all DB-side advisor findings cleared

The Supabase security advisor showed four findings. The three database-side ones are fixed live (mirrored in `supabase/migrations/2026_06_11_advisor_security_sweep.sql`):

| Finding | Level | Fix |
|---|---|---|
| `rls_disabled_in_public` on `opportunities_sectors_backup_20260604` | ERROR | RLS enabled with zero policies → deny-all for anon/authenticated. The 2,743-row June 4 sector backup stays intact for service-role/SQL restore. The advisor's follow-up INFO `rls_enabled_no_policy` on this table is the intended state. |
| `extension_in_public` (`pg_trgm`) | WARN | `ALTER EXTENSION pg_trgm SET SCHEMA extensions`. Verified unused first: no trgm-opclass indexes, no functions/views reference it (the admin dedup similarity is client-side JS in `index.html`). |
| `authenticated_security_definer_function_executable` (`is_admin()`) | WARN | Moved to a new locked-down `private` schema (`USAGE` granted to `authenticated` + `service_role` only). RLS policies bind the function by OID, so all 14 admin policies keep working unchanged; `/rest/v1/rpc/is_admin` is gone. The frontend never called it via RPC (`auth-bootstrap.js` reads `user_prefs.role` directly). |

**Post-fix verification (live, 2026-06-11):**
- Advisor re-run: only the intentional INFO (backup table) and the Auth-config WARN below remain.
- Simulated `authenticated` with a random UID: `opportunities` SELECT works (4,338 rows), `opportunities_review` returns 0 rows with **no permission error** — proving policies still evaluate `private.is_admin()` — and a direct call returns `false`.
- `POST /rest/v1/rpc/is_admin` with the anon key → `404 PGRST202` (function no longer in the API schema cache; before the move this returned a permission error, i.e. the endpoint existed).

**One finding left — manual dashboard toggle (not reachable via SQL/MCP):**
- `auth_leaked_password_protection` (WARN): enable in Dashboard → Authentication → **Attack Protection** → leaked-password protection (checks new/changed passwords against HaveIBeenPwned; if the toggle is plan-gated the dashboard will say so). Direct link: <https://supabase.com/dashboard/project/dshrbbnjahjcwxzvzygh/auth/protection>
