-- Phase C: per-user theme assignment
-- Adds a nullable `theme` column to user_prefs
-- Admins can set this to any OH_THEMES key (e.g. 'misa', 'monshaat', 'adio')
-- NULL = default platform theme

ALTER TABLE user_prefs
  ADD COLUMN IF NOT EXISTS theme TEXT DEFAULT NULL;

COMMENT ON COLUMN user_prefs.theme IS
  'White-label theme key assigned to this user by super-admin. NULL = platform default.';

-- Permissive policy that lets admins update any user's theme.
-- (RLS is permissive: any matching policy lets the operation through.)
DROP POLICY IF EXISTS "Only admins can set user themes" ON user_prefs;
CREATE POLICY "Only admins can set user themes"
  ON user_prefs FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_prefs up
      WHERE up.user_id = auth.uid() AND up.role = 'admin'
    )
  )
  WITH CHECK (true);
