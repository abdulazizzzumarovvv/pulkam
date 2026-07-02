import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ── Qo'llab-quvvatlanadigan tillar ───────────────────────────────────────────
const kSupportedLocales = [
  Locale('uz'),
  Locale('ru'),
  Locale('en'),
  Locale('zh'),
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
        'zh': '小钱',
      });

  // ── Salomlashish ────────────────────────────────────────────────────────
  String get hayirliTun => _t({
        'uz': 'Hayirli tun',
        'ru': 'Доброй ночи',
        'en': 'Good night',
        'zh': '晚安',
      });
  String get hayirliTong => _t({
        'uz': 'Hayirli tong',
        'ru': 'Доброе утро',
        'en': 'Good morning',
        'zh': '早上好',
      });
  String get hayirliKun => _t({
        'uz': 'Hayirli kun',
        'ru': 'Добрый день',
        'en': 'Good afternoon',
        'zh': '下午好',
      });
  String get hayirliKech => _t({
        'uz': 'Hayirli kech',
        'ru': 'Добрый вечер',
        'en': 'Good evening',
        'zh': '傍晚好',
      });

  // ── Profil ──────────────────────────────────────────────────────────────
  String get profil          => _t({'uz': 'Profil',             'ru': 'Профиль',          'en': 'Profile',        'zh': '个人资料'});
  String get ismKiriting     => _t({'uz': 'Ismingizni kiriting','ru': 'Введите имя',       'en': 'Enter first name','zh': '请输入名字'});
  String get familiyaKiriting=> _t({'uz': 'Familiyangizni kiriting','ru': 'Введите фамилию','en': 'Enter last name','zh': '请输入姓氏'});
  String get ismXato         => _t({'uz': 'Iltimos ismingizni kiriting','ru': 'Пожалуйста, введите имя','en': 'Please enter your name','zh': '请输入您的姓名'});

  // ── Umumiy ──────────────────────────────────────────────────────────────
  String get umumiyBalans => _t({
        'uz': 'Umumiy balans',
        'ru': 'Общий баланс',
        'en': 'Total balance',
        'zh': '总余额',
      });
  String get saqlash => _t({
        'uz': 'Saqlash',
        'ru': 'Сохранить',
        'en': 'Save',
        'zh': '保存',
      });
  String get bekorQilish => _t({
        'uz': 'Bekor qilish',
        'ru': 'Отмена',
        'en': 'Cancel',
        'zh': '取消',
      });
  String get ochirish => _t({
        'uz': "O'chirish",
        'ru': 'Удалить',
        'en': 'Delete',
        'zh': '删除',
      });
  String get tahrirlash => _t({
        'uz': 'Tahrirlash',
        'ru': 'Изменить',
        'en': 'Edit',
        'zh': '编辑',
      });
  String get tasdiqOchirish => _t({
        'uz': "Rostan ham o'chirmoqchimisiz?",
        'ru': 'Вы уверены, что хотите удалить?',
        'en': 'Are you sure you want to delete?',
        'zh': '确定要删除吗？',
      });
  String get ha => _t({
        'uz': 'Ha',
        'ru': 'Да',
        'en': 'Yes',
        'zh': '是',
      });
  String get yoq => _t({
        'uz': "Yo'q",
        'ru': 'Нет',
        'en': 'No',
        'zh': '否',
      });
  String get qidirish => _t({
        'uz': 'Qidirish',
        'ru': 'Поиск',
        'en': 'Search',
        'zh': '搜索',
      });
  String get hechNarsa => _t({
        'uz': 'Hech narsa topilmadi',
        'ru': 'Ничего не найдено',
        'en': 'Nothing found',
        'zh': '未找到',
      });

  // ── Amallar ─────────────────────────────────────────────────────────────
  String get amallar => _t({
        'uz': 'Amallar',
        'ru': 'Операции',
        'en': 'Transactions',
        'zh': '交易',
      });
  String get barchaAmallar => _t({
        'uz': 'Barcha amallar',
        'ru': 'Все операции',
        'en': 'All transactions',
        'zh': '所有交易',
      });
  String get amalsizOy => _t({
        'uz': "Bu oyda amallar yo'q",
        'ru': 'В этом месяце нет операций',
        'en': 'No transactions this month',
        'zh': '本月无交易',
      });
  String get haliAmallarYoq => _t({
        'uz': "Hali amallar mavjud emas",
        'ru': 'Операций пока нет',
        'en': 'No transactions yet',
        'zh': '暂无交易',
      });
  String get kirim => _t({
        'uz': 'Kirim',
        'ru': 'Доход',
        'en': 'Income',
        'zh': '收入',
      });
  String get chiqim => _t({
        'uz': 'Chiqim',
        'ru': 'Расход',
        'en': 'Expense',
        'zh': '支出',
      });

  // ── Hisoblar ────────────────────────────────────────────────────────────
  String get hisoblar => _t({
        'uz': 'Hisoblar',
        'ru': 'Счета',
        'en': 'Accounts',
        'zh': '账户',
      });
  String get maqsadlar => _t({
        'uz': 'Maqsadlar',
        'ru': 'Цели',
        'en': 'Goals',
        'zh': '目标',
      });
  String get qarzlar => _t({
        'uz': 'Qarzlar',
        'ru': 'Долги',
        'en': 'Debts',
        'zh': '债务',
      });
  String get hisobYoq => _t({
        'uz': "Hisob mavjud emas",
        'ru': 'Нет счетов',
        'en': 'No accounts',
        'zh': '没有账户',
      });
  String get maqsadYoq => _t({
        'uz': "Maqsad mavjud emas",
        'ru': 'Нет целей',
        'en': 'No goals',
        'zh': '没有目标',
      });
  String get qarzYoq => _t({
        'uz': "Qarz mavjud emas",
        'ru': 'Нет долгов',
        'en': 'No debts',
        'zh': '没有债务',
      });
  String get yangiHisob => _t({
        'uz': 'Yangi Hisob',
        'ru': 'Новый счёт',
        'en': 'New Account',
        'zh': '新账户',
      });
  String get hisobniTahrirlash => _t({
        'uz': 'Hisobni tahrirlash',
        'ru': 'Изменить счёт',
        'en': 'Edit Account',
        'zh': '编辑账户',
      });
  String get yangiMaqsad => _t({
        'uz': 'Yangi Maqsad',
        'ru': 'Новая цель',
        'en': 'New Goal',
        'zh': '新目标',
      });
  String get maqsadniTahrirlash => _t({
        'uz': 'Maqsadni tahrirlash',
        'ru': 'Изменить цель',
        'en': 'Edit Goal',
        'zh': '编辑目标',
      });
  String get yangiQarz => _t({
        'uz': 'Yangi Qarz',
        'ru': 'Новый долг',
        'en': 'New Debt',
        'zh': '新债务',
      });
  String get maqsadBajarildi => _t({
        'uz': 'MAQSAD BAJARILDI',
        'ru': 'ЦЕЛЬ ДОСТИГНУТА',
        'en': 'GOAL ACHIEVED',
        'zh': '目标达成',
      });
  String get maqsadgaOlga => _t({
        'uz': "Maqsad sari Olg'a!!!",
        'ru': 'Вперёд к цели!!!',
        'en': 'Onwards to the goal!!!',
        'zh': '向目标前进!!!',
      });
  String get taslimBolma => _t({
        'uz': "Maqsadga erishmadinz, taslim bo'lmang!",
        'ru': 'Цель не достигнута, не сдавайтесь!',
        'en': "Goal not reached, don't give up!",
        'zh': '未达目标，不要放弃！',
      });
  String get bajarilganMaqsadlar => _t({
        'uz': 'Bajarilgan maqsadlar',
        'ru': 'Достигнутые цели',
        'en': 'Achieved goals',
        'zh': '已达成目标',
      });
  String get bajarilganMaqsadYoq => _t({
        'uz': "Hech qanday bajarilgan maqsadlar mavjud emas",
        'ru': 'Нет достигнутых целей',
        'en': 'No achieved goals yet',
        'zh': '暂无已达成目标',
      });
  String get yopilganQarzlar => _t({
        'uz': 'Yopilgan qarzlar',
        'ru': 'Закрытые долги',
        'en': 'Closed debts',
        'zh': '已关闭债务',
      });
  String get yopilganQarzYoq => _t({
        'uz': "Hech qanday yopilgan qarz mavjud emas",
        'ru': 'Нет закрытых долгов',
        'en': 'No closed debts yet',
        'zh': '暂无已关闭债务',
      });
  String get qarzsizHayot => _t({
        'uz': "Qarzsiz hayot — yengil hayot!",
        'ru': 'Жизнь без долгов — лёгкая жизнь!',
        'en': 'Debt-free life is a light life!',
        'zh': '无债一身轻！',
      });
  String get umumiyBalansaTasir => _t({
        'uz': "Umumiy balansingizga ta'sir qiladi",
        'ru': 'Это повлияет на ваш общий баланс',
        'en': 'This will affect your total balance',
        'zh': '这将影响您的总余额',
      });
  String get boshqaHisobYoq => _t({
        'uz': "O'tkazish uchun boshqa hisob mavjud emas",
        'ru': 'Нет другого счёта для перевода',
        'en': 'No other account to transfer to',
        'zh': '没有其他账户可转账',
      });
  String get boshqaMaqsadYoq => _t({
        'uz': "O'tkazish uchun boshqa maqsad mavjud emas",
        'ru': 'Нет другой цели для перевода',
        'en': 'No other goal to transfer to',
        'zh': '没有其他目标可转账',
      });
  String get qaytarildi => _t({
        'uz': 'QAYTARILDI',
        'ru': 'ВОЗВРАТ',
        'en': 'RETURNED',
        'zh': '已归还',
      });
  String get tolangan => _t({
        'uz': "TO'LANGAN",
        'ru': 'ОПЛАЧЕНО',
        'en': 'PAID',
        'zh': '已付',
      });
  String get hisobNomi => _t({
        'uz': 'Hisob nomi',
        'ru': 'Название счёта',
        'en': 'Account name',
        'zh': '账户名称',
      });
  String get maqsadNomi => _t({
        'uz': 'Maqsad nomi',
        'ru': 'Название цели',
        'en': 'Goal name',
        'zh': '目标名称',
      });
  String get boshlangichBalans => _t({
        'uz': "Boshlang'ich balans",
        'ru': 'Начальный баланс',
        'en': 'Initial balance',
        'zh': '初始余额',
      });
  String get maqsadSumma => _t({
        'uz': 'Maqsad summasi',
        'ru': 'Целевая сумма',
        'en': 'Target amount',
        'zh': '目标金额',
      });
  String get rang => _t({
        'uz': 'Rang',
        'ru': 'Цвет',
        'en': 'Color',
        'zh': '颜色',
      });
  String get icon => _t({
        'uz': 'Icon',
        'ru': 'Иконка',
        'en': 'Icon',
        'zh': '图标',
      });
  String get iconTanlang => _t({
        'uz': 'Icon tanlang',
        'ru': 'Выберите иконку',
        'en': 'Choose icon',
        'zh': '选择图标',
      });
  String get rangTanlang => _t({
        'uz': 'Rang tanlang',
        'ru': 'Выберите цвет',
        'en': 'Choose color',
        'zh': '选择颜色',
      });
  String get otkazish => _t({
        'uz': "O'tkazish",
        'ru': 'Перевод',
        'en': 'Transfer',
        'zh': '转账',
      });
  String get toplash => _t({
        'uz': "Qo'shish",
        'ru': 'Пополнить',
        'en': 'Add funds',
        'zh': '充值',
      });
  String get tolovQoshish => _t({
        'uz': "To'lov qo'shish",
        'ru': 'Добавить платёж',
        'en': 'Add payment',
        'zh': '添加付款',
      });
  String get asosiySumma => _t({
        'uz': 'Asosiy summa',
        'ru': 'Основная сумма',
        'en': 'Principal amount',
        'zh': '本金',
      });
  String get tolangan2 => _t({
        'uz': "To'langan",
        'ru': 'Оплачено',
        'en': 'Paid',
        'zh': '已付',
      });
  String get qolgan => _t({
        'uz': 'Qolgan',
        'ru': 'Осталось',
        'en': 'Remaining',
        'zh': '剩余',
      });
  String get berdim => _t({
        'uz': 'Berdim',
        'ru': 'Дал',
        'en': 'Lent',
        'zh': '借出',
      });
  String get oldim => _t({
        'uz': 'Oldim',
        'ru': 'Взял',
        'en': 'Borrowed',
        'zh': '借入',
      });
  String get kimdan => _t({
        'uz': 'Kimdan / Kimga',
        'ru': 'Кому / От кого',
        'en': 'To / From whom',
        'zh': '借给/向谁',
      });

  // ── Kategoriya ───────────────────────────────────────────────────────────
  String get statistika => _t({
        'uz': 'Statistika',
        'ru': 'Статистика',
        'en': 'Statistics',
        'zh': '统计',
      });
  String get malumotYoq => _t({
        'uz': "Bu oyda ma'lumot yo'q",
        'ru': 'Нет данных за этот месяц',
        'en': 'No data for this month',
        'zh': '本月无数据',
      });
  String get kunlikOrtacha => _t({
        'uz': "Kunlik o'rtacha",
        'ru': 'Среднее в день',
        'en': 'Daily average',
        'zh': '日均',
      });
  String get oylikChiqim => _t({
        'uz': 'Oylik chiqim',
        'ru': 'Расход за месяц',
        'en': 'Monthly expense',
        'zh': '月支出',
      });
  String get oylikKirim => _t({
        'uz': 'Oylik kirim',
        'ru': 'Доход за месяц',
        'en': 'Monthly income',
        'zh': '月收入',
      });
  String get yangiKategoriya => _t({
        'uz': 'Yangi Kategoriya',
        'ru': 'Новая категория',
        'en': 'New Category',
        'zh': '新类别',
      });
  String get kategoriyaniTahrirlash => _t({
        'uz': 'Kategoriyani tahrirlash',
        'ru': 'Изменить категорию',
        'en': 'Edit Category',
        'zh': '编辑类别',
      });
  String get kategoriyaNomi => _t({
        'uz': 'Kategoriya nomi',
        'ru': 'Название категории',
        'en': 'Category name',
        'zh': '类别名称',
      });

  // ── Sozlamalar ───────────────────────────────────────────────────────────
  String get sozlamalar => _t({
        'uz': 'Sozlamalar',
        'ru': 'Настройки',
        'en': 'Settings',
        'zh': '设置',
      });
  String get asosiyVaIuta => _t({
        'uz': 'Asosiy valyuta',
        'ru': 'Основная валюта',
        'en': 'Main currency',
        'zh': '主货币',
      });
  String get formatlash => _t({
        'uz': 'Formatlash',
        'ru': 'Формат чисел',
        'en': 'Number format',
        'zh': '数字格式',
      });
  String get mavzular => _t({
        'uz': 'Mavzular',
        'ru': 'Темы',
        'en': 'Themes',
        'zh': '主题',
      });
  String get til => _t({
        'uz': 'Til',
        'ru': 'Язык',
        'en': 'Language',
        'zh': '语言',
      });
  String get xavfsizlik => _t({
        'uz': 'Xavfsizlik va bildirishnomalar',
        'ru': 'Безопасность и уведомления',
        'en': 'Security & notifications',
        'zh': '安全与通知',
      });
  String get pinKod => _t({
        'uz': 'PIN kod',
        'ru': 'PIN-код',
        'en': 'PIN code',
        'zh': 'PIN码',
      });
  String get bildirishnomalar => _t({
        'uz': 'Bildirishnomalar',
        'ru': 'Уведомления',
        'en': 'Notifications',
        'zh': '通知',
      });
  String get boshqa => _t({
        'uz': 'Boshqa',
        'ru': 'Прочее',
        'en': 'Other',
        'zh': '其他',
      });
  String get bizHaqimizda => _t({
        'uz': 'Biz haqimizda',
        'ru': 'О нас',
        'en': 'About us',
        'zh': '关于我们',
      });
  String get yoriqnoma => _t({
        'uz': "Ilova yo'riqnomasi",
        'ru': 'Руководство пользователя',
        'en': 'User guide',
        'zh': '使用指南',
      });
  String get mavzu => _t({
        'uz': 'Mavzu',
        'ru': 'Тема',
        'en': 'Theme',
        'zh': '主题',
      });
  String get raqamFormati => _t({
        'uz': 'Raqam formati',
        'ru': 'Формат чисел',
        'en': 'Number format',
        'zh': '数字格式',
      });
  String get valyutaniTanlang => _t({
        'uz': 'Valyutani tanlang',
        'ru': 'Выберите валюту',
        'en': 'Choose currency',
        'zh': '选择货币',
      });
  String get nomYokiKod => _t({
        'uz': "Nom yoki kod bo'yicha qidiring",
        'ru': 'Поиск по названию или коду',
        'en': 'Search by name or code',
        'zh': '按名称或代码搜索',
      });
  String get mashhurValyutalar => _t({
        'uz': 'Mashhur valyutalar',
        'ru': 'Популярные валюты',
        'en': 'Popular currencies',
        'zh': '热门货币',
      });
  String get barchaValyutalar => _t({
        'uz': 'Barcha valyutalar',
        'ru': 'Все валюты',
        'en': 'All currencies',
        'zh': '所有货币',
      });
  String get tilniTanlang => _t({
        'uz': 'Tilni tanlang',
        'ru': 'Выберите язык',
        'en': 'Choose language',
        'zh': '选择语言',
      });
  String get defaultTil => _t({
        'uz': 'Standart',
        'ru': 'По умолчанию',
        'en': 'Default',
        'zh': '默认',
      });
  String get eslatmalar => _t({
        'uz': 'Eslatmalar',
        'ru': 'Напоминания',
        'en': 'Reminders',
        'zh': '提醒',
      });
  String get pinKodYarating => _t({
        'uz': 'PIN kod yarating',
        'ru': 'Создайте PIN-код',
        'en': 'Create PIN code',
        'zh': '创建PIN码',
      });
  String get pinKodKiriting => _t({
        'uz': 'PIN kodni kiriting',
        'ru': 'Введите PIN-код',
        'en': 'Enter PIN code',
        'zh': '输入PIN码',
      });

  // ── AI Analiz ────────────────────────────────────────────────────────────
  String get ortachaXarajat => _t({
        'uz': "O'rtacha xarajat",
        'ru': 'Средние расходы',
        'en': 'Average expenses',
        'zh': '平均支出',
      });
  String get birKunda => _t({
        'uz': 'Bir kunda',
        'ru': 'В день',
        'en': 'Per day',
        'zh': '每天',
      });
  String get birHaftada => _t({
        'uz': 'Bir haftada',
        'ru': 'В неделю',
        'en': 'Per week',
        'zh': '每周',
      });

  // ── Calculator sheets ─────────────────────────────────────────────────
  String get summaKiriting => _t({
        'uz': 'Summa kiriting',
        'ru': 'Введите сумму',
        'en': 'Enter amount',
        'zh': '输入金额',
      });
  String get izoh => _t({
        'uz': 'Izoh (ixtiyoriy)',
        'ru': 'Комментарий (необязательно)',
        'en': 'Note (optional)',
        'zh': '备注（可选）',
      });
  String get kategoriya => _t({
        'uz': 'Kategoriya',
        'ru': 'Категория',
        'en': 'Category',
        'zh': '类别',
      });
  String get hisob => _t({
        'uz': 'Hisob',
        'ru': 'Счёт',
        'en': 'Account',
        'zh': '账户',
      });

  // ── Default kategoriya nomlari ───────────────────────────────────────
  String get katOziqOvqat => _t({'uz': 'Oziq-ovqat', 'ru': 'Продукты', 'en': 'Food', 'zh': '食品'});
  String get katKafe => _t({'uz': 'Kafe', 'ru': 'Кафе', 'en': 'Cafe', 'zh': '咖啡厅'});
  String get katTransport => _t({'uz': 'Transport', 'ru': 'Транспорт', 'en': 'Transport', 'zh': '交通'});
  String get katSalomatlik => _t({'uz': 'Salomatlik', 'ru': 'Здоровье', 'en': 'Health', 'zh': '健康'});
  String get katKiyim => _t({'uz': 'Kiyim', 'ru': 'Одежда', 'en': 'Clothing', 'zh': '服装'});
  String get katOila => _t({'uz': 'Oila', 'ru': 'Семья', 'en': 'Family', 'zh': '家庭'});
  String get katMaosh => _t({'uz': 'Maosh', 'ru': 'Зарплата', 'en': 'Salary', 'zh': '薪资'});
  String get katBiznes => _t({'uz': 'Biznes', 'ru': 'Бизнес', 'en': 'Business', 'zh': '商业'});
  String get katSovga => _t({'uz': "Sovg'a", 'ru': 'Подарок', 'en': 'Gift', 'zh': '礼物'});
  String get katFreelance => _t({'uz': 'Freelance', 'ru': 'Фриланс', 'en': 'Freelance', 'zh': '自由职业'});

  // ── Default hisob va maqsad nomlari ─────────────────────────────────
  String get hisobKarta    => _t({'uz': 'Karta',         'ru': 'Карта',         'en': 'Card',     'zh': '银行卡'});
  String get hisobNaqdPul  => _t({'uz': 'Naqd pul',     'ru': 'Наличные',      'en': 'Cash',     'zh': '现金'});
  String get maqsadOrzular => _t({'uz': 'Mening orzularim', 'ru': 'Мои мечты', 'en': 'My Dreams','zh': '我的梦想'});

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
      case 'umumiy':     return _t({'uz': 'Umumiy',     'ru': 'Общие',     'en': 'General',  'zh': '通用'});
      case 'moliya':     return _t({'uz': 'Moliya',     'ru': 'Финансы',   'en': 'Finance',  'zh': '金融'});
      case 'oziq_ovqat': return _t({'uz': 'Oziq-ovqat', 'ru': 'Еда',       'en': 'Food',     'zh': '食物'});
      case 'transport':  return _t({'uz': 'Transport',  'ru': 'Транспорт', 'en': 'Transport','zh': '交通'});
      case 'salomatlik': return _t({'uz': 'Salomatlik', 'ru': 'Здоровье',  'en': 'Health',   'zh': '健康'});
      case 'talim':      return _t({'uz': "Ta'lim",     'ru': 'Учёба',     'en': 'Education','zh': '教育'});
      default: return key;
    }
  }

  // ── Mavzu nomlari ────────────────────────────────────────────────────
  String mavzuNom(String key) {
    switch (key) {
      case 'tungi_qora':     return _t({'uz': 'Tungi qora',     'ru': 'Ночной чёрный', 'en': 'Midnight',       'zh': '午夜黑'});
      case 'zangori_tun':    return _t({'uz': 'Zangori tun',    'ru': 'Синяя ночь',    'en': 'Blue Night',     'zh': '蓝夜'});
      case 'qora_dengiz':    return _t({'uz': 'Qora dengiz',    'ru': 'Чёрное море',   'en': 'Dark Ocean',     'zh': '深海'});
      case 'qorongu_yashil': return _t({'uz': "Qorong'u yashil",'ru': 'Тёмно-зелёный','en': 'Dark Green',     'zh': '深绿'});
      case 'jimjit_tog':     return _t({'uz': "Jimjit tog'",    'ru': 'Тихая гора',    'en': 'Silent Peak',    'zh': '静山'});
      case 'binafsha_tun':   return _t({'uz': 'Binafsha tun',   'ru': 'Фиолетовая ночь','en': 'Purple Night',  'zh': '紫夜'});
      case 'bordo':          return _t({'uz': 'Bordo',          'ru': 'Бордо',         'en': 'Bordeaux',       'zh': '波尔多'});
      case 'shokolad':       return _t({'uz': 'Shokolad',       'ru': 'Шоколад',       'en': 'Chocolate',      'zh': '巧克力'});
      case 'marjonsiz':      return _t({'uz': 'Marjonsiz',      'ru': 'Без кораллов',  'en': 'Coralless',      'zh': '无珊瑚'});
      case 'kok_qovoq':      return _t({'uz': "Ko'k-qovoq",    'ru': 'Сине-тыквенный','en': 'Teal',           'zh': '蓝绿'});
      case 'kumush_tun':     return _t({'uz': 'Kumush tun',     'ru': 'Серебряная ночь','en': 'Silver Night',  'zh': '银夜'});
      case 'granit':         return _t({'uz': 'Granit',         'ru': 'Гранит',        'en': 'Granite',        'zh': '花岗岩'});
      case 'qongir_tog':     return _t({'uz': "Qo'ng'ir tog'",  'ru': 'Коричневая гора','en': 'Brown Peak',    'zh': '棕峰'});
      case 'toq_moviy':      return _t({'uz': "To'q moviy",     'ru': 'Тёмно-синий',   'en': 'Deep Blue',      'zh': '深蓝'});
      case 'zaytun_tun':     return _t({'uz': 'Zaytun tun',     'ru': 'Оливковая ночь','en': 'Olive Night',    'zh': '橄榄夜'});
      case 'temir':          return _t({'uz': 'Temir',          'ru': 'Железо',        'en': 'Iron',           'zh': '铁灰'});
      case 'indigo':         return _t({'uz': 'Indigo',         'ru': 'Индиго',        'en': 'Indigo',         'zh': '靛蓝'});
      case 'toq_qongir':     return _t({'uz': "To'q qo'ng'ir",  'ru': 'Тёмно-коричневый','en': 'Dark Brown',  'zh': '深棕'});
      case 'toq_zangori':    return _t({'uz': "To'q zangori",   'ru': 'Тёмно-синий 2', 'en': 'Navy',           'zh': '海军蓝'});
      case 'shinam_qora':    return _t({'uz': 'Shinam qora',    'ru': 'Уютный чёрный', 'en': 'Cozy Black',     'zh': '舒适黑'});
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
        'zh': ['','星期一','星期二','星期三','星期四','星期五','星期六','星期日'],
      }[lang] ?? ['','Dushanba','Seshanba','Chorshanba','Payshanba','Juma','Shanba','Yakshanba'];

  // ── Oy nomlari (qisqa) ───────────────────────────────────────────────
  List<String> get oylarQisqa => {
        'ru': ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'],
        'en': ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        'zh': ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
      }[lang] ?? ['Yan','Fev','Mar','Apr','May','Iyun','Iyul','Avg','Sen','Okt','Noy','Dek'];

  // ── Oy nomlari (to'liq) ──────────────────────────────────────────────
  List<String> get oylarToliq => {
        'ru': ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'],
        'en': ['January','February','March','April','May','June','July','August','September','October','November','December'],
        'zh': ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],
      }[lang] ?? ['Yanvar','Fevral','Mart','Aprel','May','Iyun','Iyul','Avgust','Sentabr','Oktabr','Noyabr','Dekabr'];
}

// ── Delegate ──────────────────────────────────────────────────────────────────
class AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const AppL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['uz', 'ru', 'en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppL10n> load(Locale locale) async => AppL10n(locale.languageCode);

  @override
  bool shouldReload(_) => false;
}
