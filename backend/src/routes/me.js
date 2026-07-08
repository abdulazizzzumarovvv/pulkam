// Ilova PRO holatini shu yerdan tekshiradi (server = haqiqat manbai).
import express from 'express';
import { query } from '../db/pool.js';
import { requireUser } from '../middleware/auth.js';
import { getProStatus } from '../lib/pro.js';

const router = express.Router();

// GET /me/pro  -> { isPro, plan, expiresAt }
router.get('/pro', requireUser, async (req, res) => {
  const status = await getProStatus(req.userId);
  res.json(status);
});

// GET /me  -> profil ma'lumotlari
router.get('/', requireUser, async (req, res) => {
  const { rows } = await query(
    `SELECT name, email, avatar_url FROM users WHERE id = $1`,
    [req.userId]
  );
  if (rows.length === 0) return res.status(404).json({ error: 'Topilmadi' });
  const u = rows[0];
  res.json({ name: u.name, email: u.email, avatarUrl: u.avatar_url });
});

export default router;
