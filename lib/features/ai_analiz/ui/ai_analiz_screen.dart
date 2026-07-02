import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/kategoriya/data/kategoriya_model.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';


class AiAnalizScreen extends StatefulWidget {
  const AiAnalizScreen({super.key});

  @override
  State<AiAnalizScreen> createState() => _AiAnalizScreenState();
}

class _AiAnalizScreenState extends State<AiAnalizScreen> {
  DateTime _selectedMonth = DateTime.now();
  KategoriyaTuri _tanlangan = KategoriyaTuri.chiqim;

  void _prevMonth() => setState(() =>
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1));

  void _nextMonth() => setState(() =>
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1));

  String _monthLabel(AppL10n l10n) =>
      '${l10n.oylarToliq[_selectedMonth.month - 1]} ${_selectedMonth.year}';

  @override
  Widget build(BuildContext context) {
    final hisobSum = context
        .watch<HisobCubit>()
        .state
        .hisoblar
        .fold(0.0, (s, h) => s + (double.tryParse(h.balance) ?? 0));
    final maqsadSum = context
        .watch<MaqsadCubit>()
        .state
        .maqsadlar
        .fold(0.0, (s, m) => s + (double.tryParse(m.balance) ?? 0));
    final totalSum = hisobSum + maqsadSum;
    final l10n = context.l10n;

    return BlocBuilder<AmalCubit, AmalState>(
      builder: (context, state) {
        final monthAmallar = state.amallar.where((a) {
          final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
          return dt.year == _selectedMonth.year &&
              dt.month == _selectedMonth.month;
        }).toList();

        final chiqimlar = monthAmallar.where((a) => !a.isKirim).toList();
        final kirimlar = monthAmallar.where((a) => a.isKirim).toList();

        final chiqimTotal = chiqimlar.fold(
            0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));
        final kirimTotal = kirimlar.fold(
            0.0, (s, a) => s + (double.tryParse(a.amount) ?? 0));

        final filtered =
            _tanlangan == KategoriyaTuri.chiqim ? chiqimlar : kirimlar;
        final total =
            _tanlangan == KategoriyaTuri.chiqim ? chiqimTotal : kirimTotal;

        // Kategoriyalar bo'yicha
        final Map<String, _KatInfo> katMap = {};
        for (final a in filtered) {
          katMap.putIfAbsent(
            a.kategoriyaName,
            () => _KatInfo(
              name: a.kategoriyaName,
              iconCode: a.kategoriyaIconCode,
              colorValue: a.kategoriyaColorValue,
            ),
          );
          katMap[a.kategoriyaName]!.amount +=
              double.tryParse(a.amount) ?? 0;
        }
        final katList = katMap.values.toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

        // O'rtacha
        final daysInMonth = DateTime(
                _selectedMonth.year, _selectedMonth.month + 1, 0)
            .day;
        final avgDay = chiqimTotal / daysInMonth;
        final avgWeek = chiqimTotal / (daysInMonth / 7);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Column(
              children: [
                Text(l10n.umumiyBalans,
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('${appFmt(totalSum, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.auto_awesome_outlined),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Oy tanlash
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: _prevMonth,
                        icon: const Icon(Icons.chevron_left)),
                    Text(_monthLabel(l10n),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right)),
                  ],
                ),

                // Chiqim / Kirim toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _ToggleBtn(
                        label: l10n.chiqim,
                        amount: chiqimTotal,
                        isSelected:
                            _tanlangan == KategoriyaTuri.chiqim,
                        color: Colors.red,
                        onTap: () => setState(
                            () => _tanlangan = KategoriyaTuri.chiqim),
                      ),
                      _ToggleBtn(
                        label: l10n.kirim,
                        amount: kirimTotal,
                        isSelected:
                            _tanlangan == KategoriyaTuri.kirim,
                        color: Colors.green,
                        onTap: () => setState(
                            () => _tanlangan = KategoriyaTuri.kirim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // O'rtacha xarajat
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.ortachaXarajat,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _AvgRow(
                          icon: Icons.calendar_today,
                          label: l10n.birKunda,
                          value: avgDay),
                      const Divider(height: 16),
                      _AvgRow(
                          icon: Icons.calendar_today,
                          label: l10n.birHaftada,
                          value: avgWeek),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Donut chart
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: total <= 0
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.monetization_on_outlined,
                                        size: 48,
                                        color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(l10n.malumotYoq,
                                        style: TextStyle(
                                            color: Colors.grey[400])),
                                  ],
                                ),
                              )
                            : CustomPaint(
                                painter: _DonutPainter(
                                  sections: katList
                                      .map((k) => _DonutSection(
                                            color: Color(k.colorValue),
                                            value: k.amount / total,
                                          ))
                                      .toList(),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.monetization_on_outlined,
                                          size: 32,
                                          color: Colors.grey[400]),
                                      Text(l10n.malumotYoq,
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      ...katList.map(
                        (k) => _KatRow(info: k, total: total),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('${appFmt(amount, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvgRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _AvgRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.red, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text('${appFmt(value, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _KatInfo {
  final String name;
  final int iconCode;
  final int colorValue;
  double amount = 0;

  _KatInfo(
      {required this.name,
      required this.iconCode,
      required this.colorValue});
}

class _KatRow extends StatelessWidget {
  final _KatInfo info;
  final double total;

  const _KatRow({required this.info, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (info.amount / total * 100) : 0.0;
    final color = Color(info.colorValue);
    final icon = IconData(info.iconCode, fontFamily: 'MaterialIcons');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(info.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w500)),
                    Text('${pct.toStringAsFixed(1)} %',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutSection {
  final Color color;
  final double value;
  const _DonutSection({required this.color, required this.value});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSection> sections;
  _DonutPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 40.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    for (final s in sections) {
      final sweepAngle = s.value * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.02,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}
