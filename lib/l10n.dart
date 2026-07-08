import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ── Qo'llab-quvvatlanadigan tillar ───────────────────────────────────────────
const kSupportedLocales = [
  Locale('uz'),
  Locale('ru'),
  Locale('en'),
];

// ── Extension: context.l10n ───────────────────────────────────────────────────
extension AppL10nX on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
}

// ── Asosiy class ─────────────────────────────────────────────────────────────
class AppL10n {
  final String lang;
  const AppL10n(this.lang);

  static AppL10n of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppL10n(locale.languageCode);
  }

  String _t(Map<String, String> m) => m[lang] ?? m['uz']!;

  // ── App nomi ─────────────────────────────────────────────────────────────
  String get appName => _t({
        'uz': 'PulKam',
        'ru': 'МалоДенег',
        'en': 'LittleMoney',
      });
  String get proOlish => _t({
        'uz': 'PRO olish',
        'ru': 'Получить PRO',
        'en': 'Get PRO',
      });

  // ── Pro sahifasi ─────────────────────────────────────────────────────────
  String get proTagline => _t({
        'uz': "Pulingiz qayerga ketayotganini to'liq nazorat qiling",
        'ru': 'Полный контроль над вашими деньгами',
        'en': 'Take full control of your money',
      });
  String get proYillik => _t({
        'uz': 'Yillik',
        'ru': 'Годовая',
        'en': 'Annual',
      });
  String get proOylik => _t({
        'uz': 'Oylik',
        'ru': 'Месячная',
        'en': 'Monthly',
      });
  String get proHaftasiga => _t({
        'uz': 'haftasiga',
        'ru': 'в неделю',
        'en': 'per week',
      });
  String get proFoydaOvoz => _t({
        'uz': "Ovoz orqali kirim-chiqim boshqarish (AI)",
        'ru': 'Управление операциями голосом (ИИ)',
        'en': 'Voice-controlled transactions (AI)',
      });
  String get proFoydaAnaliz => _t({
        'uz': 'AI bilan analiz',
        'ru': 'Анализ с помощью ИИ',
        'en': 'AI-powered analysis',
      });
  String get proFoydaKategoriya => _t({
        'uz': "Cheksiz kirim-chiqim kategoriyalari",
        'ru': 'Безлимитные категории операций',
        'en': 'Unlimited categories',
      });
  String get proFoydaMavzu => _t({
        'uz': "Qo'shimcha gradient mavzular",
        'ru': 'Дополнительные градиентные темы',
        'en': 'Extra gradient themes',
      });
  String get proFoydaQarzMaqsad => _t({
        'uz': 'Cheksiz qarzlar va maqsadlar',
        'ru': 'Безлимитные долги и цели',
        'en': 'Unlimited debts and goals',
      });
  String get proUmrbod => _t({
        'uz': 'Umrbod',
        'ru': 'Навсегда',
        'en': 'Lifetime',
      });
  String get proBirMartalik => _t({
        'uz': "Bir martalik to'lov",
        'ru': 'Разовый платёж',
        'en': 'One time payment',
      });
  String get proUmrbodIzoh => _t({
        'uz': "Barcha kelajakdagi funksiyalar qo'shimcha to'lovsiz",
        'ru': 'Все будущие функции без доплаты',
        'en': 'All future features included at no additional cost',
      });
  String get proCheklanganTaklif => _t({
        'uz': 'Cheklangan taklif',
        'ru': 'Ограниченное предложение',
        'en': 'Limited offer',
      });
  String get proDavomEtish => _t({
        'uz': 'Davom ettirish',
        'ru': 'Продолжить',
        'en': 'Continue',
      });
  String get proObunaBolish => _t({
        'uz': "Obuna bo'lish",
        'ru': 'Подписаться',
        'en': 'Subscribe',
      });
  String get proObunaTasdiq => _t({
        'uz': "Obuna avtomatik yangilanadi, istalgan vaqtda bekor qilishingiz mumkin.",
        'ru': 'Подписка продлевается автоматически, отменить можно в любой момент.',
        'en': 'Subscription renews automatically, cancel anytime.',
      });
  String get proMuvaffaqiyat => _t({
        'uz': "Tabriklaymiz! Siz endi PRO obunachisiz 🎉",
        'ru': 'Поздравляем! Теперь вы PRO-подписчик 🎉',
        'en': "Congratulations! You're now a PRO subscriber 🎉",
      });
  String get proAllaqachon => _t({
        'uz': 'Siz PRO obunachisiz',
        'ru': 'Вы PRO-подписчик',
        'en': "You're a PRO subscriber",
      });
  String get proTugadi => _t({
        'uz': 'PRO obunangiz tugadi',
        'ru': 'Ваша PRO-подписка закончилась',
        'en': 'Your PRO subscription has expired',
      });
  String get proTugadiMatn => _t({
        'uz': "PRO imkoniyatlaridan foydalanishda davom etish uchun obunani yangilang.",
        'ru': 'Продлите подписку, чтобы продолжить пользоваться возможностями PRO.',
        'en': 'Renew your subscription to keep using PRO features.',
      });
  // ── Ovoz orqali kirim-chiqim ─────────────────────────────────────────
  String get ovozGapiring => _t({
        'uz': 'Gapiring...',
        'ru': 'Говорите...',
        'en': 'Speak...',
      });
  String get ovozTahlil => _t({
        'uz': 'Tahlil qilinmoqda...',
        'ru': 'Анализирую...',
        'en': 'Analyzing...',
      });
  String get ovozQoshildi => _t({
        'uz': "Qo'shildi",
        'ru': 'Добавлено',
        'en': 'Added',
      });
  String get ovozTushunmadim => _t({
        'uz': 'Tushunmadim',
        'ru': 'Не понял',
        'en': "Didn't understand",
      });
  String get ovozKatTopilmadi => _t({
        'uz': 'Kategoriya topilmadi',
        'ru': 'Категория не найдена',
        'en': 'Category not found',
      });
  String get ovozXato => _t({
        'uz': "Xatolik yuz berdi, qayta urinib ko'ring",
        'ru': 'Произошла ошибка, попробуйте ещё раз',
        'en': 'Something went wrong, try again',
      });
  String get ovozBalansYetmaydi => _t({
        'uz': 'Hisobda mablag\' yetarli emas',
        'ru': 'Недостаточно средств на счёте',
        'en': 'Insufficient account balance',
      });
  String get ovozYoriqnoma => _t({
        'uz': "Kategoriya nomi va summani ayting. Masalan:\n\n"
            "•  «Transport 1700 so'm»\n"
            "•  «Oziq-ovqat 50 ming»\n"
            "•  «Oylik 5 million kirim»\n"
            "•  «Naqddan kafe 30 ming»",
        'ru': 'Назовите категорию и сумму. Например:\n\n'
            '•  «Транспорт 1700 сум»\n'
            '•  «Продукты 50 тысяч»\n'
            '•  «Зарплата 5 миллионов доход»\n'
            '•  «С наличных кафе 30 тысяч»',
        'en': 'Say the category and amount. For example:\n\n'
            '•  "Transport 1700"\n'
            '•  "Food 50 thousand"\n'
            '•  "Salary 5 million income"\n'
            '•  "Cafe 30 thousand from cash"',
      });
  String get ovozBosing => _t({
        'uz': "Gapirib bo'lgach mikrofonni bosing",
        'ru': 'Закончив говорить, нажмите на микрофон',
        'en': "Tap the mic when you're done speaking",
      });
  String get ovozRuxsatYoq => _t({
        'uz': "Mikrofon ruxsati berilmagan yoki ovoz tanish mavjud emas",
        'ru': 'Нет доступа к микрофону или распознавание недоступно',
        'en': 'Microphone permission denied or speech recognition unavailable',
      });
  // ── AI chat (moliyaviy maslahatchi) ──────────────────────────────────
  String get aiSarlavha => _t({
        'uz': 'AI maslahatchi',
        'ru': 'ИИ-советник',
        'en': 'AI Advisor',
      });
  String get aiYozing => _t({
        'uz': 'Savolingizni yozing...',
        'ru': 'Напишите вопрос...',
        'en': 'Type your question...',
      });
  String get aiHintXarajat => _t({
        'uz': 'Xarajatlarimni tahlil qil',
        'ru': 'Проанализируй мои расходы',
        'en': 'Analyze my spending',
      });
  String get aiHintTejash => _t({
        'uz': 'Qanday tejashim mumkin?',
        'ru': 'Как мне экономить?',
        'en': 'How can I save money?',
      });
  String get aiHintKopaytirish => _t({
        'uz': "Pulni qanday ko'paytiraman?",
        'ru': 'Как приумножить деньги?',
        'en': 'How do I grow my money?',
      });
  String get aiHintQarz => _t({
        'uz': 'Qarzlarni qanday tez yopaman?',
        'ru': 'Как быстрее закрыть долги?',
        'en': 'How to pay off debts faster?',
      });
  String get aiHintMaqsad => _t({
        'uz': 'Maqsadlarimga qanday tez erishaman?',
        'ru': 'Как быстрее достичь целей?',
        'en': 'How to reach my goals faster?',
      });
  // ── Tutorial (yo'riqnoma turi) ───────────────────────────────────────
  String get tutKeyingi => _t({
        'uz': 'Keyingi',
        'ru': 'Далее',
        'en': 'Next',
      });
  String get tutOtkazish => _t({
        'uz': "O'tkazib yuborish",
        'ru': 'Пропустить',
        'en': 'Skip',
      });
  String get tutPlus => _t({
        'uz': "Bu tugma orqali kirim va chiqim qo'shasiz. Ko'rib chiqamiz!",
        'ru': 'Эта кнопка добавляет доходы и расходы. Давайте посмотрим!',
        'en': "This button adds income and expenses. Let's take a look!",
      });
  String get tutKategoriya => _t({
        'uz': 'Avval kategoriyani tanlang',
        'ru': 'Сначала выберите категорию',
        'en': 'First, choose a category',
      });
  String get tutKarta => _t({
        'uz': 'Keyin qaysi hisobdan — kartani tanlang',
        'ru': 'Затем выберите счёт — карту',
        'en': 'Then pick the account — a card',
      });
  String get tutKalkulyator => _t({
        'uz': "Summani kiritib ✓ tugmasini bosing — amal saqlanadi",
        'ru': 'Введите сумму и нажмите ✓ — операция сохранится',
        'en': 'Enter the amount and tap ✓ — the transaction is saved',
      });
  String get tutStatistika => _t({
        'uz': "Chapga sursangiz — Statistika: oylik kirim-chiqim va kategoriyalar tahlili",
        'ru': 'Свайп влево — Статистика: анализ доходов, расходов и категорий за месяц',
        'en': 'Swipe left — Statistics: monthly income, expenses and category breakdown',
      });
  String get tutHisoblar => _t({
        'uz': "O'ngga sursangiz — Hisoblar. Sarlavhani surib Qarzlar va Maqsadlarga o'tasiz",
        'ru': 'Свайп вправо — Счета. Проведя по заголовку, перейдёте к Долгам и Целям',
        'en': 'Swipe right — Accounts. Swipe the title to reach Debts and Goals',
      });
  String get tutSettings => _t({
        'uz': 'Sozlamalar shu yerda. Ochib ko\'ramiz!',
        'ru': 'Настройки здесь. Откроем!',
        'en': "Settings are here. Let's open them!",
      });
  String get tutSettingsIchi => _t({
        'uz': "Bu yerda: til, valyuta, mavzu, PIN-kod va eslatmalar sozlanadi",
        'ru': 'Здесь настраиваются: язык, валюта, тема, PIN-код и напоминания',
        'en': 'Here you set: language, currency, theme, PIN and reminders',
      });
  String get tutProfil => _t({
        'uz': "Va nihoyat — profilingiz. Ism va rasm qo'shing!",
        'ru': 'И наконец — ваш профиль. Добавьте имя и фото!',
        'en': 'And finally — your profile. Add a name and photo!',
      });
  String get tutBirinchiKirim => _t({
        'uz': "Endi birinchi kirimingizni qiling — '+' tugmasini bosing!",
        'ru': "Теперь добавьте свой первый доход — нажмите '+'!",
        'en': "Now make your first income — tap '+'!",
      });
  String get tutSupport => _t({
        'uz': "Savollaringiz bo'lsa — supportga yozing.\nIlovadan foydalanish yoqimli bo'lsin! 🎉",
        'ru': 'Если появятся вопросы — напишите в поддержку.\nПриятного использования! 🎉',
        'en': 'If you have any questions — write to support.\nEnjoy the app! 🎉',
      });
  String get aboutMatn => _t({
        'uz': "yolg'iz Flutter dasturchi tomonidan yaratilgan ilova",
        'ru': 'приложение, созданное Flutter-разработчиком в одиночку',
        'en': 'an app built by a solo Flutter developer',
      });
  /// Maqsad muddati: "26 dekabr 2026 gacha"
  String maqsadMuddat(String sana) => _t({
        'uz': '$sana gacha',
        'ru': 'до $sana',
        'en': 'up to $sana',
      });
  String get iltimosNomKiriting => _t({
        'uz': 'Iltimos nomini kiriting',
        'ru': 'Пожалуйста, введите название',
        'en': 'Please enter a name',
      });
  String get tushunarli => _t({
        'uz': 'Tushunarli',
        'ru': 'Понятно',
        'en': 'Got it',
      });
  String get ajoyib => _t({
        'uz': 'Ajoyib!',
        'ru': 'Отлично!',
        'en': 'Awesome!',
      });
  String get proChegirma => _t({
        'uz': 'chegirma',
        'ru': 'скидка',
        'en': 'off',
      });
  String get proMavzular => _t({
        'uz': 'PRO mavzular',
        'ru': 'PRO темы',
        'en': 'PRO themes',
      });

  // ── Salomlashish ────────────────────────────────────────────────────────
  String get salom => _t({
        'uz': 'Salom',
        'ru': 'Привет',
        'en': 'Hello',
      });

  // ── Profil ──────────────────────────────────────────────────────────────

  // ── Umumiy ──────────────────────────────────────────────────────────────
  String get umumiyBalans => _t({
        'uz': 'Umumiy balans',
        'ru': 'Общий баланс',
        'en': 'Total balance',
      });
  String get saqlash => _t({
        'uz': 'Saqlash',
        'ru': 'Сохранить',
        'en': 'Save',
      });
  String get bekorQilish => _t({
        'uz': 'Bekor qilish',
        'ru': 'Отмена',
        'en': 'Cancel',
      });
  String get ochirish => _t({
        'uz': "O'chirish",
        'ru': 'Удалить',
        'en': 'Delete',
      });
  String get tahrirlash => _t({
        'uz': 'Tahrirlash',
        'ru': 'Изменить',
        'en': 'Edit',
      });
  String get tasdiqOchirish => _t({
        'uz': "Rostan ham o'chirmoqchimisiz?",
        'ru': 'Вы уверены, что хотите удалить?',
        'en': 'Are you sure you want to delete?',
      });
  String get ha => _t({
        'uz': 'Ha',
        'ru': 'Да',
        'en': 'Yes',
      });
  String get yoq => _t({
        'uz': "Yo'q",
        'ru': 'Нет',
        'en': 'No',
      });
  String get qidirish => _t({
        'uz': 'Qidirish',
        'ru': 'Поиск',
        'en': 'Search',
      });
  String get hechNarsa => _t({
        'uz': 'Hech narsa topilmadi',
        'ru': 'Ничего не найдено',
        'en': 'Nothing found',
      });

  // ── Amallar ─────────────────────────────────────────────────────────────
  String get amallar => _t({
        'uz': 'Amallar',
        'ru': 'Операции',
        'en': 'Transactions',
      });
  String get barchaAmallar => _t({
        'uz': 'Barcha amallar',
        'ru': 'Все операции',
        'en': 'All transactions',
      });
  String get amalsizOy => _t({
        'uz': "Bu oyda amallar yo'q",
        'ru': 'В этом месяце нет операций',
        'en': 'No transactions this month',
      });
  String get haliAmallarYoq => _t({
        'uz': "Hali amallar mavjud emas",
        'ru': 'Операций пока нет',
        'en': 'No transactions yet',
      });
  String get bugunAmallarYoq => _t({
        'uz': 'Bugun amallar yo\'q',
        'ru': 'Сегодня операций нет',
        'en': 'No transactions today',
      });
  String get otkazma => _t({
        'uz': 'O\'tkazma',
        'ru': 'Перевод',
        'en': 'Transfer',
      });
  String get comingSoon => _t({
        'uz': 'Tez orada',
        'ru': 'Скоро',
        'en': 'Coming soon',
      });
  String get kirim => _t({
        'uz': 'Kirim',
        'ru': 'Доход',
        'en': 'Income',
      });
  String get chiqim => _t({
        'uz': 'Chiqim',
        'ru': 'Расход',
        'en': 'Expense',
      });

  // ── Hisoblar ────────────────────────────────────────────────────────────
  String get hisoblar => _t({
        'uz': 'Hisoblar',
        'ru': 'Счета',
        'en': 'Accounts',
      });
  String get maqsadlar => _t({
        'uz': 'Maqsadlar',
        'ru': 'Цели',
        'en': 'Goals',
      });
  String get qarzlar => _t({
        'uz': 'Qarzlar',
        'ru': 'Долги',
        'en': 'Debts',
      });
  String get hisobYoq => _t({
        'uz': "Hisob mavjud emas",
        'ru': 'Нет счетов',
        'en': 'No accounts',
      });
  String get maqsadYoq => _t({
        'uz': "Maqsad mavjud emas",
        'ru': 'Нет целей',
        'en': 'No goals',
      });
  String get qarzYoq => _t({
        'uz': "Qarz mavjud emas",
        'ru': 'Нет долгов',
        'en': 'No debts',
      });
  String get yangiHisob => _t({
        'uz': 'Yangi Hisob',
        'ru': 'Новый счёт',
        'en': 'New Account',
      });
  String get hisobniTahrirlash => _t({
        'uz': 'Hisobni tahrirlash',
        'ru': 'Изменить счёт',
        'en': 'Edit Account',
      });
  String get yangiMaqsad => _t({
        'uz': 'Yangi Maqsad',
        'ru': 'Новая цель',
        'en': 'New Goal',
      });
  String get maqsadniTahrirlash => _t({
        'uz': 'Maqsadni tahrirlash',
        'ru': 'Изменить цель',
        'en': 'Edit Goal',
      });
  String get yangiQarz => _t({
        'uz': 'Yangi Qarz',
        'ru': 'Новый долг',
        'en': 'New Debt',
      });
  String get maqsadBajarildi => _t({
        'uz': 'MAQSAD BAJARILDI',
        'ru': 'ЦЕЛЬ ДОСТИГНУТА',
        'en': 'GOAL ACHIEVED',
      });
  String get maqsadgaOlga => _t({
        'uz': "Maqsad sari Olg'a!!!",
        'ru': 'Вперёд к цели!!!',
        'en': 'Onwards to the goal!!!',
      });
  String get taslimBolma => _t({
        'uz': "Maqsadga erishmadinz, taslim bo'lmang!",
        'ru': 'Цель не достигнута, не сдавайтесь!',
        'en': "Goal not reached, don't give up!",
      });
  String get bajarilganMaqsadlar => _t({
        'uz': 'Bajarilgan maqsadlar',
        'ru': 'Достигнутые цели',
        'en': 'Achieved goals',
      });
  String get bajarilganMaqsadYoq => _t({
        'uz': "Hech qanday bajarilgan maqsadlar mavjud emas",
        'ru': 'Нет достигнутых целей',
        'en': 'No achieved goals yet',
      });
  String get yopilganQarzlar => _t({
        'uz': 'Yopilgan qarzlar',
        'ru': 'Закрытые долги',
        'en': 'Closed debts',
      });
  String get yopilganQarzYoq => _t({
        'uz': "Hech qanday yopilgan qarz mavjud emas",
        'ru': 'Нет закрытых долгов',
        'en': 'No closed debts yet',
      });
  String get qarzsizHayot => _t({
        'uz': "Qarzsiz hayot — yengil hayot!",
        'ru': 'Жизнь без долгов — лёгкая жизнь!',
        'en': 'Debt-free life is a light life!',
      });
  String get umumiyBalansaTasir => _t({
        'uz': "Umumiy balansingizga ta'sir qiladi",
        'ru': 'Это повлияет на ваш общий баланс',
        'en': 'This will affect your total balance',
      });
  String get boshqaHisobYoq => _t({
        'uz': "O'tkazish uchun boshqa hisob mavjud emas",
        'ru': 'Нет другого счёта для перевода',
        'en': 'No other account to transfer to',
      });
  String get boshqaMaqsadYoq => _t({
        'uz': "O'tkazish uchun boshqa maqsad mavjud emas",
        'ru': 'Нет другой цели для перевода',
        'en': 'No other goal to transfer to',
      });
  String get qaytarildi => _t({
        'uz': 'QAYTARILDI',
        'ru': 'ВОЗВРАТ',
        'en': 'RETURNED',
      });
  String get tolangan => _t({
        'uz': "TO'LANGAN",
        'ru': 'ОПЛАЧЕНО',
        'en': 'PAID',
      });
  String get hisobNomi => _t({
        'uz': 'Hisob nomi',
        'ru': 'Название счёта',
        'en': 'Account name',
      });
  String get maqsadNomi => _t({
        'uz': 'Maqsad nomi',
        'ru': 'Название цели',
        'en': 'Goal name',
      });
  String get boshlangichBalans => _t({
        'uz': "Boshlang'ich balans",
        'ru': 'Начальный баланс',
        'en': 'Initial balance',
      });
  String get maqsadSumma => _t({
        'uz': 'Maqsad summasi',
        'ru': 'Целевая сумма',
        'en': 'Target amount',
      });
  String get rang => _t({
        'uz': 'Rang',
        'ru': 'Цвет',
        'en': 'Color',
      });
  String get icon => _t({
        'uz': 'Icon',
        'ru': 'Иконка',
        'en': 'Icon',
      });
  String get iconTanlang => _t({
        'uz': 'Icon tanlang',
        'ru': 'Выберите иконку',
        'en': 'Choose icon',
      });
  String get rangTanlang => _t({
        'uz': 'Rang tanlang',
        'ru': 'Выберите цвет',
        'en': 'Choose color',
      });
  String get otkazish => _t({
        'uz': "O'tkazish",
        'ru': 'Перевод',
        'en': 'Transfer',
      });
  String get toplash => _t({
        'uz': "Qo'shish",
        'ru': 'Пополнить',
        'en': 'Add funds',
      });
  String get tolovQoshish => _t({
        'uz': "To'lov qo'shish",
        'ru': 'Добавить платёж',
        'en': 'Add payment',
      });
  String get asosiySumma => _t({
        'uz': 'Asosiy summa',
        'ru': 'Основная сумма',
        'en': 'Principal amount',
      });
  String get tolangan2 => _t({
        'uz': "To'langan",
        'ru': 'Оплачено',
        'en': 'Paid',
      });
  String get qolgan => _t({
        'uz': 'Qolgan',
        'ru': 'Осталось',
        'en': 'Remaining',
      });
  String get berdim => _t({
        'uz': 'Berdim',
        'ru': 'Дал',
        'en': 'Lent',
      });
  String get oldim => _t({
        'uz': 'Oldim',
        'ru': 'Взял',
        'en': 'Borrowed',
      });
  String get kimdan => _t({
        'uz': 'Kimdan / Kimga',
        'ru': 'Кому / От кого',
        'en': 'To / From whom',
      });

  // ── Kategoriya ───────────────────────────────────────────────────────────
  String get statistika => _t({
        'uz': 'Statistika',
        'ru': 'Статистика',
        'en': 'Statistics',
      });
  String get malumotYoq => _t({
        'uz': "Bu oyda ma'lumot yo'q",
        'ru': 'Нет данных за этот месяц',
        'en': 'No data for this month',
      });
  String get kunlikOrtacha => _t({
        'uz': "Kunlik o'rtacha",
        'ru': 'Среднее в день',
        'en': 'Daily average',
      });
  String get kunlikOrtachaChiqim => _t({
        'uz': "Kunlik o'rtacha chiqim",
        'ru': 'Среднее расходов в день',
        'en': 'Daily avg. expense',
      });
  String get kunlikOrtachaKirim => _t({
        'uz': "Kunlik o'rtacha kirim",
        'ru': 'Среднее доходов в день',
        'en': 'Daily avg. income',
      });
  String get kunlikDinamika => _t({
        'uz': 'Kunlik dinamika',
        'ru': 'Динамика по дням',
        'en': 'Daily dynamics',
      });
  String get oylikChiqim => _t({
        'uz': 'Oylik chiqim',
        'ru': 'Расход за месяц',
        'en': 'Monthly expense',
      });
  String get oylikKirim => _t({
        'uz': 'Oylik kirim',
        'ru': 'Доход за месяц',
        'en': 'Monthly income',
      });
  String get yangiKategoriya => _t({
        'uz': 'Yangi Kategoriya',
        'ru': 'Новая категория',
        'en': 'New Category',
      });
  String get kategoriyaniTahrirlash => _t({
        'uz': 'Kategoriyani tahrirlash',
        'ru': 'Изменить категорию',
        'en': 'Edit Category',
      });
  String get kategoriyaNomi => _t({
        'uz': 'Kategoriya nomi',
        'ru': 'Название категории',
        'en': 'Category name',
      });

  // ── Sozlamalar ───────────────────────────────────────────────────────────
  String get sozlamalar => _t({
        'uz': 'Sozlamalar',
        'ru': 'Настройки',
        'en': 'Settings',
      });
  String get asosiyVaIuta => _t({
        'uz': 'Asosiy valyuta',
        'ru': 'Основная валюта',
        'en': 'Main currency',
      });
  String get formatlash => _t({
        'uz': 'Formatlash',
        'ru': 'Формат чисел',
        'en': 'Number format',
      });
  String get mavzular => _t({
        'uz': 'Mavzular',
        'ru': 'Темы',
        'en': 'Themes',
      });
  String get til => _t({
        'uz': 'Til',
        'ru': 'Язык',
        'en': 'Language',
      });
  String get xavfsizlik => _t({
        'uz': 'Xavfsizlik va bildirishnomalar',
        'ru': 'Безопасность и уведомления',
        'en': 'Security & notifications',
      });
  String get pinKod => _t({
        'uz': 'PIN kod',
        'ru': 'PIN-код',
        'en': 'PIN code',
      });
  String get bildirishnomalar => _t({
        'uz': 'Bildirishnomalar',
        'ru': 'Уведомления',
        'en': 'Notifications',
      });
  String get boshqa => _t({
        'uz': 'Boshqa',
        'ru': 'Прочее',
        'en': 'Other',
      });
  String get bizHaqimizda => _t({
        'uz': 'Biz haqimizda',
        'ru': 'О нас',
        'en': 'About us',
      });
  String get yoriqnoma => _t({
        'uz': "Ilova yo'riqnomasi",
        'ru': 'Руководство пользователя',
        'en': 'User guide',
      });
  String get mavzu => _t({
        'uz': 'Mavzu',
        'ru': 'Тема',
        'en': 'Theme',
      });
  String get raqamFormati => _t({
        'uz': 'Raqam formati',
        'ru': 'Формат чисел',
        'en': 'Number format',
      });
  String get valyutaniTanlang => _t({
        'uz': 'Valyutani tanlang',
        'ru': 'Выберите валюту',
        'en': 'Choose currency',
      });
  String get nomYokiKod => _t({
        'uz': "Nom yoki kod bo'yicha qidiring",
        'ru': 'Поиск по названию или коду',
        'en': 'Search by name or code',
      });
  String get mashhurValyutalar => _t({
        'uz': 'Mashhur valyutalar',
        'ru': 'Популярные валюты',
        'en': 'Popular currencies',
      });
  String get barchaValyutalar => _t({
        'uz': 'Barcha valyutalar',
        'ru': 'Все валюты',
        'en': 'All currencies',
      });
  String get tilniTanlang => _t({
        'uz': 'Tilni tanlang',
        'ru': 'Выберите язык',
        'en': 'Choose language',
      });
  String get defaultTil => _t({
        'uz': 'Standart',
        'ru': 'По умолчанию',
        'en': 'Default',
      });
  String get eslatmalar => _t({
        'uz': 'Eslatmalar',
        'ru': 'Напоминания',
        'en': 'Reminders',
      });
  String get pinKodYarating => _t({
        'uz': 'PIN kod yarating',
        'ru': 'Создайте PIN-код',
        'en': 'Create PIN code',
      });
  String get pinKodKiriting => _t({
        'uz': 'PIN kodni kiriting',
        'ru': 'Введите PIN-код',
        'en': 'Enter PIN code',
      });

  // ── AI Analiz ────────────────────────────────────────────────────────────
  String get ortachaXarajat => _t({
        'uz': "O'rtacha xarajat",
        'ru': 'Средние расходы',
        'en': 'Average expenses',
      });
  String get birKunda => _t({
        'uz': 'Bir kunda',
        'ru': 'В день',
        'en': 'Per day',
      });
  String get birHaftada => _t({
        'uz': 'Bir haftada',
        'ru': 'В неделю',
        'en': 'Per week',
      });

  // ── Calculator sheets ─────────────────────────────────────────────────
  String get summaKiriting => _t({
        'uz': 'Summa kiriting',
        'ru': 'Введите сумму',
        'en': 'Enter amount',
      });
  String get izoh => _t({
        'uz': 'Izoh (ixtiyoriy)',
        'ru': 'Комментарий (необязательно)',
        'en': 'Note (optional)',
      });
  String get kategoriya => _t({
        'uz': 'Kategoriya',
        'ru': 'Категория',
        'en': 'Category',
      });
  String get hisob => _t({
        'uz': 'Hisob',
        'ru': 'Счёт',
        'en': 'Account',
      });

  // ── Profil ───────────────────────────────────────────────────────────
  String get profil          => _t({'uz': 'Profil',             'ru': 'Профиль',          'en': 'Profile'});
  String get ismKiriting     => _t({'uz': 'Ismingizni kiriting','ru': 'Введите имя',       'en': 'Enter first name'});
  String get familiyaKiriting=> _t({'uz': 'Familiyangizni kiriting','ru': 'Введите фамилию','en': 'Enter last name'});
  String get ismXato         => _t({'uz': 'Iltimos ismingizni kiriting','ru': 'Пожалуйста, введите имя','en': 'Please enter your name'});

  // ── Default kategoriya nomlari ───────────────────────────────────────
  String get katOziqOvqat => _t({'uz': 'Oziq-ovqat', 'ru': 'Продукты', 'en': 'Food'});
  String get katKafe => _t({'uz': 'Kafe', 'ru': 'Кафе', 'en': 'Cafe'});
  String get katTransport => _t({'uz': 'Transport', 'ru': 'Транспорт', 'en': 'Transport'});
  String get katSalomatlik => _t({'uz': 'Salomatlik', 'ru': 'Здоровье', 'en': 'Health'});
  String get katKiyim => _t({'uz': 'Kiyim', 'ru': 'Одежда', 'en': 'Clothing'});
  String get katOila => _t({'uz': 'Oila', 'ru': 'Семья', 'en': 'Family'});
  String get katMaosh => _t({'uz': 'Maosh', 'ru': 'Зарплата', 'en': 'Salary'});
  String get katOylik => _t({'uz': 'Oylik', 'ru': 'Зарплата', 'en': 'Salary'});
  String get katAvans => _t({'uz': 'Avans', 'ru': 'Аванс', 'en': 'Advance'});
  String get katBiznes => _t({'uz': 'Biznes', 'ru': 'Бизнес', 'en': 'Business'});
  String get katSovga => _t({'uz': "Sovg'a", 'ru': 'Подарок', 'en': 'Gift'});
  String get katFreelance => _t({'uz': 'Freelance', 'ru': 'Фриланс', 'en': 'Freelance'});

  // ── Default hisob va maqsad nomlari ─────────────────────────────────
  String get hisobKarta    => _t({'uz': 'Karta',         'ru': 'Карта',         'en': 'Card'});
  String get hisobNaqdPul  => _t({'uz': 'Naqd pul',     'ru': 'Наличные',      'en': 'Cash'});
  String get maqsadOrzular => _t({'uz': 'Mening orzularim', 'ru': 'Мои мечты', 'en': 'My Dreams'});

  String defaultHisobNom(String key) {
    switch (key) {
      case 'karta':     case 'Karta':           return hisobKarta;
      case 'naqd_pul':  case 'Naqd pul':        return hisobNaqdPul;
      case 'orzular':   case 'Mening orzularim': return maqsadOrzular;
      default: return key;
    }
  }

  // ── Kategoriya icon guruh nomlari ────────────────────────────────────
  String ikonGuruh(String key) {
    switch (key) {
      case 'umumiy':     return _t({'uz': 'Umumiy',     'ru': 'Общие',     'en': 'General'});
      case 'moliya':     return _t({'uz': 'Moliya',     'ru': 'Финансы',   'en': 'Finance'});
      case 'oziq_ovqat': return _t({'uz': 'Oziq-ovqat', 'ru': 'Еда',       'en': 'Food'});
      case 'transport':  return _t({'uz': 'Transport',  'ru': 'Транспорт', 'en': 'Transport'});
      case 'salomatlik': return _t({'uz': 'Salomatlik', 'ru': 'Здоровье',  'en': 'Health'});
      case 'talim':      return _t({'uz': "Ta'lim",     'ru': 'Учёба',     'en': 'Education'});
      default: return key;
    }
  }

  // ── Mavzu nomlari ────────────────────────────────────────────────────
  String mavzuNom(String key) {
    switch (key) {
      case 'tungi_qora':     return _t({'uz': 'Tungi qora',     'ru': 'Ночной чёрный', 'en': 'Midnight'});
      case 'zangori_tun':    return _t({'uz': 'Zangori tun',    'ru': 'Синяя ночь',    'en': 'Blue Night'});
      case 'qora_dengiz':    return _t({'uz': 'Qora dengiz',    'ru': 'Чёрное море',   'en': 'Dark Ocean'});
      case 'qorongu_yashil': return _t({'uz': "Qorong'u yashil",'ru': 'Тёмно-зелёный','en': 'Dark Green'});
      case 'jimjit_tog':     return _t({'uz': "Jimjit tog'",    'ru': 'Тихая гора',    'en': 'Silent Peak'});
      case 'binafsha_tun':   return _t({'uz': 'Binafsha tun',   'ru': 'Фиолетовая ночь','en': 'Purple Night'});
      case 'bordo':          return _t({'uz': 'Bordo',          'ru': 'Бордо',         'en': 'Bordeaux'});
      case 'shokolad':       return _t({'uz': 'Shokolad',       'ru': 'Шоколад',       'en': 'Chocolate'});
      case 'marjonsiz':      return _t({'uz': 'Marjonsiz',      'ru': 'Без кораллов',  'en': 'Coralless'});
      case 'kok_qovoq':      return _t({'uz': "Ko'k-qovoq",    'ru': 'Сине-тыквенный','en': 'Teal'});
      case 'kumush_tun':     return _t({'uz': 'Kumush tun',     'ru': 'Серебряная ночь','en': 'Silver Night'});
      case 'granit':         return _t({'uz': 'Granit',         'ru': 'Гранит',        'en': 'Granite'});
      case 'qongir_tog':     return _t({'uz': "Qo'ng'ir tog'",  'ru': 'Коричневая гора','en': 'Brown Peak'});
      case 'toq_moviy':      return _t({'uz': "To'q moviy",     'ru': 'Тёмно-синий',   'en': 'Deep Blue'});
      case 'zaytun_tun':     return _t({'uz': 'Zaytun tun',     'ru': 'Оливковая ночь','en': 'Olive Night'});
      case 'temir':          return _t({'uz': 'Temir',          'ru': 'Железо',        'en': 'Iron'});
      case 'indigo':         return _t({'uz': 'Indigo',         'ru': 'Индиго',        'en': 'Indigo'});
      case 'toq_qongir':     return _t({'uz': "To'q qo'ng'ir",  'ru': 'Тёмно-коричневый','en': 'Dark Brown'});
      case 'toq_zangori':    return _t({'uz': "To'q zangori",   'ru': 'Тёмно-синий 2', 'en': 'Navy'});
      case 'shinam_qora':    return _t({'uz': 'Shinam qora',    'ru': 'Уютный чёрный', 'en': 'Cozy Black'});
      // PRO gradient mavzular
      case 'grad_kosmos':    return _t({'uz': 'Kosmos',         'ru': 'Космос',        'en': 'Cosmos'});
      case 'grad_shafaq':    return _t({'uz': 'Shafaq',         'ru': 'Закат',         'en': 'Sunset'});
      case 'grad_okean':     return _t({'uz': 'Okean tubi',     'ru': 'Глубина океана','en': 'Deep Ocean'});
      case 'grad_aurora':    return _t({'uz': 'Aurora',         'ru': 'Аврора',        'en': 'Aurora'});
      case 'grad_lava':      return _t({'uz': 'Lava',           'ru': 'Лава',          'en': 'Lava'});
      case 'grad_tunola':    return _t({'uz': "Tun olovi",      'ru': 'Ночной огонь',  'en': 'Night Fire'});
      case 'grad_binafsha':  return _t({'uz': 'Binafsha tush',  'ru': 'Фиолетовый сон','en': 'Violet Dream'});
      case 'grad_izumrud':   return _t({'uz': 'Izumrud',        'ru': 'Изумруд',       'en': 'Emerald'});
      default: return key;
    }
  }

  String defaultKatNom(String key) {
    switch (key) {
      case 'oziq_ovqat': case 'Oziq-ovqat': return katOziqOvqat;
      case 'kafe':        case 'Kafe':       return katKafe;
      case 'transport':   case 'Transport':  return katTransport;
      case 'salomatlik':  case 'Salomatlik': return katSalomatlik;
      case 'kiyim':       case 'Kiyim':      return katKiyim;
      case 'oila':        case 'Oila':       return katOila;
      case 'maosh':       case 'Maosh':      return katMaosh;
      case 'oylik':       case 'Oylik':      return katOylik;
      case 'avans':       case 'Avans':      return katAvans;
      case 'biznes':      case 'Biznes':     return katBiznes;
      case 'sovga':       case "Sovg'a":     return katSovga;
      case 'freelance':   case 'Freelance':  return katFreelance;
      default: return key;
    }
  }

  // ── Hafta kunlari (1=Dushanba ... 7=Yakshanba) ──────────────────────
  List<String> get haftaKunlari => {
        'ru': ['','Понедельник','Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'],
        'en': ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
      }[lang] ?? ['','Dushanba','Seshanba','Chorshanba','Payshanba','Juma','Shanba','Yakshanba'];

  // ── Oy nomlari (qisqa) ───────────────────────────────────────────────
  List<String> get oylarQisqa => {
        'ru': ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'],
        'en': ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
      }[lang] ?? ['Yan','Fev','Mar','Apr','May','Iyun','Iyul','Avg','Sen','Okt','Noy','Dek'];

  // ── Oy nomlari (to'liq) ──────────────────────────────────────────────
  List<String> get oylarToliq => {
        'ru': ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'],
        'en': ['January','February','March','April','May','June','July','August','September','October','November','December'],
      }[lang] ?? ['Yanvar','Fevral','Mart','Aprel','May','Iyun','Iyul','Avgust','Sentabr','Oktabr','Noyabr','Dekabr'];
}

// ── Delegate ──────────────────────────────────────────────────────────────────
class AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const AppL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['uz', 'ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppL10n> load(Locale locale) async => AppL10n(locale.languageCode);

  @override
  bool shouldReload(_) => false;
}
