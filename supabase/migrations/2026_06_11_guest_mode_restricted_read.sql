-- ════════════════════════════════════════════════════════════════
-- 2026-06-11 — GUEST MODE: server-enforced column-restricted reads
-- ════════════════════════════════════════════════════════════════
-- Adds a "Continue as Guest" data path for sales prospects and, in the
-- same stroke, closes a pre-existing exposure found while wiring it up:
--
--   FINDING (flagged in the guest-mode work, see SECURITY_AUDIT.md):
--   the policy `opportunities_public_read` was role={public}, qual=true.
--   Anyone holding the anon key (which ships in every page of this
--   static site) could read EVERY column of EVERY opportunity row —
--   including the paid-value fields (description_short, funding_amount,
--   eligibility_entities, application_link) and the internal editorial
--   columns (notes, review_status, review_notes) — without ever
--   logging in. The login wall was purely client-side.
--
-- DESIGN
--   Guests do NOT use Supabase anonymous sign-in. Two reasons:
--     1. The `on_auth_user_created` trigger (handle_new_user) creates a
--        profile row for every new auth user — anonymous sign-in would
--        write auth.users + profiles rows per guest visit, and the spec
--        requires guest sessions to write nothing.
--     2. Anonymous-auth users run as the `authenticated` Postgres role,
--        the same role as paying members — column-level separation
--        between "guest" and "member" would then be impossible. The
--        unauthenticated `anon` role gives a real privilege boundary.
--   So: guest = no session at all. The client keeps a sessionStorage
--   flag for UX, and the anon role's database privileges are the
--   actual enforcement.
--
-- AFTER THIS MIGRATION
--   anon (guests):       zero access to public.opportunities. May read
--                        public.opportunities_guest — a projection that
--                        exposes ONLY the breadth columns (card fields,
--                        filter dims, chart dims) plus four presence
--                        booleans, and excludes archived rows.
--   authenticated:       unchanged — full SELECT on opportunities via
--                        the new authenticated-only policy (identical
--                        rows to the old public policy).
--   admins/service_role: unchanged (write policies untouched;
--                        service_role bypasses RLS).
--
-- Locked columns (never reach a guest client, not even in the view):
--   description_short, description_short_ar, funding_amount,
--   eligibility_entities, application_link, notes, review_status,
--   review_notes, "isNew" (legacy).
-- ════════════════════════════════════════════════════════════════


-- ─── 1. Replace the wide-open read policy with authenticated-only ──
-- Same rows as before for signed-in users (qual=true), so member and
-- admin behaviour is byte-identical. anon simply no longer matches any
-- SELECT policy on the base table.
DROP POLICY IF EXISTS "opportunities_public_read" ON public.opportunities;

DROP POLICY IF EXISTS "opportunities_authenticated_read" ON public.opportunities;
CREATE POLICY "opportunities_authenticated_read" ON public.opportunities
  FOR SELECT TO authenticated
  USING (true);

-- ─── 2. Strip anon's table-level privileges on the base table ──────
-- Supabase's default grants gave anon ALL privileges (writes were only
-- stopped by RLS). Guests now have no direct path to the base table at
-- all — RLS (no anon policy) AND no grant, two independent locks.
REVOKE ALL ON TABLE public.opportunities FROM anon;

-- Belt-and-suspenders on the editorial tables too: both are already
-- RLS-locked to admins (2026-05-19 hardening), but anon had no
-- legitimate reason to keep its default table-level grants.
REVOKE ALL ON TABLE public.opportunities_review  FROM anon;
REVOKE ALL ON TABLE public.opportunities_archive FROM anon;

-- ─── 3. The guest projection ───────────────────────────────────────
-- SECURITY DEFINER view (Postgres default; security_invoker is left
-- OFF deliberately). It must run with the owner's privileges because
-- the invoker (anon) has no privileges on the base table at all —
-- that is the point. The Supabase advisor will report
-- `security_definer_view` for this object; that finding is ACCEPTED
-- and documented here:
--   * the SELECT list is a fixed allow-list of breadth columns —
--     none of the locked columns appear;
--   * the four has_* booleans disclose only PRESENCE of a locked
--     field (so the guest UI can render honest "members only" locks
--     instead of pretending every row has a description/link);
--   * row scope is baked in: archived rows are excluded, mirroring
--     the .neq('status','archived') filter every app loader applies;
--   * it is read-only by construction (projection + WHERE; no
--     INSERT/UPDATE/DELETE grants are issued on it).
CREATE OR REPLACE VIEW public.opportunities_guest AS
SELECT
  o.id,
  o.title,
  o.title_ar,
  o.type,
  o.sponsor_institution,
  o.country,
  o.eligibility_region,          -- geographic scope (card "region" field)
  o.funding_type,                -- categorical (grant/loan/…) — amounts stay locked
  o.deadline_date,
  o.status,
  o.language,
  o.last_verified,
  o.profiles,
  o.sectors,
  o.created_at,
  -- Presence flags for honest lock UI (existence only, never content).
  -- has_funding_amount mirrors the member-side "meaningful amount" test
  -- (index.html resultsCount: excludes Not specified / TBA / N/A /
  -- Varies / See details placeholders) so a guest lock never teases a
  -- value that would read as "TBA" to a member, and the guest "with
  -- funding" counter matches the member counter's definition.
  (o.description_short    IS NOT NULL AND btrim(o.description_short)    <> '')  AS has_description,
  (o.funding_amount       IS NOT NULL AND btrim(o.funding_amount)       <> ''
     AND o.funding_amount !~* '(not specified|tba|n/a|varies|see details)')     AS has_funding_amount,
  (o.eligibility_entities IS NOT NULL AND btrim(o.eligibility_entities) <> '')  AS has_eligibility,
  (o.application_link     IS NOT NULL AND o.application_link ~* '^https?://')   AS has_application_link
FROM public.opportunities o
WHERE o.status IS DISTINCT FROM 'archived';

ALTER VIEW public.opportunities_guest OWNER TO postgres;

-- Read-only grant. `authenticated` is included so the login page's
-- stat pills keep working when a still-signed-in user revisits
-- login.html (their supabase-js client sends the user JWT, not anon).
REVOKE ALL ON TABLE public.opportunities_guest FROM anon, authenticated;
GRANT SELECT ON TABLE public.opportunities_guest TO anon, authenticated;

-- ─── 4. Post-conditions (run manually to verify) ───────────────────
-- Guest (anon) must NOT read the base table:
--   curl '<url>/rest/v1/opportunities?select=id&limit=1' -H 'apikey: <anon>'
--     → 42501 permission denied
-- Guest (anon) reads only the projection:
--   curl '<url>/rest/v1/opportunities_guest?select=*&limit=1' -H 'apikey: <anon>'
--     → 200, no locked columns in the payload
--   curl '<url>/rest/v1/opportunities_guest?select=funding_amount&limit=1' ...
--     → 42703 column does not exist
-- Signed-in member still reads full rows:
--   same query with 'Authorization: Bearer <user jwt>' on /opportunities
--     → 200 with all columns

SELECT 'guest mode restricted-read migration applied' AS status;
