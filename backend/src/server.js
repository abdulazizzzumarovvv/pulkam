import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

import authRouter from './routes/auth.js';
import meRouter from './routes/me.js';
import paymentsRouter from './routes/payments.js';
import clickRouter from './routes/click.js';
import adminRouter from './routes/admin.js';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

app.use(cors());

// Click webhook'lari o'z body-parser'ini ishlatadi (urlencoded), shuning uchun
// global JSON parser'ni click'dan OLDIN emas, route ichida qo'llaymiz.
app.use('/click', clickRouter);

// Qolgan route'lar JSON
app.use(express.json());
app.use('/auth', authRouter);
app.use('/me', meRouter);
app.use('/payments', paymentsRouter);
app.use('/admin', adminRouter);

// Admin panel (statik HTML)
app.use('/admin-panel', express.static(path.join(__dirname, '../public/admin')));

// Sog'lik tekshiruvi
app.get('/health', (req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 PulKam backend ishlayapti — http://localhost:${PORT}`);
});
