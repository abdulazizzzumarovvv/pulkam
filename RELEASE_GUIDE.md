# PulKam — Google Play релиз yo'riqnomasi

## ✅ Kod tarafi (bajarilgan)
- Package name: `uz.pulkam.app`
- Release signing config (`key.properties` orqali)
- Proguard qoidalari + minify
- Privacy policy (uz/ru/en) → `privacy-policy/index.html`

---

## 1️⃣ Keystore yaratish (BIR MARTA — o'zingiz bajaring)

Git Bash / terminalda:

```bash
cd "c:/Users/AbdulAziz/StudioProjects/pulkam/android"

"/c/Program Files/Microsoft/jdk-21.0.10.7-hotspot/bin/keytool" -genkey -v \
  -keystore pulkam-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pulkam
```

Keyin `android/key.properties` faylini yarating:
```properties
storePassword=<store parolingiz>
keyPassword=<key parolingiz>
keyAlias=pulkam
storeFile=../pulkam-release.jks
```

> ⚠️ **`pulkam-release.jks` + parollarni yo'qotmang!** Yo'qolsa ilovani boshqa
> yangilay olmaysiz. Bulutga + fleshkaga nusxa saqlang.

---

## 2️⃣ Release AAB build qilish

```bash
cd "c:/Users/AbdulAziz/StudioProjects/pulkam"
flutter clean
flutter build appbundle --release --no-tree-shake-icons
```

Natija: `build/app/outputs/bundle/release/app-release.aab`
Shu faylni Play Console'ga yuklaysiz.

---

## 3️⃣ Privacy Policy'ni internetga qo'yish

`privacy-policy/index.html` ni ochiq URL qilish kerak. Eng oson — GitHub Pages:
1. GitHub'da repo oching, `index.html` ni yuklang
2. Settings → Pages → yoqing
3. URL: `https://username.github.io/repo/` — shu URL'ni Play Console'ga bering

---

## 4️⃣ Play Console — Store Listing

| Maydon | Qiymat |
|--------|--------|
| App name | PulKam |
| Qisqa tavsif (80) | Pul, maqsad va qarzlarni oson boshqaring — AI yordamida |
| To'liq tavsif | (pastda) |
| Screenshotlar | `store_assets/output/1.png … 8.png` |
| Icon | 512×512 (assets/icon dan) |
| Til | O'zbek (asosiy) + Rus + Ingliz |

### Developer brand (140 belgi, RU):
```
Умные финансовые приложения для контроля денег, целей и долгов. Просто, красиво и на вашем языке.
```

---

## 5️⃣ Play Console — Data Safety formasi

- **Ma'lumot yig'iladimi?** Ha
- **Moliyaviy ma'lumot** → faqat qurilmada saqlanadi, uchinchi tomonga BERILMAYDI
- **Ovoz (audio)** → OpenAI'ga yuboriladi (funksiya uchun), saqlanmaydi
- **Shifrlash** → Ha (HTTPS)
- **O'chirishni so'rash** → foydalanuvchi ma'lumotni ilovadan o'zi o'chiradi

---

## 6️⃣ Ruxsatlar (App content → Permissions)

- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` — **Google so'raydi**:
  > "Ilova aniq vaqtli eslatmalar (reminder) beradi. Foydalanuvchi belgilagan
  > vaqtda moliyaviy yozuvni eslatish uchun aniq alarm zarur."
- `RECORD_AUDIO` — "Ovozli kirim: foydalanuvchi gapirib xarajat qo'shadi."

---

## 7️⃣ Content rating + Target audience
- Anketa to'ldiring → 3+ / Everyone
- Maqsadli auditoriya: 18+ (moliyaviy ilova)

---

## Yakuniy checklist
- [ ] Keystore yaratildi + saqlandi
- [ ] key.properties to'ldirildi
- [ ] AAB build qilindi
- [ ] Privacy policy URL tayyor
- [ ] Screenshotlar (8 ta) yuklandi
- [ ] Data Safety to'ldirildi
- [ ] Ruxsatlar izohlandi
- [ ] Content rating
- [ ] Internal testing → Production
