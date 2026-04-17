-- =============================================
-- ClassWordle - Supabase Setup
-- Run this in the Supabase SQL Editor
-- =============================================

-- 1. Classes table
CREATE TABLE IF NOT EXISTS classes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  class_code TEXT NOT NULL UNIQUE,
  teacher_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Daily words table
CREATE TABLE IF NOT EXISTS daily_words (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  class_code TEXT NOT NULL REFERENCES classes(class_code) ON DELETE CASCADE,
  play_date DATE NOT NULL DEFAULT CURRENT_DATE,
  word TEXT NOT NULL CHECK (char_length(word) = 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (class_code, play_date)
);

-- 3. Results table
CREATE TABLE IF NOT EXISTS results (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  class_code TEXT NOT NULL REFERENCES classes(class_code) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  period INT NOT NULL CHECK (period BETWEEN 1 AND 5),
  play_date DATE NOT NULL DEFAULT CURRENT_DATE,
  solved BOOLEAN NOT NULL,
  num_guesses INT NOT NULL CHECK (num_guesses BETWEEN 1 AND 6),
  guess_data JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (class_code, first_name, last_name, period, play_date)
);

-- 4. Name links table (manual roster mappings)
CREATE TABLE IF NOT EXISTS name_links (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  class_code TEXT NOT NULL,
  submitted_name TEXT NOT NULL,
  roster_name TEXT NOT NULL,
  period INT NOT NULL CHECK (period BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (class_code, submitted_name)
);

-- =============================================
-- Indexes
-- =============================================

CREATE INDEX IF NOT EXISTS idx_daily_words_lookup ON daily_words(class_code, play_date);
CREATE INDEX IF NOT EXISTS idx_results_lookup ON results(class_code, play_date);
CREATE INDEX IF NOT EXISTS idx_results_period ON results(class_code, play_date, period);
CREATE INDEX IF NOT EXISTS idx_name_links_lookup ON name_links(class_code, submitted_name);

-- =============================================
-- Row Level Security (RLS)
-- =============================================

ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE name_links ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read/insert for all tables (using anon key)
CREATE POLICY "Allow public read on classes"
  ON classes FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on classes"
  ON classes FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public read on daily_words"
  ON daily_words FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on daily_words"
  ON daily_words FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public read on results"
  ON results FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on results"
  ON results FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public read on name_links"
  ON name_links FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on name_links"
  ON name_links FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update on name_links"
  ON name_links FOR UPDATE
  USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete on name_links"
  ON name_links FOR DELETE
  USING (true);
