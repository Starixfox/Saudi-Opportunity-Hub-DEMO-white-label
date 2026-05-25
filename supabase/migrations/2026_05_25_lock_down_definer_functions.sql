-- ════════════════════════════════════════════════════════════════
-- 2026-05-25 — LOCK DOWN SECURITY DEFINER FUNCTIONS
-- ════════════════════════════════════════════════════════════════
-- Resolves remaining Supabase advisor warnings after the 2026-05-19
-- security hardening pass (see SECURITY_AUDIT.md §7).
--
-- Two classes of warning addressed:
--
-- 1. function_search_path_mutable
--    handle_new_user  (SECURITY DEFINER, trigger on auth.users)
--    handle_updated_at(SECURITY INVOKER, trigger on public.profiles)
--    A mutable search_path lets a privileged DEFINER function resolve
--    object names against an attacker-controlled schema if invoked
--    from one. Pin it to public, pg_temp.
--
-- 2. anon_/authenticated_security_definer_function_executable
--    handle_new_user, handle_updated_at, protect_role_column were all
--    callable via PostgREST RPC (/rest/v1/rpc/<name>) by anon and
--    authenticated. None of these are meant to be called by clients —
--    they exist solely as triggers. Triggers do NOT need role-level
--    EXECUTE grants to fire (trigger binding is in pg_trigger, not
--    routed through privilege checks), so revoking client EXECUTE is
--    safe and removes the RPC attack surface.
--
--    is_admin() stays callable by `authenticated` because the live RLS
--    policies reference it in their `qual` clause; revoking would
--    break the admin SELECT/UPDATE policies on profiles, activity_log,
--    opportunities_review, opportunities_archive, and user_prefs.
--    Anon EXECUTE on is_admin() is revoked — anon never satisfies the
--    role check, so exposing the function to anon is wasted surface.

-- ─── 1. Pin search_path on the two flagged functions ────────────
ALTER FUNCTION public.handle_new_user()    SET search_path = public, pg_temp;
ALTER FUNCTION public.handle_updated_at()  SET search_path = public, pg_temp;

-- ─── 2. Revoke RPC exposure on the three trigger-only functions ─
REVOKE EXECUTE ON FUNCTION public.handle_new_user()      FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_updated_at()    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.protect_role_column()  FROM PUBLIC, anon, authenticated;

-- ─── 3. Trim is_admin() exposure to only what RLS needs ─────────
-- Keep authenticated (RLS evaluation), drop anon and PUBLIC.
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
