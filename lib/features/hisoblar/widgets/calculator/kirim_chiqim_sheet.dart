import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../hisoblar_tab/logic/hisob_cubit.dart';
import '../../hisoblar_tab/data/hisob_model.dart';
import '../../../kategoriya/logic/kategoriya_cubit.dart';
import '../../../kategoriya/data/kategoriya_model.dart';
import '../../../kategoriya/ui/kategoriya_quick_add_dialog.dart';
import '../../../amallar/logic/amal_cubit.dart';
import '../../../amallar/data/amal_model.dart';
import 'calculator_cubit.dart';

/// Kirim/chiqim kalkulyatorli sheet.
/// Hisob kartasidagi ↕ yoki Home "+ Umumiy balans" tugmasidan ochiladi.
/// hisob = null bo'lsa, ro'yxatdagi birinchi hisob default tanlangan bo'ladi.
class KirimChiqimSheet extends StatefulWidget {
  final HisobModel? hisob; // null = birinchi hisobni auto-tanlash
  const KirimChiqimSheet({super.key, this.hisob});

  @override
  State<KirimChiqimSheet> createState() => _KirimChiqimSheetState();
}

class _KirimChiqimSheetState extends State<KirimChiqimSheet>
    with SingleTickerProviderStateMixin {
  late final CalculatorCubit _calc;
  late final AnimationController _flash; // chiqimda mablag' yetmasa sirena
  bool _isChiqim = true; // default chiqim
  HisobModel? _selectedHisob; // initState yoki birinchi build'da to'ldiriladi
  KategoriyaModel? _selectedKat;
  Object? _shakingKatKey; // long-press: qaysi kategoriya edit rejimida

  static const _green = Color(0xFF27AE60);
  static const _red = Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _calc = CalculatorCubit();
    _selectedHisob = widget.hisob; // null bo'lsa build'da birinchisi tanlanadi
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14400),
    );
  }

  @override
  void dispose() {
    _calc.close();
    _flash.dispose();
    super.dispose();
  }

  Color get _accent => _isChiqim ? _red : _green;

  // ── raqam formatlash (mingliklarni ajratish) ──────────────────────────
  String _grp(String s) {
    if (s.isEmpty) return s;
    final neg = s.startsWith('-');
    final body = neg ? s.substring(1) : s;
    final parts = body.split('.');
    final ip = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < ip.length; i++) {
      if (i > 0 && (ip.length - i) % 3 == 0) buf.write(',');
      buf.write(ip[i]);
    }
    final res = parts.length > 1
        ? '${buf.toString()}.${parts[1]}'
        : buf.toString();
    return neg ? '-$res' : res;
  }

  String _numFmt(double v) {
    if (v == v.truncateToDouble()) return _grp(v.toInt().toString());
    return _grp(v.toStringAsFixed(2));
  }

  double? _liveResult(CalculatorState s) {
    if (s.operand == null || s.operator == null) return null;
    final b = double.tryParse(s.display) ?? 0;
    switch (s.operator) {
      case '+':
        return s.operand! + b;
      case '−':
        return s.operand! - b;
      case '×':
        return s.operand! * b;
      case '÷':
        return b == 0 ? null : s.operand! / b;
    }
    return null;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _save() {
    final h = _selectedHisob;
    if (h == null) {
      _snack('Hisob tanlang');
      return;
    }
    final amount = double.tryParse(_calc.currentValue) ?? 0;
    if (_selectedKat == null) {
      _snack('Kategoriya tanlang');
      return;
    }
    if (amount <= 0) {
      _snack('Summa kiriting');
      return;
    }
    final bal = double.tryParse(h.balance) ?? 0;
    if (_isChiqim && amount > bal) {
      _flash.forward(from: 0);
      return;
    }
    final newBal = _isChiqim ? bal - amount : bal + amount;

    context.read<HisobCubit>().updateHisob(
      h,
      HisobModel(
        name: h.name,
        balance: newBal.toStringAsFixed(2),
        iconCode: h.iconCode,
        colorValue: h.colorValue,
      ),
    );
    context.read<AmalCubit>().addAmal(
      AmalModel(
        kategoriyaName: _selectedKat!.name,
        amount: amount.toStringAsFixed(2),
        kategoriyaIconCode: _selectedKat!.iconCode,
        kategoriyaColorValue: _selectedKat!.colorValue,
        hisobName: h.name,
        isKirim: !_isChiqim,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    Navigator.pop(context);
  }

  void _onAction(CalculatorState state) {
    if (state.actionButton == ActionButtonType.equals) {
      _calc.calculate();
    } else {
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _calc,
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final hisoblar = context.watch<HisobCubit>().state.hisoblar;
          // null bo'lsa birinchi hisobni default tanlash
          if (_selectedHisob == null && hisoblar.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() => _selectedHisob = hisoblar.first),
            );
          }
          final kategoriyalar = context
              .watch<KategoriyaCubit>()
              .state
              .kategoriyalar
              .where((k) => (k.turi == 'chiqim') == _isChiqim)
              .toList();

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              // Orqaga strelka
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              // Toggle + o'ng tomonda + iconcha
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toggle(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => showKategoriyaQuickAddDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFF1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Faqat kategoriyalar scroll bo'ladi
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: _categoryGrid(context, kategoriyalar),
                    ),
                  ),
                  // Strelka + hisoblar + kalkulyator — hammasi fixed
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Icon(
                            _isChiqim
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: _accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _cardPicker(hisoblar),
                        const SizedBox(height: 10),
                        _display(state),
                        const SizedBox(height: 8),
                        _keypad(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Kirim / Chiqim toggle (yopishgan segment pill) ────────────────────
  Widget _toggle() {
    Widget seg(String label, bool chiqim) {
      final active = _isChiqim == chiqim;
      final col = chiqim ? _red : _green;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _isChiqim = chiqim;
            _selectedKat = null; // kategoriya ro'yxati o'zgaradi
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: active ? col : Colors.grey[500],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 230,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [seg('Kirim', false), seg('Chiqim', true)]),
    );
  }

  // ── Kategoriya grid (4 ustun, + tugma yo'q — AppBar'da bor) ─────────
  Widget _categoryGrid(BuildContext context, List<KategoriyaModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Kategoriya yo\'q',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 82,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final k = list[i];
        final selected = _selectedKat?.key == k.key;
        final shaking = _shakingKatKey == k.key;
        return _KatChip(
          kat: k,
          selected: selected,
          shaking: shaking,
          onTap: () {
            setState(() {
              _selectedKat = k;
              _shakingKatKey = null; // tap — edit rejimini yopadi
            });
          },
          onLongPress: () =>
              setState(() => _shakingKatKey = shaking ? null : k.key),
          onEdit: () async {
            setState(() => _shakingKatKey = null);
            await showKategoriyaQuickAddDialog(context, editing: k);
          },
          onDelete: () {
            context.read<KategoriyaCubit>().deleteKategoriya(k);
            setState(() => _shakingKatKey = null);
            if (_selectedKat?.key == k.key) {
              setState(() => _selectedKat = null);
            }
          },
        );
      },
    );
  }

  // ── Karta tanlagich (mini kartalar) ───────────────────────────────────
  Widget _cardPicker(List<HisobModel> list) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final h = list[i];
          final selected = _selectedHisob?.key == h.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedHisob = h),
            child: AnimatedBuilder(
              animation: _flash,
              builder: (_, _) {
                Color brd;
                if (!selected) {
                  brd = Colors.white.withValues(alpha: 0.0);
                } else if (_flash.isAnimating) {
                  final intensity =
                      (1 - math.cos(_flash.value * 4 * math.pi)) / 2;
                  brd = Color.lerp(
                    Colors.white,
                    const Color(0xFFE74C3C),
                    intensity,
                  )!;
                } else {
                  brd = Colors.white;
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 116,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: h.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brd, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: h.color.withValues(alpha: selected ? 0.5 : 0.25),
                        blurRadius: selected ? 8 : 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                            child: const Text(
                              'UZS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _grp(h.balance),
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

  // ── Displey (UZS badge + summa/expression + jonli natija) ─────────────
  Widget _display(CalculatorState state) {
    final live = _liveResult(state);
    final hasOp = state.operand != null && state.operator != null;
    final big = hasOp
        ? '${_numFmt(state.operand!)} ${state.operator} ${_grp(state.display)}'
        : _grp(state.display);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // UZS badge — to'q grey
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'UZS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  big,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasOp) ...[
          const SizedBox(height: 6),
          Text(
            live == null ? '= …' : '= ${_numFmt(live)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  // ── Klaviatura (och dizayn) ───────────────────────────────────────────
  Widget _keypad(BuildContext context, CalculatorState state) {
    final cubit = context.read<CalculatorCubit>();

    Widget key(
      String label, {
      VoidCallback? onTap,
      IconData? icon,
      bool op = false,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: Colors.grey[700], size: 22)
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: op
                              ? Colors.grey[500]
                              : const Color(0xFF2A2A2C),
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    Widget digit(String d) => key(d, onTap: () => cubit.inputDigit(d));

    // Action tugma — default ✓ (saqlaydi), amal bo'lsa = (hisoblaydi)
    final isEquals = state.actionButton == ActionButtonType.equals;
    final actionKey = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () => _onAction(state),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: isEquals
                  ? const Text(
                      '=',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // operatorlar + action tugma (÷ ning o'ng tomonida)
          Row(
            children: [
              key('+', onTap: () => cubit.inputOperator('+'), op: true),
              key('−', onTap: () => cubit.inputOperator('−'), op: true),
              key('×', onTap: () => cubit.inputOperator('×'), op: true),
              key('÷', onTap: () => cubit.inputOperator('÷'), op: true),
              actionKey,
            ],
          ),
          Row(children: [digit('1'), digit('2'), digit('3')]),
          Row(children: [digit('4'), digit('5'), digit('6')]),
          Row(children: [digit('7'), digit('8'), digit('9')]),
          Row(
            children: [
              key('.', onTap: cubit.inputDot),
              digit('0'),
              key('', onTap: cubit.backspace, icon: Icons.backspace_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Kategoriya chip: tap=tanlash, long-press=silkinish+edit/delete ─────
class _KatChip extends StatefulWidget {
  final KategoriyaModel kat;
  final bool selected;
  final bool shaking;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KatChip({
    required this.kat,
    required this.selected,
    required this.shaking,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_KatChip> createState() => _KatChipState();
}

class _KatChipState extends State<_KatChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(_KatChip old) {
    super.didUpdateWidget(old);
    if (widget.shaking && !old.shaking) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.shaking && old.shaking) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kat;
    final sel = widget.selected;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Mini edit icon (chap tomonda)
              if (widget.shaking)
                Positioned(
                  left: -20,
                  top: 7,
                  child: InkWell(
                    onTap: widget.onEdit,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C3CE1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),

              // Asosiy dumaloq (silkinish bilan)
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) => Transform.translate(
                  offset: Offset(widget.shaking ? _shake.value : 0, 0),
                  child: child,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: sel ? k.color : k.color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: sel ? Border.all(color: k.color, width: 2.5) : null,
                  ),
                  child: Icon(
                    k.icon,
                    color: sel ? Colors.white : k.color,
                    size: 24,
                  ),
                ),
              ),

              // Mini delete icon (o'ng tomonda)
              if (widget.shaking)
                Positioned(
                  right: -20,
                  top: 7,
                  child: InkWell(
                    onTap: widget.onDelete,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            k.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: sel ? Colors.black87 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
