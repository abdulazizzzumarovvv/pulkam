-- PulKam PRO — ma'lumotlar bazasi sxemasi

-- Foydalanuvchilar (Google account orqali)
CREATE TABLE IF NOT EXISTS users (
  id          SERIAL PRIMARY KEY,
  google_sub  TEXT UNIQUE NOT NULL,          -- Google'ning barqaror user ID si
  email       TEXT,
  name        TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Obunalar (PRO holati)
CREATE TABLE IF NOT EXISTS subscriptions (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan        TEXT NOT NULL CHECK (plan IN ('oylik','yillik','umrbod')),
  status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','expired','cancelled')),
  starts_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ,                    -- NULL = umrbod (muddatsiz)
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);

-- To'lovlar (Click)
CREATE TABLE IF NOT EXISTS payments (
  id               SERIAL PRIMARY KEY,
  user_id          INTEGER REFERENCES users(id) ON DELETE SET NULL,
  order_id         TEXT UNIQUE NOT NULL,      -- bizning ichki ID (Click: merchant_trans_id)
  plan             TEXT NOT NULL CHECK (plan IN ('oylik','yillik','umrbod')),
  amount           NUMERIC(14,2) NOT NULL,
  status           TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','prepared','paid','failed','cancelled')),
  click_trans_id   TEXT,                      -- Click tranzaksiya ID
  click_paydoc_id  TEXT,
  prepare_id       INTEGER,                   -- Prepare bosqichida qaytariladi
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  paid_at          TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);

-- Adminlar (admin panelга kirish uchun)
CREATE TABLE IF NOT EXISTS admins (
  id             SERIAL PRIMARY KEY,
  email          TEXT UNIQUE NOT NULL,
  password_hash  TEXT NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
