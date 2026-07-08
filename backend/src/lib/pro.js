// PRO holatini hisoblash va aktivlashtirish yordamchilari.
import { query } from '../db/pool.js';

// Plan -> muddat (kun). umrbod = muddatsiz.
export function planDuration(plan) {
  switch (plan) {
    case 'oylik': return 30;
    case 'yillik': return 365;
    case 'umrbod': return null; // muddatsiz
    default: return null;
  }
}

// To'lov tasdiqlangач obunani yoqadi.
export async function activatePro(userId, plan) {
  const days = planDuration(plan);
  const expiresAt = days === null
    ? null
    : new Date(Date.now() + days * 24 * 60 * 60 * 1000);

  await query(
    `INSERT INTO subscriptions (user_id, plan, status, starts_at, expires_at)
     VALUES ($1, $2, 'active', now(), $3)`,
    [userId, plan, expiresAt]
  );
}

// Foydalanuvchining joriy PRO holati (server = haqiqat manbai).
export async function getProStatus(userId) {
  const { rows } = await query(
    `SELECT plan, expires_at
       FROM subscriptions
      WHERE user_id = $1 AND status = 'active'
        AND (expires_at IS NULL OR expires_at > now())
      ORDER BY (expires_at IS NULL) DESC, expires_at DESC
      LIMIT 1`,
    [userId]
  );
  if (rows.length === 0) {
    return { isPro: false, plan: null, expiresAt: null };
  }
  const r = rows[0];
  return { isPro: true, plan: r.plan, expiresAt: r.expires_at };
}
