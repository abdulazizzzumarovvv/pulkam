import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/kategoriya_model.dart';
import '../../hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import '../../hisoblar/hisoblar_tab/data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';

class OperatsiyaSheet extends StatefulWidget {
  final KategoriyaModel kategoriya;

  const OperatsiyaSheet({super.key, required this.kategoriya});

  @override
  State<OperatsiyaSheet> createState() => _OperatsiyaSheetState();
}

class _OperatsiyaSheetState extends State<OperatsiyaSheet> {
  String _amount = '0';
  HisobModel? _selectedHisob;

  void _openCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalculatorSheet(
        currency: 'UZS',
        onConfirm: (value) {
          setState(() => _amount = value);
        },
      ),
    );
  }

  void _saqlash() {
    if (_selectedHisob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, hisob tanlang!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, summa kiriting!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hisobBalance = double.tryParse(_selectedHisob!.balance) ?? 0;
    final isChiqim =
        widget.kategoriya.kategoriyaTuri == KategoriyaTuri.chiqim;

    if (isChiqim && amount > hisobBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hisobda yetarli mablag\' yo\'q!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newBalance =
        isChiqim ? hisobBalance - amount : hisobBalance + amount;

    context.read<HisobCubit>().updateHisob(
      _selectedHisob!,
      HisobModel(
        name: _selectedHisob!.name,
        balance: newBalance.toStringAsFixed(2),
        iconCode: _selectedHisob!.iconCode,
        colorValue: _selectedHisob!.colorValue,
      ),
    );

    context.read<AmalCubit>().addAmal(AmalModel(
      kategoriyaName: widget.kategoriya.name,
      amount: amount.toStringAsFixed(2),
      kategoriyaIconCode: widget.kategoriya.iconCode,
      kategoriyaColorValue: widget.kategoriya.colorValue,
      hisobName: _selectedHisob!.name,
      isKirim: !isChiqim,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hisoblar = context.read<HisobCubit>().state.hisoblar;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hisob',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HisobModel>(
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Tanlang',
                                style: TextStyle(fontSize: 13)),
                          ),
                          value: _selectedHisob,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          items: hisoblar.map((h) {
                            return DropdownMenuItem(
                              value: h,
                              child: Row(
                                children: [
                                  Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: h.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(h.icon, size: 16, color: h.color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(h.name,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedHisob = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategoriya',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: widget.kategoriya.color.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color:
                                    widget.kategoriya.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(widget.kategoriya.icon,
                                  size: 16, color: widget.kategoriya.color),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.kategoriya.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _openCalculator,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Summa'),
                    Text(
                      '$_amount UZS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.kategoriya.kategoriyaTuri ==
                                KategoriyaTuri.chiqim
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saqlash,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor:
                  widget.kategoriya.kategoriyaTuri == KategoriyaTuri.chiqim
                      ? Colors.red
                      : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.kategoriya.kategoriyaTuri == KategoriyaTuri.chiqim
                  ? 'Chiqim qilish'
                  : 'Kirim qilish',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
