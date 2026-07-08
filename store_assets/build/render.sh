#!/usr/bin/env bash
# PulKam — Play Market screenshotlarini generatsiya qiladi va render qiladi.
# Ishlatish:  bash render.sh
set -e

BUILD="c:/Users/AbdulAziz/StudioProjects/pulkam/store_assets/build"
RAW="c:/Users/AbdulAziz/StudioProjects/pulkam/store_assets/raw"
OUT="c:/Users/AbdulAziz/StudioProjects/pulkam/store_assets/output"
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
ICON="c:/Users/AbdulAziz/StudioProjects/pulkam/assets/icon/app_icon.png"

# Slayd formatlari:  IMG | KICKER | TITLE_HTML | SUBTITLE | CLASS
slides=(
  "home.png|AI YORDAMCHI|Kirim va chiqimni<br><span class=g>AI orqali</span> oson boshqaring|Bir marta gapiring — amal avtomatik qo'shiladi|"
  "maqsadlar.png|MAQSADLAR|Ulkan <span class=g>maqsadlar</span> qo'ying<br>va ularga erishing|Har bir orzu uchun jamg'arma va muddat belgilang|"
  "qarzlar.png|QARZLAR|Kredit va qarzlaringizni<br>oson <span class=g>boshqaring</span> va yoping|Kim qarzdor, kimga qarzsiz — hammasi nazoratda|"
  "statistika.png|STATISTIKA|Pulingiz <span class=g>qayerga</span><br>ketayotganini biling|Aniq grafiklar va kategoriyalar bo'yicha tahlil|"
  "ai_chat.png|SUN'IY INTELLEKT|<span class=g>AI tahlilchi</span> bilan<br>pulingizni boshqaring|Shaxsiy moliyaviy maslahatchi doim yoningizda|"
  "sozlamalar.png|MOSLASH|Kategoriyalar, mavzular<br>va <span class=g>formatlash</span>|Ilovani butunlay o'zingizga moslab oling|"
  "pin.png|XAVFSIZLIK|Ma'lumotlaringiz <span class=g>himoyalangan</span><br>va telefoningizda saqlanadi|PIN-kod bilan qulflang — hech qayerga yuborilmaydi|"
  "statistika.png|—|Pulni boshqargan inson<br><span class=g>kuchli marralarga</span> erishadi|Bugun boshlang — kelajakdagi o'zingiz minnatdor bo'ladi|motiv"
)

echo "→ HTML slaydlar generatsiya qilinmoqda..."
i=0
missing=0
for s in "${slides[@]}"; do
  i=$((i+1))
  IFS='|' read -r IMG KICKER TITLE SUB CLASS <<< "$s"

  if [ ! -f "$RAW/$IMG" ]; then
    echo "  ⚠  YETISHMAYDI: raw/$IMG"
    missing=$((missing+1))
  fi

  KICKER_HTML=""
  if [ "$KICKER" != "—" ]; then
    KICKER_HTML="<div class=\"kicker\">$KICKER</div>"
  fi

  CROWN_HTML=""
  if [ "$CLASS" = "motiv" ]; then
    CROWN_HTML="<div class=\"crown\">🏆</div>"
  fi

  # Ikkinchi rasm bor bo'lsa — juft telefon layout (.png yoki .jpg)
  BASE="${IMG%.png}"
  IMG2=""
  if   [ -f "$RAW/${BASE}2.png" ]; then IMG2="${BASE}2.png"
  elif [ -f "$RAW/${BASE}2.jpg" ]; then IMG2="${BASE}2.jpg"
  fi
  if [ "$CLASS" != "motiv" ] && [ -n "$IMG2" ]; then
    PHONE_BLOCK="<div class=\"phone-wrap dual\">
    <div class=\"phone back\"><img src=\"../raw/$IMG\" alt=\"\"></div>
    <div class=\"phone front\"><img src=\"../raw/$IMG2\" alt=\"\"></div>
  </div>"
  else
    PHONE_BLOCK="<div class=\"phone-wrap\">
    <div class=\"phone\"><img src=\"../raw/$IMG\" alt=\"\"></div>
  </div>"
  fi

  cat > "$BUILD/slide$i.html" <<HTML
<!DOCTYPE html>
<html lang="uz">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="style.css">
</head>
<body class="$CLASS">
  <div class="glow"></div>
  <div class="grid"></div>
  <div class="headline">
    $CROWN_HTML
    $KICKER_HTML
    <h1 class="title">$TITLE</h1>
    <p class="subtitle">$SUB</p>
  </div>
  $PHONE_BLOCK
  <div class="brand">
    <img src="file:///$ICON" alt="">
    <span>PulKam</span>
  </div>
</body>
</html>
HTML
done

if [ "$missing" -gt 0 ]; then
  echo ""
  echo "⚠  $missing ta screenshot yetishmayapti — raw/ papkaga qo'ying va qayta ishga tushiring."
  echo "   (Yetishmagan kadrlar bo'sh rasm bilan chiqadi.)"
  echo ""
fi

echo "→ PNG render qilinmoqda (Chrome headless)..."
for n in 1 2 3 4 5 6 7 8; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --window-size=1080,1920 \
    --screenshot="$OUT/$n.png" \
    "file:///$BUILD/slide$n.html" 2>/dev/null || true
  echo "  ✓ output/$n.png"
done

echo ""
echo "✅ Tayyor →  store_assets/output/  (1.png … 8.png)"
