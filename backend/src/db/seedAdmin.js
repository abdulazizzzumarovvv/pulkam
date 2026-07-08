// Birinchi admin akkauntini yaratadi:  npm run seed:admin
// .env dagi ADMIN_EMAIL va ADMIN_PASSWORD ishlatiladi.
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import { pool } from './pool.js';

dotenv.config();

async function seed() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (!email || !password) {
    console.error('❌ .env da ADMIN_EMAIL va ADMIN_PASSWORD ni to\'ldiring.');
    process.exit(1);
  }
  const hash = await bcrypt.hash(password, 10);
  await pool.query(
    `INSERT INTO admins (email, password_hash) VALUES ($1, $2)
     ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash`,
    [email, hash]
  );
  console.log(`✅ Admin tayyor:  ${email}`);
  await pool.end();
}

seed().catch((e) => {
  console.error('❌ Seed xatosi:', e);
  process.exit(1);
});
