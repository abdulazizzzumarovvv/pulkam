import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pulkam/l10n.dart';
import '../logic/qarz_cubit.dart';
import '../data/qarz_model.dart';
import 'qarz_add.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';

class QarzlarTab extends StatelessWidget {
  const QarzlarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QarzCubit, QarzState>(
      builder: (context, state) {
        final total = state.qarzlar.fold(
            0.0, (sum, q) => sum + (double.tryParse(q.amount) ?? 0));

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.qarzlar,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${appFmt(total, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    ...state.qarzlar.map((q) => _QarzCard(qarz: q)),
                    const SizedBox(height: 8),
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(12),
                        color: Colors.grey[400]!,
                        dashPattern: const [10, 5],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                          value: context.read<QarzCubit>()),
                                      BlocProvider.value(
                                          value: context.read<HisobCubit>()),
                                      BlocProvider.value(
                                          value: context.read<AmalCubit>()),
                                    ],
                                    child: const QarzAdd(),
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.green, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(context.l10n.yangiQarz),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QarzCard extends StatefulWidget {
  final QarzModel qarz;
  const _QarzCard({required this.qarz});

  @override
  State<_QarzCard> createState() => _QarzCardState();
}

class _QarzCardState extends State<_QarzCard> {
  bool _expanded = false;

  void _tolovQoshish() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TolovSheet(
        qarz: widget.qarz,
        qarzCubit: context.read<QarzCubit>(),
        hisobCubit: context.read<HisobCubit>(),
        amalCubit: context.read<AmalCubit>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.qarz;
    final color = q.isQarzBerdim ? Colors.green : Colors.red;
    final icon = q.isQarzBerdim ? Icons.arrow_upward : Icons.arrow_downward;
    final progressPct = (q.progress * 100).toStringAsFixed(0);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.personName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${appFmt(double.tryParse(q.amount) ?? 0, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
                                style:
                                    TextStyle(color: color, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text('$progressPct%',
                          style: TextStyle(color: color, fontSize: 13)),
                      const SizedBox(width: 8),
                      Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: q.progress,
                    minHeight: 3,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_expanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _DetailRow(
                          label: context.l10n.asosiySumma,
                          value: '${appFmt(double.tryParse(q.amount) ?? 0, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}'),
                      _DetailRow(
                          label: context.l10n.tolangan2,
                          value: '${appFmt(double.tryParse(q.paid) ?? 0, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}'),
                      _DetailRow(
                          label: context.l10n.qolgan,
                          value: '${appFmt(q.remaining, context.read<SozlamalarCubit>().state.formatKod)} ${context.read<SozlamalarCubit>().state.valyutaKod}',
                          valueColor: color),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _tolovQoshish,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.l10n.tolovQoshish),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<QarzCubit>().deleteQarz(q);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(context.l10n.ochirish),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TolovSheet extends StatefulWidget {
  final QarzModel qarz;
  final QarzCubit qarzCubit;
  final HisobCubit hisobCubit;
  final AmalCubit amalCubit;

  const _TolovSheet({
    required this.qarz,
    required this.qarzCubit,
    required this.hisobCubit,
    required this.amalCubit,
  });

  @override
  State<_TolovSheet> createState() => _TolovSheetState();
}

class _TolovSheetState extends State<_TolovSheet> {
  String _amount = '0';

  void _openCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalculatorSheet(
        currency: 'UZS',
        onConfirm: (v) => setState(() => _amount = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text("${context.l10n.tolovQoshish} — ${widget.qarz.personName}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          InkWell(
            onTap: _openCalculator,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.summaKiriting),
                    Text('$_amount UZS',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(_amount) ?? 0;
              if (amt <= 0) return;
              widget.qarzCubit.addTolov(widget.qarz, _amount);

              // Hisob balansini yangilash
              final hisoblar = widget.hisobCubit.state.hisoblar;
              final hisob = hisoblar
                  .where((h) => h.name == widget.qarz.hisobName)
                  .firstOrNull;
              if (hisob != null) {
                final old = double.tryParse(hisob.balance) ?? 0;
                final newBal = widget.qarz.isQarzBerdim
                    ? old + amt
                    : old - amt;
                widget.hisobCubit.updateBalance(
                    hisob, newBal.toStringAsFixed(2));
              }

              widget.amalCubit.addAmal(AmalModel(
                kategoriyaName: widget.qarz.isQarzBerdim
                    ? 'Qarz qaytarildi'
                    : 'Qarz to\'landi',
                amount: amt.toStringAsFixed(2),
                kategoriyaIconCode: Icons.sync_alt.codePoint,
                kategoriyaColorValue: Colors.blue.toARGB32(),
                hisobName: widget.qarz.hisobName,
                isKirim: widget.qarz.isQarzBerdim,
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ));

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.l10n.saqlash),
          ),
        ],
      ),
    );
  }
}
