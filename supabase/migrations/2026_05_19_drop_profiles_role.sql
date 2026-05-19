-- ════════════════════════════════════════════════════════════════
-- 2026-05-19 — DROP DEPRECATED profiles.role COLUMN
-- ════════════════════════════════════════════════════════════════
-- Follow-up to 2026_05_19_security_hardening.sql.
--
-- Background
-- ----------
-- The platform historically tracked admin status in two places:
--   * public.user_prefs.role     ← what is_admin() actually reads
--   * public.profiles.role       ← legacy, mirrored by old code paths
--
-- The previous hardening migration installed a BEFORE trigger on BOTH
-- columns so neither could be used as an escalation vector. With that
-- in place the audit's recommendation was to consolidate on the
-- column that is_admin() consults (user_prefs.role) and remove the
-- duplicate. After the corresponding code change in index.html
-- (commit follows), no application code reads profiles.role anymore,
-- so the column is safe to drop.
--
-- Safety notes
-- ------------
--   1. Run AFTER the index.html change that stops reading p.role is
--      deployed. The file you're looking at is part of that same PR.
--   2. The role value for every existing admin/user is already
--      mirrored in user_prefs.role (the bootstrap step of
--      2026_05_19_security_hardening.sql ensured this for the owner;
--      no other admins existed at audit time).
--   3. We DROP the now-redundant protect_profiles_role trigger to
--      avoid an orphan referring to a non-existent column.
--   4. The trigger on user_prefs.role stays — that remains the
--      load-bearing escalation guard.

-- Sanity belt: re-confirm that the owner's admin status survives in
-- user_prefs (idempotent — same insert/upsert from the hardening
-- migration). If the row is gone for any reason, restore it.
INSERT INTO public.user_prefs (user_id, role)
VALUES ('72f017e5-b4f0-4ef2-9083-65e3d9961548', 'admin')
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';

-- 1. Drop the now-unused profiles trigger first (it would error after
--    the column is gone).
DROP TRIGGER IF EXISTS protect_profiles_role ON public.profiles;

-- 2. Drop the deprecated column.
ALTER TABLE public.profiles DROP COLUMN IF EXISTS role;

-- 3. Documentation marker.
COMMENT ON TABLE public.profiles IS
  'User profile data. Admin status lives in user_prefs.role; do NOT add a role column here again.';

SELECT 'profiles.role dropped — user_prefs.role is the single source of truth' AS status;
