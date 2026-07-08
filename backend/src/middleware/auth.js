// JWT auth middleware'lari — ilova foydalanuvchisi va admin uchun.
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const SECRET = process.env.JWT_SECRET;

export function signUserToken(userId) {
  return jwt.sign({ uid: userId, kind: 'user' }, SECRET, { expiresIn: '365d' });
}

export function signAdminToken(adminId) {
  return jwt.sign({ aid: adminId, kind: 'admin' }, SECRET, { expiresIn: '7d' });
}

// Ilova foydalanuvchisi uchun himoya
export function requireUser(req, res, next) {
  const token = bearer(req);
  if (!token) return res.status(401).json({ error: 'Token yo\'q' });
  try {
    const p = jwt.verify(token, SECRET);
    if (p.kind !== 'user') throw new Error('kind');
    req.userId = p.uid;
    next();
  } catch {
    res.status(401).json({ error: 'Token yaroqsiz' });
  }
}

// Admin panel uchun himoya
export function requireAdmin(req, res, next) {
  const token = bearer(req);
  if (!token) return res.status(401).json({ error: 'Token yo\'q' });
  try {
    const p = jwt.verify(token, SECRET);
    if (p.kind !== 'admin') throw new Error('kind');
    req.adminId = p.aid;
    next();
  } catch {
    res.status(401).json({ error: 'Token yaroqsiz' });
  }
}

function bearer(req) {
  const h = req.headers.authorization || '';
  return h.startsWith('Bearer ') ? h.slice(7) : null;
}
