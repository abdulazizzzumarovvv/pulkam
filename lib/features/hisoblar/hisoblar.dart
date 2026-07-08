import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../amallar/logic/amal_cubit.dart';
import '../amallar/data/amal_model.dart';
import 'hisoblar_tab/logic/hisob_cubit.dart';
import 'hisoblar_tab/data/hisob_model.dart';
import 'maqsadlar_tab/logic/maqsad_cubit.dart';
import 'maqsadlar_tab/data/maqsad_model.dart';
import 'qarzlar_tab/logic/qarz_cubit.dart';
import 'qarzlar_tab/data/qarz_model.dart';
import 'widgets/calculator/kirim_chiqim_sheet.dart';
import 'widgets/calculator/maqsad_topup_sheet.dart';
import 'widgets/calculator/maqsad_transfer_sheet.dart';
import 'widgets/calculator/hisob_transfer_sheet.dart';
import 'widgets/calculator/qarz_tolov_sheet.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/features/pro/ui/pro_page.dart';
import 'package:pulkam/l10n.dart';
import 'package:pulkam/services/tutorial_service.dart';
import 'hisoblar_shared.dart' show kNumStyle;

const double _btnSize = 52.0;
const double _btnHalf = _btnSize / 2;
const double _cardH = 168.0;
const double _hisobGap = 48.0;

// tab titles are now dynamic — see _tabTitle(context, i) below
const _qarzGreen = Color(0xFF27AE60);
const _qarzRed = Color(0xFFE74C3C);

// Inline-edit rejimidagi rang palitrasi (loyihaning color_picker ranglari)
const _palette = <Color>[
  Color(0xFFFF6B6B),
  Color(0xFFFF5252),
  Color(0xFFFF1744),
  Color(0xFFD50000),
  Color(0xFFFF8A80),
  Color(0xFFFF6E40),
  Color(0xFFFF3D00),
  Color(0xFFDD2C00),
  Color(0xFFFFAB40),
  Color(0xFFFF9100),
  Color(0xFFFF6D00),
  Color(0xFFE65100),
  Color(0xFFFFD740),
  Color(0xFFFFAB00),
  Color(0xFFFF6F00),
  Color(0xFFF57F17),
  Color(0xFFCCFF90),
  Color(0xFF69F0AE),
  Color(0xFF00E676),
  Color(0xFF00C853),
  Color(0xFF64FFDA),
  Color(0xFF1DE9B6),
  Color(0xFF00BFA5),
  Color(0xFF004D40),
  Color(0xFF80D8FF),
  Color(0xFF40C4FF),
  Color(0xFF0091EA),
  Color(0xFF01579B),
  Color(0xFF82B1FF),
  Color(0xFF448AFF),
  Color(0xFF2979FF),
  Color(0xFF2962FF),
  Color(0xFFB388FF),
  Color(0xFF7C4DFF),
  Color(0xFF651FFF),
  Color(0xFF6200EA),
  Color(0xFFEA80FC),
  Color(0xFFE040FB),
  Color(0xFFD500F9),
  Color(0xFFAA00FF),
  Color(0xFFFF80AB),
  Color(0xFFFF4081),
  Color(0xFFF50057),
  Color(0xFFC51162),
  Color(0xFF90A4AE),
  Color(0xFF546E7A),
  Color(0xFF263238),
];

String _maqsadDate(int ms, AppL10n l10n) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.day} ${l10n.oylarQisqa[d.month - 1]} ${d.year}';
}


// Height helpers — must match Stack calculations below.
// Collapsed = bitta karta ko'rinadi (hammasi ustma-ust), expanded = barchasi ochiq.
double _hisoblarHeight(List<HisobModel> list, bool expanded) {
  if (list.isEmpty) return _cardH;
  final n = list.length;
  return expanded ? n * _cardH + (n - 1) * _hisobGap + _btnHalf : _cardH;
}

double _maqsadlarHeight(List<MaqsadModel> list, bool expanded) {
  if (list.isEmpty) return _cardH;
  final n = list.length;
  return expanded ? n * _cardH + (n - 1) * _hisobGap + _btnHalf : _cardH;
}

double _qarzlarHeight(List<QarzModel> list, bool expanded) {
  if (list.isEmpty) return _cardH;
  final n = list.length;
  return expanded ? n * _cardH + (n - 1) * _hisobGap + _btnHalf : _cardH;
}

class Hisoblar extends StatefulWidget {
  const Hisoblar({super.key});

  @override
  State<Hisoblar> createState() => _HisoblarState();
}

class _HisoblarState extends State<Hisoblar> {
  late PageController _tabCtrl;
  int _tabIndex = 1; // 0=Qarzlar, 1=Hisoblar, 2=Maqsadlar
  // Joriy tab avtomatik ochiq, qolganlari yopiq (bitta karta).
  final _expanded = [false, true, false];
  // Inline-edit: tahrirlanayotgan model (null = tahrir yo'q)
  Object? _editItem;
  // Inline-add: qaysi tabda yangi karta qo'shilmoqda (null = yo'q)
  int? _addingTab;
  // O'chirishni tasdiqlash: o'chirilayotgan model (null = yo'q)
  Object? _deleteItem;

  void _startEdit(Object item) => setState(() {
    _addingTab = null;
    _deleteItem = null;
    _editItem = item;
  });
  void _endEdit() => setState(() => _editItem = null);
  void _startDelete(Object item) => setState(() {
    _addingTab = null;
    _editItem = null;
    _deleteItem = item;
  });
  void _endDelete() => setState(() => _deleteItem = null);
  void _startAdd() {
    // Pro cheklovi: maqsadlar (orzular) 5 ta, qarzlar 4 ta maksimum
    final isPro = context.read<SozlamalarCubit>().state.isPro;
    if (!isPro) {
      if (_tabIndex == 2) {
        final aktivMaqsadlar = context
            .read<MaqsadCubit>()
            .state
            .maqsadlar
            .where((m) => !m.bajarilgan)
            .length;
        if (aktivMaqsadlar >= 5) {
          showProPage(context);
          return;
        }
      } else if (_tabIndex == 0) {
        final aktivQarzlar = context
            .read<QarzCubit>()
            .state
            .qarzlar
            .where((q) => !q.bajarilgan)
            .length;
        if (aktivQarzlar >= 4) {
          showProPage(context);
          return;
        }
      }
    }
    setState(() {
      _editItem = null;
      _addingTab = _tabIndex;
    });
  }
  void _endAdd() => setState(() => _addingTab = null);

  @override
  void initState() {
    super.initState();
    _tabCtrl = PageController(viewportFraction: 0.88, initialPage: 1);

    // Tutorial: qo'lcha bilan swipe ko'rsatib, tablarni namoyish qilish
    tutorialTablarKorsat = () async {
      if (!_tabCtrl.hasClients || !mounted) return;
      Future<void> tabga(int i) => _tabCtrl.animateToPage(
            i,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOut,
          );

      // Qo'lcha overlay — swipe harakatini ko'rsatadi
      final qol = _SwipeHandController();
      final entry = OverlayEntry(
        builder: (_) => _SwipeHand(controller: qol),
      );
      Overlay.of(context, rootOverlay: true).insert(entry);

      try {
        // Avval qo'l animatsiyasi to'liq ko'rsatiladi, keyin swipe
        // O'ngga swipe (qo'l chapdan o'ngga) → Qarzlar
        await qol.korsat(ongga: true);
        await Future.delayed(const Duration(milliseconds: 250));
        await tabga(0);
        await Future.delayed(const Duration(milliseconds: 1100));

        // Chapga swipe (qo'l o'ngdan chapga) → Maqsadlar tomon
        await qol.korsat(ongga: false);
        await Future.delayed(const Duration(milliseconds: 250));
        await tabga(2);
        await Future.delayed(const Duration(milliseconds: 1100));

        // Hisoblarga qaytish
        await qol.korsat(ongga: true);
        await Future.delayed(const Duration(milliseconds: 250));
        await tabga(1);
        await Future.delayed(const Duration(milliseconds: 400));
      } finally {
        entry.remove();
      }
    };
  }

  @override
  void dispose() {
    tutorialTablarKorsat = null;
    _tabCtrl.dispose();
    super.dispose();
  }

  Widget _addButton(BuildContext context) {
    return GestureDetector(
      onTap: _startAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          child: const Icon(Icons.add, color: Colors.white, size: 25,),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    final hisoblar = context.watch<HisobCubit>().state.hisoblar;
    final allMaqsadlar = context.watch<MaqsadCubit>().state.maqsadlar;
    // Bajarilganlar asosiy carouseldan chiqib, arxivga o'tadi
    final maqsadlar = allMaqsadlar.where((m) => !m.bajarilgan).toList();
    final allQarzlar = context.watch<QarzCubit>().state.qarzlar;
    // Bitgan (to'langan) qarzlar ham arxivga o'tadi
    final qarzlar = allQarzlar.where((q) => !q.bajarilgan).toList();

    // Container height tracks current tab's expanded/collapsed state.
    final double pageH = switch (_tabIndex) {
      0 => _qarzlarHeight(qarzlar, _expanded[0]),
      2 => _maqsadlarHeight(maqsadlar, _expanded[2]),
      _ => _hisoblarHeight(hisoblar, _expanded[1]),
    };

    final bool curEmpty = switch (_tabIndex) {
      0 => qarzlar.isEmpty,
      2 => maqsadlar.isEmpty,
      _ => hisoblar.isEmpty,
    };
    final bool adding = _addingTab == _tabIndex;
    // Bo'sh tabda qo'shilayotganda karusel yashiriladi — add karta uning o'rnini egallaydi
    final bool hideCarousel = adding && curEmpty;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Qarzlar / Maqsadlar tabida — bajarilganlar arxivi tugmasi
            if (_tabIndex == 0 || _tabIndex == 2) ...[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _tabIndex == 0
                        ? BlocProvider.value(
                            value: context.read<QarzCubit>(),
                            child: const BajarilganQarzlarScreen(),
                          )
                        : BlocProvider.value(
                            value: context.read<MaqsadCubit>(),
                            child: const BajarilganMaqsadlarScreen(),
                          ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                [context.l10n.qarzlar, context.l10n.hisoblar, context.l10n.maqsadlar][_tabIndex],
                key: ValueKey(_tabIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [_addButton(context)],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Inline-add: yangi karta yuqorida (klaviatura berkitmasligi uchun) ──
                if (adding)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _EditOverlayCard(
                      key: ValueKey('add-$_tabIndex'),
                      tab: _tabIndex,
                      item: null,
                      hisoblar: hisoblar,
                      onDone: _endAdd,
                    ),
                  ),

                // ── Carousel — viewportFraction 0.88 qo'shni kartalarni ko'rsatadi ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOut,
                  height: hideCarousel ? 0 : pageH + 12,
                  child: PageView(
                    controller: _tabCtrl,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (i) => setState(() {
                      _expanded[_tabIndex] = false; // oldingi tabni yop
                      _addingTab = null; // tab almashganda add bekor
                      _tabIndex = i;
                      _expanded[i] = true; // yangi tabni avtomatik och
                    }),
                    children: [
                      // 0 — Qarzlar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _QarzStack(
                            qarzlar: qarzlar,
                            expanded: _expanded[0],
                            onToggle: () =>
                                setState(() => _expanded[0] = !_expanded[0]),
                            onEdit: _startEdit,
                            onDelete: _startDelete,
                          ),
                        ),
                      ),

                      // 1 — Hisoblar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _CardStack(
                            hisoblar: hisoblar,
                            expanded: _expanded[1],
                            onToggle: () =>
                                setState(() => _expanded[1] = !_expanded[1]),
                            onEdit: _startEdit,
                            onDelete: _startDelete,
                          ),
                        ),
                      ),

                      // 2 — Maqsadlar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _MaqsadStack(
                            maqsadlar: maqsadlar,
                            expanded: _expanded[2],
                            onToggle: () =>
                                setState(() => _expanded[2] = !_expanded[2]),
                            onEdit: _startEdit,
                            onDelete: _startDelete,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Outer PageView swipe uchun kichik maydon ────────────
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Inline-edit overlay: orqa fon blur + markazda tahrir karta ──
          if (_editItem != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _endEdit,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: _EditOverlayCard(
                    key: ValueKey(_editItem),
                    tab: _tabIndex,
                    item: _editItem,
                    hisoblar: hisoblar,
                    onDone: _endEdit,
                  ),
                ),
              ),
            ),
          ],

          // ── O'chirishni tasdiqlash overlay: blur + karta ustida ──
          if (_deleteItem != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _endDelete,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: _DeleteOverlayCard(
                    key: ValueKey(_deleteItem),
                    tab: _tabIndex,
                    item: _deleteItem!,
                    onDone: _endDelete,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Hisoblar stack ────────────────────────────────────────────────────
class _CardStack extends StatelessWidget {
  final List<HisobModel> hisoblar;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;

  const _CardStack({
    required this.hisoblar,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (hisoblar.isEmpty) {
      return _EmptyCard(
        message: context.l10n.hisobYoq,
        icon: Icons.account_balance_wallet_rounded,
      );
    }
    final n = hisoblar.length;
    final h = _hisoblarHeight(hisoblar, expanded);

    return SizedBox(
      width: double.infinity,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        // Teskari z-tartib: 0-karta eng ustda ko'rinadi (yopilganda u qoladi)
        children: List.generate(n, (k) {
          final i = n - 1 - k;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            top: expanded ? i * (_cardH + _hisobGap) : 0,
            left: 0,
            right: 0,
            height: _cardH,
            child: GestureDetector(
              onTap: onToggle,
              child: _HisobCard(
                hisob: hisoblar[i],
                allHisoblar: hisoblar,
                stackExpanded: expanded,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HisobCard extends StatelessWidget {
  final HisobModel hisob;
  final List<HisobModel> allHisoblar;
  final bool stackExpanded;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const _HisobCard({
    required this.hisob,
    required this.allHisoblar,
    required this.stackExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final balance = double.tryParse(hisob.balance) ?? 0;
    final fmtKod = context.read<SozlamalarCubit>().state.formatKod;
    final formatted = appFmt(balance, fmtKod);
    final decSep = (fmtKod == 'dot_comma' || fmtKod == 'space_comma') ? ',' : '.';
    final dotIdx = formatted.lastIndexOf(decSep);
    final intPart = dotIdx >= 0 ? formatted.substring(0, dotIdx) : formatted;
    final decPart = dotIdx >= 0 ? formatted.substring(dotIdx) : '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: hisob.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: hisob.color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hisob.displayName(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _UzsBadge(),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(intPart, style: kNumStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3, left: 2),
                              child: Text(
                                decPart,
                                style: kNumStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Glass tugmalar — faqat expanded holda ko'rinadi
        Positioned(
          bottom: -_btnHalf,
          left: 20,
          child: AnimatedOpacity(
            opacity: stackExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !stackExpanded,
              child: Row(
                children: [
                  _GlassBtn(
                    icon: Icons.edit_outlined,
                    onTap: () => onEdit(hisob),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: Icons.swap_vert_rounded,
                    onTap: () => _showTopUp(context),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: Icons.swap_horiz_rounded,
                    onTap: () => _showTransfer(context),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => onDelete(hisob),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTopUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KirimChiqimSheet(hisob: hisob)),
    );
  }

  void _showTransfer(BuildContext context) {
    final others = allHisoblar.where((h) => h.key != hisob.key).toList();
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.boshqaHisobYoq),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HisobTransferSheet(source: hisob, boshqalar: others),
    );
  }
}

// ── Maqsadlar stack ───────────────────────────────────────────────────
class _MaqsadStack extends StatelessWidget {
  final List<MaqsadModel> maqsadlar;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const _MaqsadStack({
    required this.maqsadlar,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (maqsadlar.isEmpty) {
      return _EmptyCard(
        message: context.l10n.maqsadYoq,
        icon: Icons.emoji_events_rounded,
      );
    }
    final n = maqsadlar.length;
    final h = _maqsadlarHeight(maqsadlar, expanded);

    return SizedBox(
      width: double.infinity,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(n, (k) {
          final i = n - 1 - k;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            top: expanded ? i * (_cardH + _hisobGap) : 0,
            left: 0,
            right: 0,
            height: _cardH,
            child: GestureDetector(
              onTap: onToggle,
              child: _MaqsadCard(
                maqsad: maqsadlar[i],
                allMaqsadlar: maqsadlar,
                stackExpanded: expanded,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MaqsadCard extends StatelessWidget {
  final MaqsadModel maqsad;
  final List<MaqsadModel> allMaqsadlar;
  final bool stackExpanded;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const _MaqsadCard({
    required this.maqsad,
    required this.allMaqsadlar,
    required this.stackExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  // Foiz / UZS badge — fon va matn rangi `fg` ga moslashadi
  Widget _badge(String text, Color fg, {double fontSize = 12}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.66,
        vertical: fontSize * 0.33,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Karta tarkibi — ikki marta chiziladi: oq fonda rangli, to'lgan
  // qism ustida oq matn bilan (ikki tonli, har doim o'qiladi)
  Widget _content(
    Color fg,
    Color subFg,
    bool done,
    int pct,
    String intPart,
    String decPart,
    String currencyKod,
    AppL10n l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  maqsad.displayName(l10n),
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Olov bajarilganda alohida overlay sifatida chiziladi (pastda)
              if (!done && pct > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$pct',
                      style: TextStyle(
                        color: fg,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _badge('%', fg, fontSize: 10),
                  ],
                ),
              // Kalendar tugmasi uchun joy (Stack ustida chiziladi)
              if (!done) const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _badge(currencyKod, fg),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(intPart, style: kNumStyle(fontSize: 32, fontWeight: FontWeight.bold, color: fg, height: 1)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3, left: 2),
                        child: Text(decPart, style: kNumStyle(fontSize: 18, fontWeight: FontWeight.w500, color: subFg)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Muddat yozuvi: "26 dekabr 2026 gacha" — maqsad rangida,
          // muddat o'tgan bo'lsa qizil chiziq bilan o'ralgan
          if (!done && maqsad.deadline > 0) ...[
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final otgan = DateTime.now().millisecondsSinceEpoch >
                  maqsad.deadline;
              const qizil = Color(0xFFE74C3C);
              return Container(
                padding: otgan
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                    : EdgeInsets.zero,
                decoration: otgan
                    ? BoxDecoration(
                        border: Border.all(color: qizil, width: 1.4),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Text(
                  l10n.maqsadMuddat(
                      _maqsadDate(maqsad.deadline, l10n)),
                  style: TextStyle(
                    color: otgan ? qizil : fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
          if (done) ...[
            const SizedBox(height: 8),
            Text(
              l10n.maqsadBajarildi,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            if (maqsad.completedAt > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _maqsadDate(maqsad.completedAt, l10n),
                  style: TextStyle(
                    color: subFg,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = double.tryParse(maqsad.balance) ?? 0;
    final fmtKod = context.read<SozlamalarCubit>().state.formatKod;
    final balFmt = appFmt(balance, fmtKod);
    final decSepB = (fmtKod == 'dot_comma' || fmtKod == 'space_comma') ? ',' : '.';
    final dotB = balFmt.lastIndexOf(decSepB);
    final intPart = dotB >= 0 ? balFmt.substring(0, dotB) : balFmt;
    final decPart = dotB >= 0 ? balFmt.substring(dotB) : '';
    final progress = maqsad.progress.clamp(0.0, 1.0);
    final done = progress >= 1.0;
    final pct = (progress * 100).toInt();
    final col = maqsad.color;
    final currencyKod = context.watch<SozlamalarCubit>().state.valyutaKod;
    final l10n = context.l10n;

    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: col, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: col.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Layer A — oq fon ustida rangli matn (butun karta)
            Positioned.fill(
              child: _content(
                col,
                col.withValues(alpha: 0.5),
                done,
                pct,
                intPart,
                decPart,
                currencyKod,
                l10n,
              ),
            ),
            // Layer B — pastki to'lgan qism: rang foni + oq matn birga
            // kesiladi, shu sabab to'lgan joyda matn doim oq bo'ladi
            Positioned.fill(
              child: ClipRect(
                clipper: _BottomFillClipper(progress),
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: col)),
                    Positioned.fill(
                      child: _content(
                        Colors.white,
                        Colors.white.withValues(alpha: 0.6),
                        done,
                        pct,
                        intPart,
                        decPart,
                        currencyKod,
                        l10n,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bajarilganda — yonib turadigan katta olov (faqat olov)
            if (done) const Positioned(right: 20, bottom: 44, child: _Flame()),
            // Kalendar — o'ng tepada, maqsad muddatini belgilash
            if (!done)
              Positioned(
                top: 12,
                right: 14,
                child: GestureDetector(
                  onTap: () => _sanaTanla(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: col,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: card),
        // Glass tugmalar — faqat expanded holda; bajarilgan maqsadda chiqmaydi
        if (!done)
          Positioned(
            bottom: -_btnHalf,
            left: 20,
            child: AnimatedOpacity(
              opacity: stackExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !stackExpanded,
                child: Row(
                  children: [
                    _GlassBtn(
                      icon: Icons.edit_outlined,
                      onTap: () => onEdit(maqsad),
                    ),
                    const SizedBox(width: 12),
                    _GlassBtn(
                      icon: Icons.add_rounded,
                      onTap: () => _showTopUp(context),
                    ),
                    const SizedBox(width: 12),
                    _GlassBtn(
                      icon: Icons.swap_horiz_rounded,
                      onTap: () => _showTransfer(context),
                    ),
                    const SizedBox(width: 12),
                    _GlassBtn(
                      icon: Icons.delete_outline_rounded,
                      onTap: () => onDelete(maqsad),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Maqsad muddatini tanlash — kalendar maqsad rangida ──────────────
  Future<void> _sanaTanla(BuildContext context) async {
    final col = maqsad.color;
    final now = DateTime.now();
    final tanlangan = await showDatePicker(
      context: context,
      initialDate: maqsad.deadline > 0
          ? DateTime.fromMillisecondsSinceEpoch(maqsad.deadline)
          : now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 30),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: col,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (tanlangan == null || !context.mounted) return;
    context.read<MaqsadCubit>().updateMaqsad(
          maqsad,
          MaqsadModel(
            name: maqsad.name,
            balance: maqsad.balance,
            target: maqsad.target,
            iconCode: maqsad.iconCode,
            colorValue: maqsad.colorValue,
            isCompleted: maqsad.isCompleted,
            completedAt: maqsad.completedAt,
            defaultKey: maqsad.defaultKey,
            deadline: tanlangan.millisecondsSinceEpoch,
          ),
        );
  }

  void _showTopUp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MaqsadTopUpSheet(maqsad: maqsad),
    );
  }

  void _showTransfer(BuildContext context) {
    final others = allMaqsadlar.where((m) => m.key != maqsad.key).toList();
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.boshqaMaqsadYoq),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MaqsadTransferSheet(source: maqsad, boshqalar: others),
    );
  }
}

// Bajarilgan maqsad uchun yonib turadigan olov (oq borderli)
class _Flame extends StatefulWidget {
  const _Flame();

  @override
  State<_Flame> createState() => _FlameState();
}

class _FlameState extends State<_Flame> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final glow = 12.0 + 16.0 * t;
        return Transform.scale(
          scale: 1 + 0.12 * t,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 42,
            color: const Color(0xFFFF7A1A),
            shadows: [
              BoxShadow(
                color: const Color(0xFFFF7A1A).withValues(alpha: 0.9),
                blurRadius: glow,
              ),
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.65),
                blurRadius: glow + 8,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Pastdan yuqoriga `progress` ulushini kesadi (rang to'ldirgich + oq matn uchun)
class _BottomFillClipper extends CustomClipper<Rect> {
  final double progress;
  const _BottomFillClipper(this.progress);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);

  @override
  bool shouldReclip(_BottomFillClipper oldClipper) =>
      oldClipper.progress != progress;
}

// ── Qarzlar stack ─────────────────────────────────────────────────────
class _QarzStack extends StatelessWidget {
  final List<QarzModel> qarzlar;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const _QarzStack({
    required this.qarzlar,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (qarzlar.isEmpty) {
      return _EmptyCard(
        message: context.l10n.qarzYoq,
        icon: Icons.sentiment_satisfied_rounded,
      );
    }
    final n = qarzlar.length;
    final h = _qarzlarHeight(qarzlar, expanded);

    return SizedBox(
      width: double.infinity,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(n, (k) {
          final i = n - 1 - k;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            top: expanded ? i * (_cardH + _hisobGap) : 0,
            left: 0,
            right: 0,
            height: _cardH,
            child: GestureDetector(
              onTap: onToggle,
              child: _QarzCard(
                qarz: qarzlar[i],
                stackExpanded: expanded,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QarzCard extends StatelessWidget {
  final QarzModel qarz;
  final bool stackExpanded;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const _QarzCard({
    required this.qarz,
    required this.stackExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _badge(String text, Color fg, {double fontSize = 12}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.66,
        vertical: fontSize * 0.33,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Ikki tonli tarkib (oq fonda rangli, to'lgan qism ustida oq)
  Widget _content(
    Color fg,
    Color subFg,
    Color iconColor,
    int pct,
    String intPart,
    String decPart,
    String currencyKod,
    AppL10n l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Stack(
        children: [
          // Line-graph uslubidagi yo'nalish strelkasi — o'ng-pastda
          Positioned(
            right: 0,
            bottom: 4,
            child: Icon(
              qarz.isQarzBerdim
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: iconColor,
              size: 40,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      qarz.personName,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Foiz — Maqsad kartasidagidek (0% bo'lsa ko'rinmaydi)
                  if (pct > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '$pct',
                      style: TextStyle(
                        color: fg,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _badge('%', fg, fontSize: 10),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _badge(currencyKod, fg),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(intPart, style: kNumStyle(fontSize: 32, fontWeight: FontWeight.bold, color: fg, height: 1)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, left: 2),
                            child: Text(decPart, style: kNumStyle(fontSize: 18, fontWeight: FontWeight.w500, color: subFg)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Yopilgan qarz — maqsad kartasidagidek yorliq + sana
              if (qarz.bajarilgan) ...[
                const SizedBox(height: 8),
                Text(
                  qarz.isQarzBerdim ? l10n.qaytarildi : l10n.tolangan,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _maqsadDate(qarz.bitganSana, l10n),
                    style: TextStyle(
                      color: subFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = qarz.isQarzBerdim ? _qarzGreen : _qarzRed;
    final darkColor = Color.lerp(color, Colors.black, 0.3)!;
    // Yopilgan qarzda to'langan summa (amount), aks holda qoldiq ko'rsatiladi
    final shownVal = qarz.bajarilgan
        ? (double.tryParse(qarz.amount) ?? 0)
        : qarz.remaining;
    final fmtKod = context.read<SozlamalarCubit>().state.formatKod;
    final remFmt = appFmt(shownVal, fmtKod);
    final decSepQ = (fmtKod == 'dot_comma' || fmtKod == 'space_comma') ? ',' : '.';
    final dotB = remFmt.lastIndexOf(decSepQ);
    final intPart = dotB >= 0 ? remFmt.substring(0, dotB) : remFmt;
    final decPart = dotB >= 0 ? remFmt.substring(dotB) : '';
    final progress = qarz.progress.clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();
    final currencyKod = context.watch<SozlamalarCubit>().state.valyutaKod;
    final l10n = context.l10n;

    // Kartaning asosiy (yuqori) qismi — ikki tonli to'ldirish
    final coreStack = Stack(
      children: [
        // Layer A — oq fon ustida rangli matn
        Positioned.fill(
          child: _content(
            color,
            color.withValues(alpha: 0.5),
            darkColor,
            pct,
            intPart,
            decPart,
            currencyKod,
            l10n,
          ),
        ),
        // Layer B — to'langan qism: rang foni + oq matn
        Positioned.fill(
          child: ClipRect(
            clipper: _BottomFillClipper(progress),
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: color)),
                Positioned.fill(
                  child: _content(
                    Colors.white,
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white,
                    pct,
                    intPart,
                    decPart,
                    currencyKod,
                    l10n,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: coreStack,
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: card),
        // Glass tugmalar — faqat expanded holda ko'rinadi
        Positioned(
          bottom: -_btnHalf,
          left: 20,
          child: AnimatedOpacity(
            opacity: stackExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !stackExpanded,
              child: Row(
                children: [
                  _GlassBtn(
                    icon: Icons.edit_outlined,
                    onTap: () => onEdit(qarz),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: qarz.isQarzBerdim
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    onTap: () => _showTolov(context),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: Icons.receipt_long_rounded,
                    onTap: () => _showHistory(context),
                  ),
                  const SizedBox(width: 12),
                  _GlassBtn(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => onDelete(qarz),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QarzHistorySheet(qarz: qarz),
    );
  }

  void _showTolov(BuildContext context) {
    final hisoblar = context.read<HisobCubit>().state.hisoblar;
    if (hisoblar.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.hisobYoq)));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QarzTolovSheet(qarz: qarz, hisoblar: hisoblar),
    );
  }
}

// ── Bo'sh holat kartasi (suzib turadigan jonli ikonka) ────────────────
class _EmptyCard extends StatefulWidget {
  final String message;
  final IconData icon;
  const _EmptyCard({
    required this.message,
    this.icon = Icons.sentiment_satisfied_rounded,
  });

  @override
  State<_EmptyCard> createState() => _EmptyCardState();
}

class _EmptyCardState extends State<_EmptyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _cardH,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yumshoq suzib + pulse qiladigan ikonka
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_ctrl.value);
                return Transform.translate(
                  offset: Offset(0, -6 * t),
                  child: Transform.scale(scale: 1 + 0.08 * t, child: child),
                );
              },
              child: Icon(widget.icon, color: Colors.grey[400], size: 42),
            ),
            const SizedBox(height: 12),
            Text(
              widget.message,
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── UZS badge ─────────────────────────────────────────────────────────
class _UzsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kod = context.watch<SozlamalarCubit>().state.valyutaKod;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        kod,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Glass tugma ───────────────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: _btnSize,
            height: _btnSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ── Inline edit/add karta ─────────────────────────────────────────────
// tab: 0=Qarz, 1=Hisob, 2=Maqsad. item==null bo'lsa — yangi karta (create).
class _EditOverlayCard extends StatefulWidget {
  final int tab;
  final Object? item; // null = yangi karta qo'shish
  final List<HisobModel> hisoblar; // Qarz create uchun hisob dropdown
  final VoidCallback onDone;
  const _EditOverlayCard({
    super.key,
    required this.tab,
    required this.item,
    required this.hisoblar,
    required this.onDone,
  });

  @override
  State<_EditOverlayCard> createState() => _EditOverlayCardState();
}

class _EditOverlayCardState extends State<_EditOverlayCard>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  final _targetCtrl = TextEditingController(); // Maqsad create — maqsad puli
  late Color _color; // palitra orqali o'zgaradi
  late final bool _whiteCard; // Maqsad — oq fon
  bool _isQarzBerdim = false; // Qarz create — yo'nalish
  HisobModel? _selectedHisob; // Qarz create — tanlangan hisob
  late final AnimationController _flash; // qarz berishda mablag' yetmasa sirena

  bool get _create => widget.item == null;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14400),
    );
    final item = widget.item;
    switch (widget.tab) {
      case 0:
        final q = item as QarzModel?;
        _nameCtrl = TextEditingController(text: q?.personName ?? '');
        _amountCtrl = TextEditingController(text: q?.amount ?? '');
        _isQarzBerdim = q?.isQarzBerdim ?? false;
        _selectedHisob = widget.hisoblar.isNotEmpty
            ? widget.hisoblar.first
            : null;
        _color = _isQarzBerdim ? _qarzGreen : _qarzRed;
        _whiteCard = false;
      case 2:
        final m = item as MaqsadModel?;
        _nameCtrl = TextEditingController(text: m?.name ?? '');
        _amountCtrl = TextEditingController(text: m?.balance ?? '');
        _targetCtrl.text = m?.target ?? ''; // edit'da maqsad puli ham
        _color = m?.color ?? _randomColor();
        _whiteCard = true;
      default:
        final h = item as HisobModel?;
        _nameCtrl = TextEditingController(text: h?.name ?? '');
        _amountCtrl = TextEditingController(text: h?.balance ?? '');
        _color = h?.color ?? _randomColor();
        _whiteCard = false;
    }
  }

  Color _randomColor() => _palette[Random().nextInt(_palette.length)];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _targetCtrl.dispose();
    _flash.dispose();
    super.dispose();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final amt = double.tryParse(_amountCtrl.text.trim());

    // Umumiy validatsiyalar
    if (name.isEmpty) {
      _err('Nom kiriting');
      return;
    }
    if (amt == null) {
      _err('Summa kiriting');
      return;
    }
    final amount = amt.toStringAsFixed(2);

    switch (widget.tab) {
      case 0: // Qarz
        if (amt <= 0) {
          _err('Summa kiriting');
          return;
        }
        if (_create) {
          if (_selectedHisob == null) {
            _err('Hisob tanlang');
            return;
          }
          final hisob = _selectedHisob!;
          // Qarz berishda hisobdan pul chiqadi — mablag' yetmasa sirena
          final hbal = double.tryParse(hisob.balance) ?? 0;
          if (_isQarzBerdim && amt > hbal) {
            _flash.forward(from: 0);
            return;
          }
          final now = DateTime.now().millisecondsSinceEpoch;
          context.read<QarzCubit>().addQarz(
            QarzModel(
              personName: name,
              amount: amount,
              isQarzBerdim: _isQarzBerdim,
              hisobName: hisob.name,
              timestamp: now,
            ),
          );
          // Hisob balansini yangilash
          final oldBal = double.tryParse(hisob.balance) ?? 0;
          final newBal = _isQarzBerdim ? oldBal - amt : oldBal + amt;
          context.read<HisobCubit>().updateBalance(
            hisob,
            newBal.toStringAsFixed(2),
          );
          // Amal qo'shish
          context.read<AmalCubit>().addAmal(
            AmalModel(
              kategoriyaName: _isQarzBerdim ? 'Qarz berdim' : 'Qarz oldim',
              amount: amount,
              kategoriyaIconCode:
                  (_isQarzBerdim ? Icons.trending_up : Icons.trending_down)
                      .codePoint,
              kategoriyaColorValue: _color.toARGB32(),
              hisobName: hisob.name,
              isKirim: !_isQarzBerdim,
              timestamp: now,
            ),
          );
        } else {
          final q = widget.item as QarzModel;
          context.read<QarzCubit>().updateQarz(
            q,
            QarzModel(
              personName: name,
              amount: amount,
              paid: q.paid,
              isQarzBerdim: q.isQarzBerdim,
              hisobName: q.hisobName,
              timestamp: q.timestamp,
              tolovlar: q.tolovlar,
            ),
          );
        }
      case 2: // Maqsad
        if (_create) {
          final tgt = double.tryParse(_targetCtrl.text.trim());
          if (tgt == null || tgt <= 0) {
            _err('Maqsad puli kiriting');
            return;
          }
          if (amt >= tgt) {
            _err("Pulingiz maqsad pulidan kamroq bo'lishi kerak");
            return;
          }
          context.read<MaqsadCubit>().addMaqsad(
            MaqsadModel(
              name: name,
              balance: amount,
              target: tgt.toStringAsFixed(2),
              iconCode: Icons.auto_awesome.codePoint,
              colorValue: _color.toARGB32(),
            ),
          );
        } else {
          final m = widget.item as MaqsadModel;
          final tgt = double.tryParse(_targetCtrl.text.trim());
          if (tgt == null || tgt <= 0) {
            _err('Maqsad puli kiriting');
            return;
          }
          context.read<MaqsadCubit>().updateMaqsad(
            m,
            MaqsadModel(
              name: name,
              balance: amount,
              target: tgt.toStringAsFixed(2),
              iconCode: m.iconCode,
              colorValue: _color.toARGB32(),
              isCompleted: m.isCompleted,
              completedAt: m.completedAt,
              defaultKey: m.defaultKey,
              deadline: m.deadline,
            ),
          );
        }
      default: // Hisob
        if (_create) {
          context.read<HisobCubit>().addHisob(
            HisobModel(
              name: name,
              balance: amount,
              iconCode: Icons.add_card_outlined.codePoint,
              colorValue: _color.toARGB32(),
            ),
          );
        } else {
          final h = widget.item as HisobModel;
          context.read<HisobCubit>().updateHisob(
            h,
            HisobModel(
              name: name,
              balance: amount,
              iconCode: h.iconCode,
              colorValue: _color.toARGB32(),
              defaultKey: h.defaultKey,
            ),
          );
        }
    }
    widget.onDone();
  }

  Widget _uzsBadge(Color fg) {
    final kod = context.watch<SozlamalarCubit>().state.valyutaKod;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        kod,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputBorder _border(Color fg, double alpha) => UnderlineInputBorder(
    borderSide: BorderSide(color: fg.withValues(alpha: alpha)),
  );

  // Qarz create — Berdim/Oldim pill
  Widget _dirPill(String label, bool berdimVal) {
    final selected = _isQarzBerdim == berdimVal;
    return GestureDetector(
      onTap: () => setState(() {
        _isQarzBerdim = berdimVal;
        _color = berdimVal ? _qarzGreen : _qarzRed;
      }),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _color : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Qarz create — hisob tanlash dropdowni
  // Qarz create — hisob tanlash: mini kartalar (har biri o'z rangida, nomi bilan)
  Widget _hisobSelector(Color fg) {
    if (widget.hisoblar.isEmpty) {
      return Text(
        'Avval hisob qo\'shing',
        style: TextStyle(color: fg.withValues(alpha: 0.7)),
      );
    }
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.hisoblar.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final h = widget.hisoblar[i];
          final selected = _selectedHisob?.key == h.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedHisob = h),
            child: AnimatedBuilder(
              animation: _flash,
              builder: (_, _) {
                Color brd;
                if (!selected) {
                  brd = Colors.white.withValues(alpha: 0.25);
                } else if (_flash.isAnimating) {
                  final intensity = (1 - cos(_flash.value * 4 * pi)) / 2;
                  brd = Color.lerp(
                    Colors.white,
                    const Color(0xFFE74C3C),
                    intensity,
                  )!;
                } else {
                  brd = Colors.white;
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 112,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: h.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brd, width: selected ? 2.5 : 1),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: h.color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nom (tepada)
                      Text(
                        h.displayName(ctx.l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // UZS badge + summa (pastda, kichik)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              context.watch<SozlamalarCubit>().state.valyutaKod,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              appFmt(double.tryParse(h.balance) ?? 0, context.read<SozlamalarCubit>().state.formatKod),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    required bool primary,
  }) {
    final iconColor = (_whiteCard && !primary) ? Colors.black54 : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _btnSize,
        height: _btnSize,
        decoration: BoxDecoration(
          color: primary
              ? (_whiteCard ? _color : Colors.white.withValues(alpha: 0.25))
              : (_whiteCard
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.12)),
          shape: BoxShape.circle,
          border: _whiteCard
              ? (primary
                    ? null
                    : Border.all(
                        color: Colors.black.withValues(alpha: 0.15),
                        width: 1.2,
                      ))
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.2,
                ),
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fg = _whiteCard ? _color : Colors.white;
    final l10n = context.l10n;
    final nameHint = switch (widget.tab) {
      0 => l10n.kimdan,
      2 => l10n.maqsadNomi,
      _ => l10n.hisobNomi,
    };

    Widget amountRow(TextEditingController c, double size) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _uzsBadge(fg),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: c,
              cursorColor: fg,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                color: fg,
                fontSize: size,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 4),
                enabledBorder: _border(fg, 0.35),
                focusedBorder: _border(fg, 1.0),
              ),
            ),
          ),
        ],
      );
    }

    Widget miniLabel(String t) => Text(
      t,
      style: TextStyle(
        color: fg.withValues(alpha: 0.7),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: _whiteCard ? Colors.white : _color,
          borderRadius: BorderRadius.circular(24),
          border: _whiteCard ? Border.all(color: _color, width: 2.5) : null,
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: _whiteCard ? 0.18 : 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Qarz create — Berdim/Oldim
            if (_create && widget.tab == 0) ...[
              Row(
                children: [
                  Expanded(child: _dirPill(l10n.berdim, true)),
                  const SizedBox(width: 10),
                  Expanded(child: _dirPill(l10n.oldim, false)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Nom inputi
            TextField(
              controller: _nameCtrl,
              cursorColor: fg,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: nameHint,
                hintStyle: TextStyle(color: fg.withValues(alpha: 0.5)),
                contentPadding: const EdgeInsets.only(bottom: 6),
                enabledBorder: _border(fg, 0.35),
                focusedBorder: _border(fg, 1.0),
              ),
            ),
            const SizedBox(height: 18),
            // Maqsad (create ham, edit ham): Hozirgi balans + Maqsad puli
            if (widget.tab == 2) ...[
              miniLabel(l10n.boshlangichBalans),
              const SizedBox(height: 2),
              amountRow(_amountCtrl, 20),
              const SizedBox(height: 14),
              miniLabel(l10n.maqsadSumma),
              const SizedBox(height: 2),
              amountRow(_targetCtrl, 30),
            ] else
              // Hisob / Qarz / Maqsad-edit: oddiy katta summa
              amountRow(_amountCtrl, 30),
            // Qarz create — hisob tanlash (mini kartalar)
            if (_create && widget.tab == 0) ...[
              const SizedBox(height: 14),
              _hisobSelector(fg),
            ],
            // Rang palitrasi — ikonka fixed, ranglar chapdan o'nga scroll
            if (widget.tab != 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.palette_rounded,
                    color: fg.withValues(alpha: 0.85),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _palette.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (ctx, idx) {
                          final c = _palette[idx];
                          final selected = c.toARGB32() == _color.toARGB32();
                          final ring = _whiteCard
                              ? Colors.black54
                              : Colors.white;
                          return Center(
                            child: GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? ring
                                        : Colors.white.withValues(alpha: 0.4),
                                    width: selected ? 3 : 1,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            // Bekor (faqat create) + galochka (saqlash)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_create) ...[
                  _circleBtn(
                    Icons.close_rounded,
                    widget.onDone,
                    primary: false,
                  ),
                  const SizedBox(width: 12),
                ],
                _circleBtn(Icons.check_rounded, _save, primary: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── O'chirishni tasdiqlash kartasi ────────────────────────────────────
class _DeleteOverlayCard extends StatelessWidget {
  final int tab;
  final Object item;
  final VoidCallback onDone;
  const _DeleteOverlayCard({
    super.key,
    required this.tab,
    required this.item,
    required this.onDone,
  });

  void _confirm(BuildContext context) {
    switch (tab) {
      case 0:
        context.read<QarzCubit>().deleteQarz(item as QarzModel);
      case 2:
        context.read<MaqsadCubit>().deleteMaqsad(item as MaqsadModel);
      default:
        context.read<HisobCubit>().deleteHisob(item as HisobModel);
    }
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String name;
    switch (tab) {
      case 0:
        final q = item as QarzModel;
        color = q.isQarzBerdim ? _qarzGreen : _qarzRed;
        name = q.personName;
      case 2:
        final m = item as MaqsadModel;
        color = m.color;
        name = m.name;
      default:
        final h = item as HisobModel;
        color = h.color;
        name = h.name;
    }
    // Delete kartasi har doim rangli (oq emas) — tugmalar oq glass bo'lib,
    // barcha tablarda bir xil ko'rinishi uchun.
    const fg = Colors.white;
    final l10n = context.l10n;
    final message = tab == 2
        ? '${l10n.tasdiqOchirish} ${l10n.taslimBolma}'
        : '${l10n.tasdiqOchirish} ${l10n.umumiyBalansaTasir}';

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: fg, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: fg.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _GlassBtn(icon: Icons.close_rounded, onTap: onDone),
                const SizedBox(width: 12),
                _GlassBtn(
                  icon: Icons.check_rounded,
                  onTap: () => _confirm(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Qarz tarixi (history) sheet — rangli fon, oq yozuv ────────────────
class _HistEntry {
  final String label;
  final double amount;
  final int ts;
  final bool isInitial;
  const _HistEntry({
    required this.label,
    required this.amount,
    required this.ts,
    required this.isInitial,
  });
}

class _QarzHistorySheet extends StatelessWidget {
  final QarzModel qarz;
  const _QarzHistorySheet({required this.qarz});

  String _dateFmt(BuildContext context, int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    final oylar = context.l10n.oylarQisqa;
    return '${d.day} ${oylar[d.month - 1]} ${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final color = qarz.isQarzBerdim ? _qarzGreen : _qarzRed;
    final berdim = qarz.isQarzBerdim;
    final l10n = context.l10n;

    final entries = <_HistEntry>[
      _HistEntry(
        label: berdim ? l10n.berdim : l10n.oldim,
        amount: double.tryParse(qarz.amount) ?? 0,
        ts: qarz.timestamp,
        isInitial: true,
      ),
      ...qarz.tolovlar.map(
        (t) => _HistEntry(
          label: berdim ? l10n.qaytarildi : l10n.tolangan2,
          amount: double.tryParse(t.amount) ?? 0,
          ts: t.timestamp,
          isInitial: false,
        ),
      ),
    ]..sort((a, b) => b.ts.compareTo(a.ts));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    berdim
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    qarz.personName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final e = entries[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          e.isInitial
                              ? Icons.account_balance_wallet_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _dateFmt(context, e.ts),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${appFmt(e.amount, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bajarilgan maqsadlar arxivi ───────────────────────────────────────
class BajarilganMaqsadlarScreen extends StatelessWidget {
  const BajarilganMaqsadlarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.bajarilganMaqsadlar,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<MaqsadCubit, MaqsadState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final bajarilganlar =
              state.maqsadlar.where((m) => m.bajarilgan).toList()
                ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

          if (bajarilganlar.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.bajarilganMaqsadYoq,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.maqsadgaOlga,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _qarzGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: bajarilganlar.length,
            itemBuilder: (ctx, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  height: _cardH,
                  child: _MaqsadCard(
                    maqsad: bajarilganlar[i],
                    allMaqsadlar: bajarilganlar,
                    stackExpanded: false,
                    onEdit: (_) {},
                    onDelete: (_) {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Bitgan (to'langan) qarzlar arxivi ─────────────────────────────────
class BajarilganQarzlarScreen extends StatelessWidget {
  const BajarilganQarzlarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.yopilganQarzlar,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<QarzCubit, QarzState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final bitganlar = state.qarzlar.where((q) => q.bajarilgan).toList()
            ..sort((a, b) => b.bitganSana.compareTo(a.bitganSana));

          if (bitganlar.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.yopilganQarzYoq,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.qarzsizHayot,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _qarzGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: bitganlar.length,
            itemBuilder: (ctx, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  height: _cardH,
                  child: _QarzCard(
                    qarz: bitganlar[i],
                    stackExpanded: false,
                    onEdit: (_) {},
                    onDelete: (_) {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tutorial: swipe qo'lchasi (qayerdan surish kerakligini ko'rsatadi) ─
class _SwipeHandController {
  _SwipeHandState? _state;
  Future<void> korsat({required bool ongga}) async {
    final s = _state;
    if (s == null) return;
    await s.oynat(ongga);
  }
}

class _SwipeHand extends StatefulWidget {
  final _SwipeHandController controller;
  const _SwipeHand({required this.controller});

  @override
  State<_SwipeHand> createState() => _SwipeHandState();
}

class _SwipeHandState extends State<_SwipeHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _ongga = true;
  bool _korinadi = false;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    widget.controller._state = null;
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> oynat(bool ongga) async {
    if (!mounted) return;
    setState(() {
      _ongga = ongga;
      _korinadi = true;
    });
    await _ctrl.forward(from: 0);
    if (mounted) setState(() => _korinadi = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_korinadi) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);
          final start = _ongga ? size.width * 0.22 : size.width * 0.78;
          final end = _ongga ? size.width * 0.78 : size.width * 0.22;
          final x = start + (end - start) * t;
          // Boshida paydo bo'lib, oxirida so'nadi
          final opacity = t < 0.15
              ? t / 0.15
              : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
          return Stack(
            children: [
              Positioned(
                left: x - 26,
                top: size.height * 0.38,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: const Text('👆', style: TextStyle(fontSize: 46)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
