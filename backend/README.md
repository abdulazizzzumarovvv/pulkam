# PulKam Backend

Node.js + PostgreSQL. Google login, Click to'lovlari, admin panel.

## Ishga tushirish (lokal)

```bash
cd backend
npm install
cp .env.example .env      # .env ni to'ldiring
npm run migrate           # jadvallarni yaratadi
npm run seed:admin        # birinchi adminni yaratadi (.env dagi ADMIN_*)
npm run dev               # server → http://localhost:3000
```

- **Admin panel:** http://localhost:3000/admin-panel
- **Sog'lik:** http://localhost:3000/health

## Endpointlar

| Metod | Yo'l | Kim | Vazifa |
|-------|------|-----|--------|
| POST | `/auth/google` | ilova | Google idToken → bizning JWT |
| GET | `/me/pro` | ilova | PRO holati (server = haqiqat) |
| POST | `/payments/create` | ilova | To'lov yaratadi → Click URL |
| GET | `/payments/:orderId/status` | ilova | To'lov holatini polling |
| POST | `/click/prepare` | **Click** | webhook — imzo tekshiruvi |
| POST | `/click/complete` | **Click** | webhook — PRO yoqiladi |
| POST | `/admin/login` | admin | Email+parol → admin JWT |
| GET | `/admin/stats` `/users` `/payments` | admin | Panel ma'lumotlari |
| POST | `/admin/grant` `/revoke` | admin | Qo'lda PRO |

## Keyingi qadamlar

1. **Hosting** (Railway/Render) + domen (HTTPS) — Click webhook uchun public URL kerak.
2. **Click merchant**ga ariza: Prepare/Complete URL'larni berasiz:
   - `https://DOMEN/click/prepare`
   - `https://DOMEN/click/complete`
3. Click bergan `CLICK_*` qiymatlarni `.env` ga qo'yasiz.
4. **Google Cloud** OAuth client ID → `GOOGLE_CLIENT_ID`.
5. Ilovaga ulaymiz (Google login + PRO oqimi).

> ⚠️ Click imzo formulasi (`sign_string`) va xato kodlari `src/lib/click.js` da standart SHOP API bo'yicha yozilgan. Click PDF hujjati kelganda aniq tekshiramiz.
