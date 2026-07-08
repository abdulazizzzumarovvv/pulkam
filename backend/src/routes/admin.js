// Admin panel API — login, foydalanuvchilar, statistika, qo'lda PRO berish.
import express from 'express';
import bcrypt from 'bcryptjs';
import { query } from '../db/pool.js';
import { signAdminToken, requireAdmin } from '../middleware/auth.js';
import { activatePro } from '../lib/pro.js';

const router = express.Router();
router.use(express.json());

// POST /admin/login  { email, password }
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const { rows } = await query(`SELECT * FROM admins WHERE email = $1`, [email]);
  const admin = rows[0];
  if (!admin || !(await bcrypt.compare(password, admin.password_hash))) {
    return res.status(401).json({ error: 'Email yoki parol noto\'g\'ri' });
  }
  res.json({ token: signAdminToken(admin.id) });
});

// GET /admin/stats  -> umumiy statistika
router.get('/stats', requireAdmin, async (req, res) => {
  const revenue = await query(
    `SELECT COALESCE(SUM(amount),0) AS total, COUNT(*) AS count
       FROM payments WHERE status = 'paid'`
  );
  const activePro = await query(
    `SELECT COUNT(DISTINCT user_id) AS n FROM subscriptions
      WHERE status = 'active' AND (expires_at IS NULL OR expires_at > now())`
  );
  const byPlan = await query(
    `SELECT plan, COUNT(*) AS n, COALESCE(SUM(amount),0) AS sum
       FROM payments WHERE status = 'paid' GROUP BY plan`
  );
  res.json({
    revenue: Number(revenue.rows[0].total),
    paidCount: Number(revenue.rows[0].count),
    activePro: Number(activePro.rows[0].n),
    byPlan: byPlan.rows,
  });
});

// GET /admin/users  -> foydalanuvchilar + PRO holati
router.get('/users', requireAdmin, async (req, res) => {
  const { rows } = await query(
    `SELECT u.id, u.name, u.email, u.avatar_url, u.created_at,
            s.plan, s.expires_at,
            (s.id IS NOT NULL AND (s.expires_at IS NULL OR s.expires_at > now())) AS is_pro
       FROM users u
       LEFT JOIN LATERAL (
         SELECT * FROM subscriptions
          WHERE user_id = u.id AND status = 'active'
          ORDER BY (expires_at IS NULL) DESC, expires_at DESC LIMIT 1
       ) s ON true
      ORDER BY u.created_at DESC`
  );
  res.json({ users: rows });
});

// GET /admin/payments  -> so'nggi to'lovlar
router.get('/payments', requireAdmin, async (req, res) => {
  const { rows } = await query(
    `SELECT p.order_id, p.plan, p.amount, p.status, p.created_at, p.paid_at,
            u.name, u.email
       FROM payments p LEFT JOIN users u ON u.id = p.user_id
      ORDER BY p.created_at DESC LIMIT 200`
  );
  res.json({ payments: rows });
});

// POST /admin/grant  { userId, plan }  -> qo'lda PRO berish
router.post('/grant', requireAdmin, async (req, res) => {
  const { userId, plan } = req.body;
  if (!['oylik', 'yillik', 'umrbod'].includes(plan)) {
    return res.status(400).json({ error: 'Noto\'g\'ri plan' });
  }
  await activatePro(userId, plan);
  res.json({ ok: true });
});

// POST /admin/revoke  { userId }  -> PRO ni bekor qilish
router.post('/revoke', requireAdmin, async (req, res) => {
  await query(
    `UPDATE subscriptions SET status = 'cancelled'
      WHERE user_id = $1 AND status = 'active'`,
    [req.body.userId]
  );
  res.json({ ok: true });
});

export default router;
