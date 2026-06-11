-- ════════════════════════════════════════════════════════════════
-- 2026-06-11 — ADVISOR SECURITY SWEEP
-- ════════════════════════════════════════════════════════════════
-- Clears every database-side finding from the Supabase security
-- advisor (see SECURITY_AUDIT.md §8). Applied live via MCP on
-- 2026-06-11 as three migrations:
--   enable_rls_opportunities_sectors_backup_20260604
--   move_pg_trgm_to_extensions_schema
--   move_is_admin_out_of_api_schema
-- This file is the source-control mirror of all three.

-- ─── 1. rls_disabled_in_public (ERROR) ──────────────────────────
-- opportunities_sectors_backup_20260604 (2,743 rows — the pre-change
-- copy from the 2026-06-04 sector work) was readable AND writable by
-- anyone holding the anon key. RLS with zero policies = deny-all for
-- client roles; service_role / direct SQL (the restore path) is
-- unaffected. The advisor's follow-up INFO `rls_enabled_no_policy`
-- on this table is intentional.
ALTER TABLE public.opportunities_sectors_backup_20260604 ENABLE ROW LEVEL SECURITY;

-- ─── 2. extension_in_public (WARN) ──────────────────────────────
-- pg_trgm lived in public. Verified unused app-side before moving:
-- no trgm-opclass indexes, no functions/views reference it (the
-- admin dedup similarity is client-side JS — Dice's coefficient in
-- index.html). pg_trgm is relocatable, so move it to the standard
-- extensions schema.
ALTER EXTENSION pg_trgm SET SCHEMA extensions;

-- ─── 3. authenticated_security_definer_function_executable (WARN)
-- is_admin() was reachable at /rest/v1/rpc/is_admin by signed-in
-- users. It must STAY executable by `authenticated` — 14 RLS policies
-- call it in qual/with_check, and policy expressions run with the
-- privileges of the querying role (the 2026-05-25 migration kept the
-- grant for exactly this reason). But nothing needs the RPC endpoint:
-- the frontend reads user_prefs.role directly (auth-bootstrap.js),
-- never rpc('is_admin'); no edge functions exist; protect_role_column
-- inlines its own EXISTS check rather than calling is_admin().
--
-- Policies bind the function by OID, so relocating it to a non-API
-- schema removes the PostgREST endpoint without touching any policy.
-- Executing a function also requires USAGE on its schema, hence the
-- grants. The function's own ACL travels with it (postgres,
-- authenticated, service_role only — anon was revoked 2026-05-25).
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
GRANT USAGE ON SCHEMA private TO authenticated, service_role;
ALTER FUNCTION public.is_admin() SET SCHEMA private;
