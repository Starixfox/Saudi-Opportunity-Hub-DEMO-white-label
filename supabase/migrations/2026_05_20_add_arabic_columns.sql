-- ════════════════════════════════════════════════════════════════
-- 2026-05-20 — Arabic title + description columns
-- ════════════════════════════════════════════════════════════════
-- The opportunity detail modal can render an authored Arabic title
-- and description when present. Until those values are authored
-- (separate human task) the UI falls back to the English columns
-- and surfaces a small fallback note to AR users so they know the
-- English text is intentional, not a translation bug.
--
-- All columns are nullable; nothing else changes.

ALTER TABLE public.opportunities
  ADD COLUMN IF NOT EXISTS title_ar             text,
  ADD COLUMN IF NOT EXISTS description_short_ar text;

ALTER TABLE public.opportunities_review
  ADD COLUMN IF NOT EXISTS title_ar             text,
  ADD COLUMN IF NOT EXISTS description_short_ar text;

ALTER TABLE public.opportunities_archive
  ADD COLUMN IF NOT EXISTS title_ar             text,
  ADD COLUMN IF NOT EXISTS description_short_ar text;

COMMENT ON COLUMN public.opportunities.title_ar IS
  'Authored Arabic title. NULL = fall back to the English title column in the UI.';

COMMENT ON COLUMN public.opportunities.description_short_ar IS
  'Authored Arabic short description. NULL = English fallback (UI adds an explanatory note for AR users).';

SELECT 'arabic columns added' AS status;
