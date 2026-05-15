-- Phase B: Deadline alerts
-- user_prefs already exists, just need to ensure notifications column exists
ALTER TABLE user_prefs
ADD COLUMN IF NOT EXISTS notifications jsonb DEFAULT
'{"newInSectors": true, "closingIn3Days": true, "savedSearchMatch": true}'::jsonb;
