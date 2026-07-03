-- ════════════════════════════════════════════════════════════════
-- 2026-07-03 — LOCK DOWN THE PRE-AUDIT SNAPSHOT TABLE
-- ════════════════════════════════════════════════════════════════
-- Live security check (2026-07-03) found a regression of the exact
-- class fixed for opportunities_sectors_backup_20260604 on 2026-06-11:
--
--   FINDING (Critical):
--   public.opportunities_preaudit_20260617 — a 5,487-row snapshot of
--   the opportunities table taken before the 2026-06-17 audit — was
--   left in the PostgREST-exposed `public` schema with:
--       * RLS DISABLED, and
--       * the Supabase default table-level grants still on `anon`
--         (SELECT, INSERT, UPDATE, DELETE, TRUNCATE).
--   RLS-disabled + anon grants means the grants are the ONLY gate, and
--   they are wide open. Any visitor holding the anon key (it ships in
--   every page of this static site) could:
--       * READ all 5,487 rows including description_short,
--         funding_amount and application_link — the very columns the
--         2026-06-11 guest-mode migration exists to hide. This fully
--         defeats the members-only paywall.
--       * INSERT / UPDATE / DELETE / TRUNCATE the table's contents
--         with no authentication at all (data-integrity / destruction).
--
-- REMEDIATION
--   This snapshot is a one-off pre-audit backup with no application
--   reader (nothing in the frontend or api/server.js references it).
--   The correct end state is to remove it from the client-reachable
--   surface. Two options — pick ONE:
--
--   Option A (recommended): DROP the snapshot outright.
--     If you still need the pre-audit data for reference, export it
--     first (pg_dump / CSV) and keep it outside the live project.
--
--   Option B: keep the table but make it deny-all for client roles,
--     exactly like opportunities_sectors_backup_20260604 — enable RLS
--     with zero policies AND strip anon/authenticated grants, leaving
--     only service_role / direct SQL access for a future restore.
--
-- Option B is the default below (non-destructive, reversible, and
-- byte-for-byte the pattern already blessed for the sibling backup).
-- To use Option A instead, comment out the Option B block and
-- uncomment the DROP.
-- ════════════════════════════════════════════════════════════════

-- ─── Option A: remove it entirely (uncomment to use) ────────────
-- DROP TABLE IF EXISTS public.opportunities_preaudit_20260617;

-- ─── Option B: deny-all for client roles (default) ──────────────
-- 1. Enable RLS. With zero policies this is deny-all for anon and
--    authenticated; service_role and direct SQL (the restore path)
--    bypass RLS and are unaffected.
ALTER TABLE public.opportunities_preaudit_20260617 ENABLE ROW LEVEL SECURITY;

-- 2. Strip the default table-level grants so there are two independent
--    locks (no grant AND no policy), matching the base opportunities
--    table and the sectors backup.
REVOKE ALL ON TABLE public.opportunities_preaudit_20260617 FROM anon, authenticated;

-- ─── Post-conditions (run manually to verify) ──────────────────
--   curl '<url>/rest/v1/opportunities_preaudit_20260617?select=id&limit=1' \
--        -H 'apikey: <anon>'
--     → 42501 permission denied (was: 200 with full rows)

SELECT 'preaudit snapshot locked down' AS status;
