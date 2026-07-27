import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/kategoriya_cubit.dart';
import '../data/kategoriya_model.dart';
import 'package:pulkam/l10n.dart';

// ── icon_picker_screen.dart'dagi ikonlar (guruhlar bilan) ─────────────
const _kIconGroups = <String, List<IconData>>{
  'umumiy': [
    Icons.star_outline,
    Icons.favorite_outline,
    Icons.home_outlined,
    Icons.work_outline,
    Icons.flag_outlined,
    Icons.bookmark_outline,
    Icons.calendar_today_outlined,
    Icons.alarm,
    Icons.settings_outlined,
    Icons.notifications_outlined,
  ],
  'moliya': [
    Icons.account_balance_wallet_outlined,
    Icons.credit_card_outlined,
    Icons.money,
    Icons.savings_outlined,
    Icons.attach_money,
    Icons.currency_exchange,
    Icons.payment_outlined,
    Icons.receipt_outlined,
    Icons.trending_up,
    Icons.bar_chart,
  ],
  'oziq_ovqat': [
    Icons.restaurant_outlined,
    Icons.fastfood_outlined,
    Icons.coffee_outlined,
    Icons.local_pizza_outlined,
    Icons.cake_outlined,
    Icons.lunch_dining,
    Icons.dinner_dining,
    Icons.local_cafe_outlined,
    Icons.wine_bar_outlined,
    Icons.bakery_dining,
  ],
  'transport': [
    Icons.directions_car_outlined,
    Icons.flight_outlined,
    Icons.directions_bus_outlined,
    Icons.train_outlined,
    Icons.directions_bike_outlined,
    Icons.local_taxi_outlined,
    Icons.motorcycle_outlined,
    Icons.electric_car_outlined,
    Icons.directions_walk,
    Icons.local_shipping_outlined,
  ],
  'salomatlik': [
    Icons.fitness_center_outlined,
    Icons.medical_services_outlined,
    Icons.local_hospital_outlined,
    Icons.sports_gymnastics,
    Icons.self_improvement,
    Icons.spa_outlined,
    Icons.healing_outlined,
    Icons.monitor_heart_outlined,
    Icons.medication_outlined,
    Icons.psychology_outlined,
  ],
  'talim': [
    Icons.school_outlined,
    Icons.menu_book_outlined,
    Icons.science_outlined,
    Icons.computer_outlined,
    Icons.brush_outlined,
    Icons.music_note_outlined,
    Icons.sports_soccer_outlined,
    Icons.videogame_asset_outlined,
    Icons.language_outlined,
    Icons.calculate_outlined,
  ],
};

// ── color_picker_screen.dart'dagi ranglar (4 ustun grid) ──────────────
const _kColorGrid = <List<Color>>[
  [Color(0xFFFF6B6B), Color(0xFFFF5252), Color(0xFFFF1744), Color(0xFFD50000)],
  [Color(0xFFFF8A80), Color(0xFFFF6E40), Color(0xFFFF3D00), Color(0xFFDD2C00)],
  [Color(0xFFFFAB40), Color(0xFFFF9100), Color(0xFFFF6D00), Color(0xFFE65100)],
  [Color(0xFFFFD740), Color(0xFFFFAB00), Color(0xFFFF6F00), Color(0xFFF57F17)],
  [Color(0xFFCCFF90), Color(0xFF69F0AE), Color(0xFF00E676), Color(0xFF00C853)],
  [Color(0xFF64FFDA), Color(0xFF1DE9B6), Color(0xFF00BFA5), Color(0xFF004D40)],
  [Color(0xFF80D8FF), Color(0xFF40C4FF), Color(0xFF0091EA), Color(0xFF01579B)],
  [Color(0xFF82B1FF), Color(0xFF448AFF), Color(0xFF2979FF), Color(0xFF2962FF)],
  [Color(0xFFB388FF), Color(0xFF7C4DFF), Color(0xFF651FFF), Color(0xFF6200EA)],
  [Color(0xFFEA80FC), Color(0xFFE040FB), Color(0xFFD500F9), Color(0xFFAA00FF)],
  [Color(0xFFFF80AB), Color(0xFFFF4081), Color(0xFFF50057), Color(0xFFC51162)],
  [Color(0xFFCFD8DC), Color(0xFF90A4AE), Color(0xFF546E7A), Color(0xFF263238)],
];

final _allIcons = _kIconGroups.values.expand((l) => l).toList();
final _allColors = _kColorGrid.expand((r) => r).toList();

/// Blur orqa fonli dialog — yangi kategoriya yoki tahrirlash.
/// [editing] berilsa — tahrirlash rejimi.
Future<void> showKategoriyaQuickAddDialog(
  BuildContext context, {
  KategoriyaModel? editing,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => _QuickAddDialog(
      kategoriyaCubit: ctx.read<KategoriyaCubit>(),
      editing: editing,
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _QuickAddDialog extends StatefulWidget {
  final KategoriyaCubit kategoriyaCubit;
  final KategoriyaModel? editing;
  const _QuickAddDialog({
    required this.kategoriyaCubit,
    this.editing,
  });

  @override
  State<_QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<_QuickAddDialog> {
  TextEditingController? _nameCtrl;
  late IconData _icon;
  late Color _color;
  late String _turi;
  bool _nameError = false;
  bool _nameCtrlReady = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _icon = e.icon;
      _color = e.color;
      _turi = e.turi;
    } else {
      final rng = Random();
      _icon = _allIcons[rng.nextInt(_allIcons.length)];
      _color = _allColors[rng.nextInt(_allColors.length)];
      _turi = 'chiqim';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nameCtrlReady) {
      _nameCtrlReady = true;
      final e = widget.editing;
      final initialText = e != null ? e.displayName(context.l10n) : '';
      _nameCtrl = TextEditingController(text: initialText);
      _nameCtrl!.addListener(() {
        if (_nameError && _nameCtrl!.text.trim().isNotEmpty) {
          setState(() => _nameError = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl?.dispose();
    super.dispose();
  }

  void _randomize() {
    final rng = Random();
    setState(() {
      _icon = _allIcons[rng.nextInt(_allIcons.length)];
      _color = _allColors[rng.nextInt(_allColors.length)];
    });
  }

  void _save() {
    final name = _nameCtrl?.text.trim() ?? '';
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final newKat = KategoriyaModel(
      name: name,
      iconCode: _icon.codePoint,
      colorValue: _color.toARGB32(),
      turi: _turi,
    );
    if (_isEditing) {
      widget.kategoriyaCubit.updateKategoriya(widget.editing!, newKat);
    } else {
      widget.kategoriyaCubit.addKategoriya(newKat);
    }
    Navigator.pop(context);
  }

  Widget _toggle() {
    Widget seg(String label, String turi) {
      final active = _turi == turi;
      final col = turi == 'chiqim'
          ? const Color(0xFFE74C3C)
          : const Color(0xFF27AE60);
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _turi = turi),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? col : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [seg(context.l10n.chiqim, 'chiqim'), seg(context.l10n.kirim, 'kirim')]),
    );
  }

// ── Ikonlar: icon_picker_screen uslubi (5 ustun, guruh sarlavhasi) ───
Widget _iconGrid() {
  return ListView(
    padding: const EdgeInsets.all(4),
    children: _kIconGroups.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.black12,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    context.l10n.ikonGuruh(entry.key),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.black38,
                      height: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black12,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 1,
                crossAxisSpacing: 5,
                mainAxisExtent: 25,
              ),
              itemCount: entry.value.length,
              itemBuilder: (_, i) {
                final icon = entry.value[i];
                final sel = _icon == icon;

                return GestureDetector(
                  onTap: () => setState(() => _icon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    decoration: BoxDecoration(
                      color: sel
                          ? _color.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: sel
                          ? Border.all(color: _color, width: 1.5)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: sel ? _color : Colors.black45,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }).toList(),
  );
}

  // ── Ranglar: color_picker_screen uslubi (4 ustun, to'rtburchak katak)
  Widget _colorGrid() {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: _kColorGrid.map((row) {
        return Row(
          children: row.map((col) {
            final sel = col.toARGB32() == _color.toARGB32();
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _color = col),
                child: Container(
                  height: 28,
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: sel
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _glassBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.26),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenH = MediaQuery.of(context).size.height;
    const gridBg = Color(0xFFF0F0F0);

    return Stack(
      children: [
        // ── Blur orqa fon ─────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),

        // ── Dialog (kichikroq: katta vertical margin) ─────────────────
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              // xato chiqqanda dialog balandligi oshadi — margin shunga moslashadi
              vertical: screenH * (_nameError ? 0.07 : 0.10),
            ),
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Header — oq card ──────────────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Column(
                        children: [
                          Text(
                            _isEditing
                                ? l10n.kategoriyaniTahrirlash
                                : l10n.yangiKategoriya,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _color.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(_icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _nameCtrl!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.kategoriyaNomi,
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              errorText: _nameError
                                  ? l10n.iltimosNomKiriting
                                  : null,
                              errorStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE74C3C),
                                fontWeight: FontWeight.w500,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.only(bottom: 6),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: _color, width: 2),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE74C3C),
                                  width: 1.5,
                                ),
                              ),
                              focusedErrorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE74C3C),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _toggle(),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),

                    // ── Ikonlar + Ranglar ─────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: gridBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _iconGrid(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: gridBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _colorGrid(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Glass tugmalar (zichroq) ───────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(22),
                          bottomRight: Radius.circular(22),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _glassBtn(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 18),
                          _glassBtn(
                            icon: Icons.shuffle_rounded,
                            onTap: _randomize,
                          ),
                          const SizedBox(width: 18),
                          _glassBtn(icon: Icons.check_rounded, onTap: _save),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}