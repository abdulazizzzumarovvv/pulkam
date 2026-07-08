// Google Sign-In — ilova Google ID token yuboradi, biz tekshiramiz.
import express from 'express';
import { OAuth2Client } from 'google-auth-library';
import dotenv from 'dotenv';
import { query } from '../db/pool.js';
import { signUserToken } from '../middleware/auth.js';

dotenv.config();

const router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// POST /auth/google  { idToken }
// Ilova Google'dan olgan idToken ni yuboradi. Biz tekshirib, o'z JWT beramiz.
router.post('/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken kerak' });

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const p = ticket.getPayload();
    // p.sub — Google'ning barqaror foydalanuvchi ID si

    const { rows } = await query(
      `INSERT INTO users (google_sub, email, name, avatar_url)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (google_sub) DO UPDATE
         SET email = EXCLUDED.email,
             name = EXCLUDED.name,
             avatar_url = EXCLUDED.avatar_url
       RETURNING id, email, name, avatar_url`,
      [p.sub, p.email, p.name, p.picture]
    );
    const user = rows[0];

    res.json({
      token: signUserToken(user.id),
      user: { name: user.name, email: user.email, avatarUrl: user.avatar_url },
    });
  } catch (e) {
    console.error('google auth error:', e);
    res.status(401).json({ error: 'Google token tekshiruvdan o\'tmadi' });
  }
});

export default router;
