// Click SHOP API yordamchilari — imzo tekshirish va konstantalar.
import crypto from 'crypto';
import dotenv from 'dotenv';

dotenv.config();

export const CLICK = {
  merchantId: process.env.CLICK_MERCHANT_ID,
  serviceId: process.env.CLICK_SERVICE_ID,
  secretKey: process.env.CLICK_SECRET_KEY,
  merchantUserId: process.env.CLICK_MERCHANT_USER_ID,
  returnUrl: process.env.CLICK_RETURN_URL || 'pulkam://payment-return',
};

// Click action kodlari
export const ACTION = { PREPARE: 0, COMPLETE: 1 };

// Click xato kodlari (rasmiy jadval)
export const ERR = {
  SUCCESS: 0,
  SIGN_CHECK_FAILED: -1,
  INCORRECT_AMOUNT: -2,
  ACTION_NOT_FOUND: -3,
  ALREADY_PAID: -4,
  USER_NOT_FOUND: -5,
  TRANSACTION_NOT_FOUND: -6,
  FAILED_TO_UPDATE: -7,
  ERROR_IN_REQUEST: -8,
  TRANSACTION_CANCELLED: -9,
};

/**
 * Prepare imzosini tekshiradi.
 * sign_string = md5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + amount + action + sign_time)
 */
export function verifyPrepareSign(p) {
  const raw =
    String(p.click_trans_id) +
    String(p.service_id) +
    CLICK.secretKey +
    String(p.merchant_trans_id) +
    String(p.amount) +
    String(p.action) +
    String(p.sign_time);
  return md5(raw) === p.sign_string;
}

/**
 * Complete imzosini tekshiradi (merchant_prepare_id qo'shiladi).
 * sign_string = md5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id
 *                   + merchant_prepare_id + amount + action + sign_time)
 */
export function verifyCompleteSign(p) {
  const raw =
    String(p.click_trans_id) +
    String(p.service_id) +
    CLICK.secretKey +
    String(p.merchant_trans_id) +
    String(p.merchant_prepare_id) +
    String(p.amount) +
    String(p.action) +
    String(p.sign_time);
  return md5(raw) === p.sign_string;
}

function md5(s) {
  return crypto.createHash('md5').update(s, 'utf8').digest('hex');
}

// Ilova ochadigan to'lov URL manzili
export function buildCheckoutUrl(orderId, amount) {
  const u = new URL('https://my.click.uz/services/pay');
  u.searchParams.set('service_id', CLICK.serviceId);
  u.searchParams.set('merchant_id', CLICK.merchantId);
  u.searchParams.set('amount', String(amount));
  u.searchParams.set('transaction_param', orderId);
  u.searchParams.set('return_url', CLICK.returnUrl);
  return u.toString();
}
