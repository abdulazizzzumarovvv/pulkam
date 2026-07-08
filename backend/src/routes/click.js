// Click SHOP API webhook'lari — Click serveri shu endpoint'larni chaqiradi.
// Ikki bosqich: Prepare (action=0) va Complete (action=1).
import express from 'express';
import { query } from '../db/pool.js';
import {
  ACTION, ERR,
  verifyPrepareSign, verifyCompleteSign,
} from '../lib/click.js';
import { activatePro } from '../lib/pro.js';

const router = express.Router();

// Click x-www-form-urlencoded yuboradi
router.use(express.urlencoded({ extended: true }));

// ── PREPARE ────────────────────────────────────────────────────────────
// POST /click/prepare
router.post('/prepare', async (req, res) => {
  const p = req.body;

  if (!verifyPrepareSign(p)) {
    return res.json(reply(p, ERR.SIGN_CHECK_FAILED, 'Imzo noto\'g\'ri'));
  }

  // order_id (bizniki) = merchant_trans_id (Click)
  const { rows } = await query(
    `SELECT * FROM payments WHERE order_id = $1`,
    [p.merchant_trans_id]
  );
  const pay = rows[0];
  if (!pay) {
    return res.json(reply(p, ERR.TRANSACTION_NOT_FOUND, 'To\'lov topilmadi'));
  }
  if (pay.status === 'paid') {
    return res.json(reply(p, ERR.ALREADY_PAID, 'Allaqachon to\'langan'));
  }
  if (Number(pay.amount) !== Number(p.amount)) {
    return res.json(reply(p, ERR.INCORRECT_AMOUNT, 'Summa mos emas'));
  }

  await query(
    `UPDATE payments
        SET status = 'prepared', click_trans_id = $1, click_paydoc_id = $2, prepare_id = id
      WHERE order_id = $3`,
    [p.click_trans_id, p.click_paydoc_id, p.merchant_trans_id]
  );

  res.json({
    ...reply(p, ERR.SUCCESS, 'Success'),
    merchant_prepare_id: pay.id,
  });
});

// ── COMPLETE ───────────────────────────────────────────────────────────
// POST /click/complete
router.post('/complete', async (req, res) => {
  const p = req.body;

  if (!verifyCompleteSign(p)) {
    return res.json(reply(p, ERR.SIGN_CHECK_FAILED, 'Imzo noto\'g\'ri'));
  }

  const { rows } = await query(
    `SELECT * FROM payments WHERE order_id = $1`,
    [p.merchant_trans_id]
  );
  const pay = rows[0];
  if (!pay) {
    return res.json(reply(p, ERR.TRANSACTION_NOT_FOUND, 'To\'lov topilmadi'));
  }
  if (String(pay.id) !== String(p.merchant_prepare_id)) {
    return res.json(reply(p, ERR.TRANSACTION_NOT_FOUND, 'Prepare ID mos emas'));
  }
  if (pay.status === 'paid') {
    return res.json(reply(p, ERR.ALREADY_PAID, 'Allaqachon to\'langan'));
  }

  // Click tomondan xato bo'lsa — bekor qilamiz
  if (Number(p.error) < 0) {
    await query(`UPDATE payments SET status = 'cancelled' WHERE order_id = $1`,
      [p.merchant_trans_id]);
    return res.json(reply(p, ERR.TRANSACTION_CANCELLED, 'Bekor qilindi'));
  }

  // To'lov muvaffaqiyatli — PRO ni yoqamiz
  await query(
    `UPDATE payments SET status = 'paid', paid_at = now() WHERE order_id = $1`,
    [p.merchant_trans_id]
  );
  if (pay.user_id) {
    await activatePro(pay.user_id, pay.plan);
  }

  res.json({
    ...reply(p, ERR.SUCCESS, 'Success'),
    merchant_confirm_id: pay.id,
  });
});

// Click javob shabloni
function reply(p, error, note) {
  return {
    click_trans_id: p.click_trans_id,
    merchant_trans_id: p.merchant_trans_id,
    error,
    error_note: note,
  };
}

export default router;
