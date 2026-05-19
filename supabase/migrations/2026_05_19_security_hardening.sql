-- ════════════════════════════════════════════════════════════════
-- 2026-05-19 — SECURITY HARDENING
-- ════════════════════════════════════════════════════════════════
-- Closes a set of Critical/High RLS findings discovered during the
-- pre-launch security audit (see SECURITY_AUDIT.md).
--
-- Summary of issues fixed:
--   1. profiles "Admin can read all profiles" was role=public, qual=true.
--      Since policies are OR'd, this overrode the per-user policy and
--      allowed ANY anonymous request to list every user's email/name/org.
--   2. activity_log "Admin can read/delete all activity" had the same
--      role=public, qual=true pattern. Anyone could read or delete every
--      user's activity history.
--   3. opportunities_review and opportunities_archive had public-read
--      policies — internal review queue and archive were readable by any
--      anon client hitting the REST endpoint.
--   4. user_prefs "Only admins can set user themes" used WITH CHECK (true)
--      which let an admin (or anyone who could become admin via #5) write
--      any column on any row — including silently promoting other users.
--   5. CRITICAL self-promotion: is_admin() reads user_prefs.role = 'admin',
--      and the user_prefs_self policy (correctly) allowed users to
--      INSERT/UPDATE their own row. Nothing restricted the ROLE column,
--      so any signed-in user could:
--          INSERT INTO user_prefs(user_id, role) VALUES (auth.uid(),'admin')
--      and become a platform admin. Same vector existed on profiles.role
--      via "Users can update own profile".
--
-- The fix uses a BEFORE INSERT/UPDATE trigger that clamps the `role`
-- column to a safe value for any non-admin caller. service_role / MCP
-- (auth.uid() IS NULL) is whitelisted so admins can still be promoted
-- via privileged tooling.

-- ── 0. Bootstrap the platform owner as admin BEFORE the trigger ─────
-- After the trigger is installed, only an existing admin or service_role
-- can mint new admins, so we seed the intended owner here.

INSERT INTO public.user_prefs (user_id, role)
VALUES ('72f017e5-b4f0-4ef2-9083-65e3d9961548', 'admin')
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';

UPDATE public.profiles
SET role = 'admin'
WHERE id = '72f017e5-b4f0-4ef2-9083-65e3d9961548';

-- ── 1. profiles: replace broken admin-read policy ───────────────────
DROP POLICY IF EXISTS "Admin can read all profiles" ON public.profiles;
CREATE POLICY "admin_select_all_profiles" ON public.profiles
  FOR SELECT TO authenticated
  USING (public.is_admin());

-- ── 2. activity_log: replace broken admin policies ──────────────────
DROP POLICY IF EXISTS "Admin can read all activity" ON public.activity_log;
DROP POLICY IF EXISTS "Admin can delete activity"   ON public.activity_log;

CREATE POLICY "admin_select_all_activity" ON public.activity_log
  FOR SELECT TO authenticated
  USING (public.is_admin());

CREATE POLICY "admin_delete_activity" ON public.activity_log
  FOR DELETE TO authenticated
  USING (public.is_admin());

CREATE POLICY "user_select_own_activity" ON public.activity_log
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- ── 3. opportunities_review + opportunities_archive: admin-only ─────
DROP POLICY IF EXISTS "opportunities_review_public_read"  ON public.opportunities_review;
DROP POLICY IF EXISTS "opportunities_archive_public_read" ON public.opportunities_archive;

CREATE POLICY "admin_select_opportunities_review" ON public.opportunities_review
  FOR SELECT TO authenticated
  USING (public.is_admin());
CREATE POLICY "admin_modify_opportunities_review" ON public.opportunities_review
  FOR ALL TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "admin_select_opportunities_archive" ON public.opportunities_archive
  FOR SELECT TO authenticated
  USING (public.is_admin());
CREATE POLICY "admin_modify_opportunities_archive" ON public.opportunities_archive
  FOR ALL TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── 4. user_prefs: replace broken "Only admins can set user themes" ──
DROP POLICY IF EXISTS "Only admins can set user themes" ON public.user_prefs;
CREATE POLICY "admin_update_any_user_prefs" ON public.user_prefs
  FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── 5. Role-escalation trigger ──────────────────────────────────────
-- Clamps the `role` column for non-admin callers. SECURITY DEFINER so it
-- can read user_prefs even if RLS would otherwise hide rows.

CREATE OR REPLACE FUNCTION public.protect_role_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_is_admin boolean;
BEGIN
  -- service_role / superuser / cron / MCP: auth.uid() returns NULL.
  -- Whitelist that path so privileged tooling can bootstrap admins.
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  caller_is_admin := EXISTS (
    SELECT 1 FROM public.user_prefs
    WHERE user_id = auth.uid() AND role = 'admin'
  );

  IF caller_is_admin THEN
    RETURN NEW;
  END IF;

  -- Non-admin path: clamp role to a safe value so writes are still
  -- accepted (the per-user policies still apply for the OTHER columns),
  -- but the role itself can't be elevated.
  IF TG_OP = 'INSERT' THEN
    NEW.role := 'user';
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.role := OLD.role;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_user_prefs_role ON public.user_prefs;
CREATE TRIGGER protect_user_prefs_role
  BEFORE INSERT OR UPDATE ON public.user_prefs
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_role_column();

DROP TRIGGER IF EXISTS protect_profiles_role ON public.profiles;
CREATE TRIGGER protect_profiles_role
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_role_column();

SELECT 'security hardening migration applied' AS status;
