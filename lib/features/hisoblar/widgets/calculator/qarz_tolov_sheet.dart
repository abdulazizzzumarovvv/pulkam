import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../hisoblar_tab/logic/hisob_cubit.dart';
import '../../hisoblar_tab/data/hisob_model.dart';
import '../../qarzlar_tab/logic/qarz_cubit.dart';
import '../../qarzlar_tab/data/qarz_model.dart';
import '../../../amallar/logic/amal_cubit.dart';
import '../../../amallar/data/amal_model.dart';
import 'calculator_cubit.dart';

const _qarzGreen = Color(0xFF27AE60);
const _qarzRed = Color(0xFFE74C3C);

/// Qarzga to'lov qo'shish — kalkulyatorli sheet.
/// Tepada qarz kartasi (fixed) → trending strelka → pastida hisoblar (tanlanadi).
class QarzTolovSheet extends StatefulWidget {
  final QarzModel qarz;
  final List<HisobModel> hisoblar;
  const QarzTolovSheet({super.key, required this.qarz, required this.hisoblar});

  @override
  State<QarzTolovSheet> createState() => _QarzTolovSheetState();
}

class _QarzTolovSheetState extends State<QarzTolovSheet>
    with SingleTickerProviderStateMixin {
  late final CalculatorCubit _calc;
  late final AnimationController _flash; // mablag' yetmasa sirena
  HisobModel? _selectedHisob;

  @override
  void initState() {
    super.initState();
    _calc = CalculatorCubit();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14400),
    );
    // Default: qarzning hisobi (topilsa), aks holda birinchisi
    _selectedHisob =
        widget.hisoblar
            .where((h) => h.name == widget.qarz.hisobName)
            .firstOrNull ??
        (widget.hisoblar.isNotEmpty ? widget.hisoblar.first : null);
  }

  @override
  void dispose() {
    _calc.close();
    _flash.dispose();
    super.dispose();
  }

  Color get _accent => widget.qarz.isQarzBerdim ? _qarzGreen : _qarzRed;

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
    final amount = double.tryParse(_calc.currentValue) ?? 0;
    if (_selectedHisob == null) return;
    if (amount <= 0) {
      _snack('Summa kiriting');
      return;
    }
    final berdim = widget.qarz.isQarzBerdim;
    final bal = double.tryParse(_selectedHisob!.balance) ?? 0;
    // Oldim — to'lansa hisobdan chiqadi; mablag' yetmasa sirena
    if (!berdim && amount > bal) {
      _flash.forward(from: 0);
      return;
    }

    // To'lovni qo'shish (sana bilan)
    context.read<QarzCubit>().addTolov(widget.qarz, amount.toStringAsFixed(2));
    // Hisob balansini yangilash: berdim → kirim, oldim → chiqim
    final newBal = berdim ? bal + amount : bal - amount;
    context.read<HisobCubit>().updateBalance(
      _selectedHisob!,
      newBal.toStringAsFixed(2),
    );
    // Amal qo'shish
    context.read<AmalCubit>().addAmal(
      AmalModel(
        kategoriyaName: berdim ? 'Qarz qaytarildi' : "Qarz to'landi",
        amount: amount.toStringAsFixed(2),
        // Ikonani Icons.handshake_outlined ga o'zgartirdik
        kategoriyaIconCode: Icons.handshake_outlined.codePoint,
        // berdim true bo'lsa yashil (Green), false bo'lsa qizil (Red) rang bo'ladi
        kategoriyaColorValue: berdim
            ? Colors.green.toARGB32()
            : Colors.red.toARGB32(),
        hisobName: _selectedHisob!.name,
        isKirim: berdim,
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
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "To'lov qo'shish",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Hisoblar (tanlanadi) → trending strelka → qarz (fixed)
                _hisobPicker(),
                const SizedBox(height: 6),
                Icon(
                  widget.qarz.isQarzBerdim
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: _accent,
                  size: 26,
                ),
                const SizedBox(height: 6),
                _qarzCard(),

                const SizedBox(height: 12),
                _display(state),
                const SizedBox(height: 8),
                _keypad(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Qarz kartasi (fixed) ──────────────────────────────────────────────
  Widget _qarzCard() {
    return _miniCard(
      color: _accent,
      name: widget.qarz.personName,
      balance: widget.qarz.remaining.toStringAsFixed(2),
      borderColor: Colors.white,
      strong: true,
    );
  }

  // ── Hisoblar (tanlanadigan, sirena bilan) ─────────────────────────────
  Widget _hisobPicker() {
    if (widget.hisoblar.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('Hisob yo\'q', style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                Color border;
                if (!selected) {
                  border = Colors.white.withValues(alpha: 0.0);
                } else if (_flash.isAnimating) {
                  final intensity =
                      (1 - math.cos(_flash.value * 4 * math.pi)) / 2;
                  border = Color.lerp(
                    Colors.white,
                    const Color(0xFFE74C3C),
                    intensity,
                  )!;
                } else {
                  border = Colors.white;
                }
                return _miniCard(
                  color: h.color,
                  name: h.name,
                  balance: h.balance,
                  borderColor: border,
                  strong: selected,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _miniCard({
    required Color color,
    required String name,
    required String balance,
    required Color borderColor,
    required bool strong,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 116,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: strong ? 0.5 : 0.25),
            blurRadius: strong ? 8 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
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
                  _grp(balance),
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
  }

  // ── Displey ───────────────────────────────────────────────────────────
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
          children: [
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

  // ── Klaviatura ────────────────────────────────────────────────────────
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
