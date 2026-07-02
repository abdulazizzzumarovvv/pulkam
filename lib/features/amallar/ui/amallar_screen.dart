import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/ui/malumotlar_screen.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import '../logic/amal_cubit.dart';
import '../data/amal_model.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/kirim_chiqim_sheet.dart';
import 'dart:ui';
import 'package:pulkam/features/amallar/widgets/profile_dialog.dart';
import 'package:pulkam/features/profile/logic/profile_cubit.dart';
import 'dart:io';
import 'package:pulkam/l10n.dart';

const _kSubtext = Color(0xFF8A88A0);



String _salomlashuv(AppL10n l10n) {
  final hour = DateTime.now().hour;
  if (hour < 6) return l10n.hayirliTun;
  if (hour < 12) return l10n.hayirliTong;
  if (hour < 18) return l10n.hayirliKun;
  return l10n.hayirliKech;
}

// ── Asosiy ekran ─────────────────────────────────────────────────────
class AmallarScreen extends StatelessWidget {
  const AmallarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => showProfileDialog(context),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final avatarPath = state.avatarPath;
                return CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  backgroundImage: avatarPath != null
                      ? FileImage(File(avatarPath))
                      : null,
                  child: avatarPath == null
                      ? const Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                );
              },
            ),
          ),
        ),
        title: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final name = state.profile?.fullName ?? state.name;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_salomlashuv(l10n)},',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 6),
                if (name != null && name.isNotEmpty)
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MalumotlarScreen()),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final hisobSum = context.watch<HisobCubit>().state.hisoblar.fold(
            0.0,
            (s, h) => s + (double.tryParse(h.balance) ?? 0),
          );
          // Bajarilgan maqsadlar umumiy balansga ta'sir qilmaydi
          final maqsadSum = context
              .watch<MaqsadCubit>()
              .state
              .maqsadlar
              .where((m) => !m.bajarilgan)
              .fold(0.0, (s, m) => s + (double.tryParse(m.balance) ?? 0));
          final totalSum = hisobSum + maqsadSum;
          final fmtKod = context.watch<SozlamalarCubit>().state.formatKod;
          final commaDecimal = fmtKod == 'dot_comma' || fmtKod == 'space_comma';
          final decSep = commaDecimal ? ',' : '.';
          final formatted = appFmt(totalSum, fmtKod);
          final sepIdx = formatted.lastIndexOf(decSep);
          final parts = sepIdx >= 0
              ? [formatted.substring(0, sepIdx), formatted.substring(sepIdx + 1)]
              : [formatted, '00'];

          final allAmallar = context.watch<AmalCubit>().state.amallar;
          final today = DateTime.now();
          bool bugun(int ts) {
            final dt = DateTime.fromMillisecondsSinceEpoch(ts);
            return dt.year == today.year &&
                dt.month == today.month &&
                dt.day == today.day;
          }

          final bugunChiqim = allAmallar
              .where((a) => !a.isKirim && bugun(a.timestamp))
              .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));
          final bugunKirim = allAmallar
              .where((a) => a.isKirim && bugun(a.timestamp))
              .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balans
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(Colors.white.withValues(alpha: 0.07), kBg),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chap tomondagi balans qismi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.umumiyBalans,
                              style: TextStyle(color: _kSubtext, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _UzsBadge(dark: true),
                                  const SizedBox(width: 8),
                                  Text(
                                    parts[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 4,
                                      left: 3,
                                    ),
                                    child: Text(
                                      '$decSep${parts[1]}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // O'ng tomondagi SHISHA (Glass) effektli "+" tugmasi
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KirimChiqimSheet(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(30),
                        child: ClipOval(
                          // Shisha xiralashtirish effekti dumaloq chegaradan chiqib ketmasligi uchun
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ), // Orqa fonni xiralashtirish (blur)
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Yarim shaffof oq rang shisha effektini beradi
                                color: Colors.white.withValues(alpha: 0.07),
                                border: Border.all(
                                  // Shisha chetidagi mayin yorug'lik chizig'i
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Oq bottom-sheet karta
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          children: [
                            // 1. CHAP TARAF: Haqiqiy menyu (yoki barcha amallar) tugmasi
                            // Uni o'ng tarafdagi Pill bilan bir xil kenglikda (SizedBox yordamida) cheklaymiz
                            SizedBox(
                              width:
                                  52, // O'ngdagi Pill tugmasining taxminiy kengligi bilan muvozanatlash
                              child: Align(
                                alignment: Alignment
                                    .centerLeft, // Chap tomonga tekislaydi
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<AmalCubit>(),
                                        child: const _BarchaAmallarPage(),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      CupertinoIcons.line_horizontal_3,
                                      color: Colors.grey[700],
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 2. O'RTA: Mukammal markazlashgan matn
                            Expanded(
                              child: Text(
                                l10n.amallar,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // 3. O'NG TARAF: Mikrofon — Pro versiya kulrang uslubida
                            Container(
                              width:
                                  52, // Chap taraf bilan bir xil muvozanat kengligi
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(
                                Icons.mic_rounded,
                                color: Colors.grey.withValues(alpha: 0.4),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flat list
                      Expanded(
                        child: BlocBuilder<AmalCubit, AmalState>(
                          builder: (context, state) {
                            final amallar = state.amallar;
                            if (amallar.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      l10n.haliAmallarYoq,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
                              itemCount: amallar.length,
                              separatorBuilder: (ctx, i) => Divider(
                                height: 1,
                                indent: 72,
                                color: Colors.grey[100],
                              ),
                              itemBuilder: (_, i) => _AmalRow(amal: amallar[i]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Barcha amallar (oy carousel + expandable kun) ─────────────────────
class _BarchaAmallarPage extends StatefulWidget {
  const _BarchaAmallarPage();

  @override
  State<_BarchaAmallarPage> createState() => _BarchaAmallarPageState();
}

class _BarchaAmallarPageState extends State<_BarchaAmallarPage> {
  late PageController _monthController;
  late PageController _contentController;
  late int _currentPage;
  bool _syncing = false;

  static const int _base = 24000;

  DateTime _pageToMonth(int page) {
    final total = page - _base;
    return DateTime(2000 + total ~/ 12, total % 12 + 1);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentPage = _base + (now.year - 2000) * 12 + (now.month - 1);
    _monthController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.33,
    );
    _contentController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onMonthChanged(int page) {
    if (_syncing) return;
    _syncing = true;
    setState(() => _currentPage = page);
    if (_contentController.hasClients) _contentController.jumpToPage(page);
    Future.microtask(() => _syncing = false);
  }

  void _onContentChanged(int page) {
    if (_syncing) return;
    _syncing = true;
    setState(() => _currentPage = page);
    if (_monthController.hasClients) _monthController.jumpToPage(page);
    Future.microtask(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.barchaAmallar,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Oy carousel
          SizedBox(
            height: 52,
            child: PageView.builder(
              controller: _monthController,
              onPageChanged: _onMonthChanged,
              itemBuilder: (_, page) {
                final m = _pageToMonth(page);
                final isSelected = page == _currentPage;
                return GestureDetector(
                  onTap: () {
                    _monthController.animateToPage(
                      page,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Center(
                    child: Text(
                      context.l10n.oylarToliq[m.month - 1],
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.black87 : Colors.grey[400],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),

          // Kontent — swipe bilan oy o'zgaradi
          Expanded(
            child: BlocBuilder<AmalCubit, AmalState>(
              builder: (context, state) {
                return PageView.builder(
                  controller: _contentController,
                  onPageChanged: _onContentChanged,
                  itemBuilder: (_, page) {
                    final m = _pageToMonth(page);
                    final monthAmallar = state.amallar.where((a) {
                      final dt = DateTime.fromMillisecondsSinceEpoch(
                        a.timestamp,
                      );
                      return dt.year == m.year && dt.month == m.month;
                    }).toList();

                    if (monthAmallar.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.amalsizOy,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final Map<String, List<AmalModel>> grouped = {};
                    for (final a in monthAmallar) {
                      final dt = DateTime.fromMillisecondsSinceEpoch(
                        a.timestamp,
                      );
                      final key =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                      grouped.putIfAbsent(key, () => []).add(a);
                    }
                    final sortedKeys = grouped.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 32),
                      itemCount: sortedKeys.length,
                      itemBuilder: (_, i) {
                        final dt = DateTime.parse(sortedKeys[i]);
                        return _ExpandableDay(
                          date: dt,
                          amallar: grouped[sortedKeys[i]]!,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableDay extends StatefulWidget {
  final DateTime date;
  final List<AmalModel> amallar;
  const _ExpandableDay({required this.date, required this.amallar});

  @override
  State<_ExpandableDay> createState() => _ExpandableDayState();
}

class _ExpandableDayState extends State<_ExpandableDay> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final kirimTotal = widget.amallar
        .where((a) => a.isKirim)
        .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));
    final chiqimTotal = widget.amallar
        .where((a) => !a.isKirim)
        .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Katta kun raqami
                SizedBox(
                  width: 48,
                  child: Text(
                    widget.date.day.toString(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.haftaKunlari[widget.date.weekday],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${context.l10n.oylarToliq[widget.date.month - 1]} ${widget.date.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (kirimTotal > 0)
                      Text(
                        '+${appFmt(kirimTotal, context.read<SozlamalarCubit>().state.formatKod)}',
                        style: const TextStyle(
                          color: Color(0xFF34C759),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (chiqimTotal > 0)
                      Text(
                        '-${appFmt(chiqimTotal, context.read<SozlamalarCubit>().state.formatKod)}',
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          Divider(height: 1, indent: 20, color: Colors.grey[100]),
          ...widget.amallar.map((a) => _AmalRow(amal: a)),
        ],
        Divider(height: 1, color: Colors.grey[100]),
      ],
    );
  }
}

// ── Amal qatori ──────────────────────────────────────────────────────
class _AmalRow extends StatefulWidget {
  final AmalModel amal;
  const _AmalRow({required this.amal});

  @override
  State<_AmalRow> createState() => _AmalRowState();
}

class _AmalRowState extends State<_AmalRow> {
  bool _revealed = false;

  // Amalni o'chirib, hisob balansini qaytaradi (action reverse)
  void _deleteAndReverse() {
    final amal = widget.amal;
    final amt = double.tryParse(amal.amount) ?? 0;
    final hisobCubit = context.read<HisobCubit>();
    final matches = hisobCubit.state.hisoblar.where(
      (h) => h.name == amal.hisobName,
    );
    if (matches.isNotEmpty) {
      final hisob = matches.first;
      final bal = double.tryParse(hisob.balance) ?? 0;
      // Teskari: kirim bo'lsa ayiriladi, chiqim bo'lsa qaytariladi
      final newBal = amal.isKirim ? bal - amt : bal + amt;
      hisobCubit.updateBalance(hisob, newBal.toStringAsFixed(2));
    }
    context.read<AmalCubit>().deleteAmal(amal);
  }

  @override
  Widget build(BuildContext context) {
    final amal = widget.amal;
    final color = Color(amal.kategoriyaColorValue);
    final icon = IconData(amal.kategoriyaIconCode, fontFamily: 'MaterialIcons');
    final dt = DateTime.fromMillisecondsSinceEpoch(amal.timestamp);
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _revealed = !_revealed),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Kategoriya ikonasi: Background to'liq rangda, icon esa oppoq
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color:
                    color, // 100% fon rangi (alpha shaffofligi olib tashlandi)
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white, // Ikonaning o'zi oppoq bo'ldi
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.l10n.defaultKatNom(amal.kategoriyaName),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
            ),
            // Summa + vaqt (delete ochilganda chapga suriladi)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${amal.isKirim ? '+' : '-'}${appFmt(double.tryParse(amal.amount) ?? 0, context.read<SozlamalarCubit>().state.formatKod)}',
                  style: TextStyle(
                    color: amal.isKirim
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
            // O'ng burchakda qizil delete ikonka (suriladi)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: _revealed
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: GestureDetector(
                        onTap: _deleteAndReverse,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF3B30,
                            ).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFFF3B30),
                            size: 22,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── UZS badge ────────────────────────────────────────────────────────
class _UzsBadge extends StatelessWidget {
  final bool dark;
  const _UzsBadge({this.dark = false});

  @override
  Widget build(BuildContext context) {
    final kod = context.watch<SozlamalarCubit>().state.valyutaKod;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        kod,
        style: TextStyle(
          color: dark ? Colors.white : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
