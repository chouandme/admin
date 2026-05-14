-- =============================================================
-- Supabase Migration: groomers + customer_flags
-- Run this in BOTH Supabase projects:
--   1. chouandme-booking project (qlyyeetzvtegbgasmmmb)
--   2. admin project (pjbhqaprkljbvixqztbe)
--
-- The groomers table is read by both apps.
-- The customer_flags table is only used by the admin apps.
-- =============================================================

-- ─────────────────────────────────────────
-- TABLE: groomers
-- Used by: chouandme-booking/index.html
--          admin/index.html
--          admin/admin.html
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS groomers (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  emoji       TEXT NOT NULL DEFAULT '💇‍♀️',
  sort_order  INTEGER NOT NULL DEFAULT 0,
  color       TEXT DEFAULT '#A07255',
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed the two default groomers
INSERT INTO groomers (id, name, emoji, sort_order) VALUES
  ('groomer1', 'ช่าง 1', '💇‍♀️', 1),
  ('groomer2', 'ช่าง 2', '💇‍♀️', 2)
ON CONFLICT (id) DO NOTHING;

-- Allow anonymous read (apps use the anon key)
ALTER TABLE groomers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read groomers"
  ON groomers FOR SELECT USING (true);

-- ─────────────────────────────────────────
-- TABLE: customer_flags
-- Used by: admin/index.html
--          admin/admin.html
-- Run this only in the ADMIN project (pjbhqaprkljbvixqztbe)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customer_flags (
  phone       TEXT PRIMARY KEY,
  noshow      INTEGER NOT NULL DEFAULT 0,
  late        INTEGER NOT NULL DEFAULT 0,
  cancel      INTEGER NOT NULL DEFAULT 0,
  updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Upsert trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_customer_flags_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customer_flags_updated
  BEFORE INSERT OR UPDATE ON customer_flags
  FOR EACH ROW EXECUTE FUNCTION update_customer_flags_timestamp();

-- RLS: allow anon to read and upsert (admin app uses anon key)
ALTER TABLE customer_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public read customer_flags"
  ON customer_flags FOR SELECT USING (true);
CREATE POLICY "public upsert customer_flags"
  ON customer_flags FOR INSERT WITH CHECK (true);
CREATE POLICY "public update customer_flags"
  ON customer_flags FOR UPDATE USING (true);
