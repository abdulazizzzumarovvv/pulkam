import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

const _kSubtext = Color(0xFF8A88A0);
const _base = 24000;


String _fmtShort(double v) {
  if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}


DateTime _p2m(int p) {
  final t = p - _base;
  return DateTime(2000 + t ~/ 12, t % 12 + 1);
}

int _nowPage() {
  final now = DateTime.now();
  return _base + (now.year - 2000) * 12 + (now.month - 1);
}

// ── Statistika sahifasi ───────────────────────────────────────────────
class Kategoriya extends StatelessWidget {
  const Kategoriya({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), kBg);
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.statistika,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: const _StatsBody(),
    );
  }
}

// ── Asosiy tana ───────────────────────────────────────────────────────
class _StatsBody extends StatefulWidget {
  const _StatsBody();

  @override
  State<_StatsBody> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<_StatsBody> {
  late PageController _monthCtrl;
  late PageController _contentCtrl;
  late int _page;
  bool _syncing = false;
  bool _isChiqim = true; // default chiqim

  @override
  void initState() {
    super.initState();
    _page = _nowPage();
    _monthCtrl = PageController(initialPage: _page, viewportFraction: 0.33);
    _contentCtrl = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onMonth(int p) {
    if (_syncing) return;
    _syncing = true;
    setState(() => _page = p);
    if (_contentCtrl.hasClients) _contentCtrl.jumpToPage(p);
    Future.microtask(() => _syncing = false);
  }

  void _onContent(int p) {
    if (_syncing) return;
    _syncing = true;
    setState(() => _page = p);
    if (_monthCtrl.hasClients) _monthCtrl.jumpToPage(p);
    Future.microtask(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Oy carousel ──────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: PageView.builder(
            controller: _monthCtrl,
            onPageChanged: _onMonth,
            itemBuilder: (_, page) {
              final sel = page == _page;
              final m = _p2m(page);
              return GestureDetector(
                onTap: () => _monthCtrl.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Center(
                  child: Text(
                    context.l10n.oylarToliq[m.month - 1],
                    style: TextStyle(
                      fontSize: sel ? 17 : 14,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                      color: sel
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 14),

        // ── Kirim / Chiqim toggle ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _KirimChiqimToggle(
            isChiqim: _isChiqim,
            month: _p2m(_page),
            onChanged: (v) => setState(() => _isChiqim = v),
          ),
        ),
        const SizedBox(height: 14),

        // ── Kontent (scroll) ─────────────────────────────────────────
        Expanded(
          child: PageView.builder(
            controller: _contentCtrl,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _onContent,
            itemBuilder: (_, page) =>
                _StatsPage(month: _p2m(page), isChiqim: _isChiqim),
          ),
        ),
      ],
    );
  }
}

// ── Kirim / Chiqim toggle: ikkiga bo'lingan, border, bosilganda filled ─
class _KirimChiqimToggle extends StatelessWidget {
  final bool isChiqim;
  final DateTime month;
  final ValueChanged<bool> onChanged;

  const _KirimChiqimToggle({
    required this.isChiqim,
    required this.month,
    required this.onChanged,
  });

  static const _red = Color(0xFFE74C3C);
  static const _green = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amallar = context.watch<AmalCubit>().state.amallar.where((a) {
      final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
      return dt.year == month.year && dt.month == month.month;
    }).toList();

    final oylikKirim = amallar
        .where((a) => a.isKirim)
        .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));
    final oylikChiqim = amallar
        .where((a) => !a.isKirim)
        .fold(0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));

    Widget half({
      required bool chiqim,
      required double amount,
      required Color color,
      required String label,
      required bool isLeft,
    }) {
      final selected = isChiqim == chiqim;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(chiqim),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isLeft ? 14 : 0),
                bottomLeft: Radius.circular(isLeft ? 14 : 0),
                topRight: Radius.circular(isLeft ? 0 : 14),
                bottomRight: Radius.circular(isLeft ? 0 : 14),
              ),
              border: Border.all(
                color: selected ? color : color.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.9)
                        : color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.2)
                            : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        context.watch<SozlamalarCubit>().state.valyutaKod,
                        style: TextStyle(
                          color: selected ? Colors.white : color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          appFmt(amount, context.read<SozlamalarCubit>().state.formatKod),
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        half(
          chiqim: true,
          amount: oylikChiqim,
          color: _red,
          label: l10n.oylikChiqim,
          isLeft: true,
        ),
        half(
          chiqim: false,
          amount: oylikKirim,
          color: _green,
          label: l10n.oylikKirim,
          isLeft: false,
        ),
      ],
    );
  }
}

// ── Kategoriya aggregatsiyasi ─────────────────────────────────────────
class _CatAgg {
  final String name;
  double amount;
  final int icon;
  final int color;
  _CatAgg({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

// ── Bitta oy statistikasi ─────────────────────────────────────────────
class _StatsPage extends StatelessWidget {
  final DateTime month;
  final bool isChiqim;
  const _StatsPage({required this.month, required this.isChiqim});

  static const _red = Color(0xFFE74C3C);
  static const _green = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kBg = context.watch<SozlamalarCubit>().state.mavzuRang;
    final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), kBg);
    final amallar = context.watch<AmalCubit>().state.amallar.where((a) {
      final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
      return dt.year == month.year &&
          dt.month == month.month &&
          a.isKirim == !isChiqim;
    }).toList();

    if (amallar.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.malumotYoq,
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    // Kategoriya bo'yicha yig'ish
    final Set<int> days = {};
    final Map<String, _CatAgg> cats = {};
    double total = 0;

    for (final a in amallar) {
      final amt = double.tryParse(a.amount) ?? 0;
      total += amt;
      days.add(DateTime.fromMillisecondsSinceEpoch(a.timestamp).day);
      final cur = cats[a.kategoriyaName];
      if (cur == null) {
        cats[a.kategoriyaName] = _CatAgg(
          name: a.kategoriyaName,
          amount: amt,
          icon: a.kategoriyaIconCode,
          color: a.kategoriyaColorValue,
        );
      } else {
        cur.amount += amt;
      }
    }

    final avgDaily = days.isEmpty ? 0.0 : total / days.length;
    final catList = cats.values.toList()
      ..sort((x, y) => y.amount.compareTo(x.amount));
    final segments = catList
        .map((c) => (color: Color(c.color), value: c.amount))
        .toList();

    final accent = isChiqim ? _red : _green;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Column(
        children: [
          // ── Kunlik o'rtacha harajat/daromad ──────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.kunlikOrtacha,
                  style: TextStyle(color: _kSubtext, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _UzsBadge(context),
                    const SizedBox(width: 8),
                    Text(
                      appFmt(avgDaily, context.read<SozlamalarCubit>().state.formatKod),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Pie chart ─────────────────────────────────────────────
          SizedBox(
            height: 210,
            width: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(210, 210),
                  painter: _DonutPainter(segments: segments),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmtShort(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.watch<SozlamalarCubit>().state.valyutaKod,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Kategoriya konteynerlari ───────────────────────────────
          ...catList.map((c) => _CatTile(cat: c, total: total, accent: accent)),
        ],
      ),
    );
  }

  Widget _UzsBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.watch<SozlamalarCubit>().state.valyutaKod,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Kategoriya tile (kunlik konteyner stilida) ────────────────────────
class _CatTile extends StatelessWidget {
  final _CatAgg cat;
  final double total;
  final Color accent;

  const _CatTile({
    required this.cat,
    required this.total,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final kBg = context.read<SozlamalarCubit>().state.mavzuRang;
    final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), kBg);
    final color = Color(cat.color);
    final icon = IconData(cat.icon, fontFamily: 'MaterialIcons');
    final frac = total > 0 ? (cat.amount / total).clamp(0.0, 1.0) : 0.0;
    final pct = (frac * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.defaultKatNom(cat.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.watch<SozlamalarCubit>().state.valyutaKod,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    appFmt(cat.amount, context.read<SozlamalarCubit>().state.formatKod),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pct%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Donut painter ─────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<({Color color, double value})> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    const strokeW = 22.0; // ingichkaroq — pill shakl aniqroq ko'rinadi
    final radius = min(size.width, size.height) / 2 - strokeW / 2 - 4;
    const gap = 0.28; // katta gap — pilllar bir-biridan aniq ajraladi

    final total = segments.fold(0.0, (s, e) => s + e.value);
    if (total == 0) return;
    final totalGap = gap * segments.length;
    double start = -pi / 2;

    for (final seg in segments) {
      final sweep = (seg.value / total) * (2 * pi - totalGap);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
