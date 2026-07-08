// To'lov yaratish — ilova "PRO olish" bosganda chaqiradi.
import express from 'express';
import crypto from 'crypto';
import dotenv from 'dotenv';
import { query } from '../db/pool.js';
import { requireUser } from '../middleware/auth.js';
import { buildCheckoutUrl } from '../lib/click.js';

dotenv.config();

const router = express.Router();

const PRICES = {
  oylik: Number(process.env.PRICE_OYLIK || 14900),
  yillik: Number(process.env.PRICE_YILLIK || 159900),
  umrbod: Number(process.env.PRICE_UMRBOD || 249900),
};

// POST /payments/create  { plan }  -> { orderId, amount, checkoutUrl }
router.post('/create', requireUser, async (req, res) => {
  const { plan } = req.body;
  if (!['oylik', 'yillik', 'umrbod'].includes(plan)) {
    return res.status(400).json({ error: 'Noto\'g\'ri plan' });
  }
  const amount = PRICES[plan];
  const orderId = 'pk_' + crypto.randomBytes(8).toString('hex');

  await query(
    `INSERT INTO payments (user_id, order_id, plan, amount, status)
     VALUES ($1, $2, $3, $4, 'pending')`,
    [req.userId, orderId, plan, amount]
  );

  res.json({
    orderId,
    amount,
    checkoutUrl: buildCheckoutUrl(orderId, amount),
  });
});

// GET /payments/:orderId/status  -> ilova to'lov holatini polling qiladi
router.get('/:orderId/status', requireUser, async (req, res) => {
  const { rows } = await query(
    `SELECT status FROM payments WHERE order_id = $1 AND user_id = $2`,
    [req.params.orderId, req.userId]
  );
  if (rows.length === 0) return res.status(404).json({ error: 'Topilmadi' });
  res.json({ status: rows[0].status });
});

export default router;
