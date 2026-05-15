-- Folders: user-created collections of opportunities
CREATE TABLE IF NOT EXISTS user_folders (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        text NOT NULL,
  name_ar     text,
  color       text DEFAULT '#006C35',
  icon        text DEFAULT '📁',
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- Junction: which opportunities are in which folder
CREATE TABLE IF NOT EXISTS folder_items (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id     uuid NOT NULL REFERENCES user_folders(id) ON DELETE CASCADE,
  opp_id        text NOT NULL,
  added_at      timestamptz DEFAULT now(),
  UNIQUE(folder_id, opp_id)
);

-- RLS
ALTER TABLE user_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE folder_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own folders"
  ON user_folders FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users manage own folder items"
  ON folder_items FOR ALL
  USING (folder_id IN (
    SELECT id FROM user_folders WHERE user_id = auth.uid()
  ));
