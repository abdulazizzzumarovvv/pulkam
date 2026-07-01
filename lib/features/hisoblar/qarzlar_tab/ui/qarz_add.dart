import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/qarz_cubit.dart';
import '../data/qarz_model.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';

class QarzAdd extends StatefulWidget {
  const QarzAdd({super.key});

  @override
  State<QarzAdd> createState() => _QarzAddState();
}

class _QarzAddState extends State<QarzAdd> {
  bool _isQarzBerdim = false;
  final _nameController = TextEditingController();
  String _amount = '0';
  HisobModel? _selectedHisob;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

  Color get _activeColor => _isQarzBerdim ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    final hisoblar = context.watch<HisobCubit>().state.hisoblar;

    return Scaffold(
      appBar: AppBar(title: const Text('Yangi Qarz'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Qarz berdim / oldim toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isQarzBerdim = true),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isQarzBerdim
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: _isQarzBerdim
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward,
                                size: 18,
                                color: _isQarzBerdim
                                    ? Colors.green
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Qarz berdim',
                              style: TextStyle(
                                color: _isQarzBerdim
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isQarzBerdim = false),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: !_isQarzBerdim
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: !_isQarzBerdim
                              ? Border.all(color: Colors.red, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward,
                                size: 18,
                                color: !_isQarzBerdim
                                    ? Colors.red
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Qarz oldim',
                              style: TextStyle(
                                color: !_isQarzBerdim
                                    ? Colors.red
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Odam ismi
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Odam ismi',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Hisob dropdown
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<HisobModel>(
                    isExpanded: true,
                    value: _selectedHisob,
                    hint: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add_card_outlined,
                              size: 16, color: Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        const Text('Karta'),
                      ],
                    ),
                    items: hisoblar.map((h) {
                      return DropdownMenuItem(
                        value: h,
                        child: Row(
                          children: [
                            Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: h.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  Icon(h.icon, size: 16, color: h.color),
                            ),
                            const SizedBox(width: 10),
                            Text(h.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedHisob = v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Summa
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
                      const Text('Summa'),
                      Text('$_amount UZS',
                          style: TextStyle(
                              color: _activeColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Iltimos, odam ismini kiriting!')));
                  return;
                }
                if (_selectedHisob == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Iltimos, hisob tanlang!')));
                  return;
                }
                final amt = double.tryParse(_amount) ?? 0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Iltimos, summa kiriting!')));
                  return;
                }

                // Qarz qo'shish
                context.read<QarzCubit>().addQarz(QarzModel(
                  personName: _nameController.text.trim(),
                  amount: _amount,
                  isQarzBerdim: _isQarzBerdim,
                  hisobName: _selectedHisob!.name,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                ));

                // Hisob balansini yangilash
                final oldBal =
                    double.tryParse(_selectedHisob!.balance) ?? 0;
                final newBal = _isQarzBerdim ? oldBal - amt : oldBal + amt;
                context.read<HisobCubit>().updateBalance(
                    _selectedHisob!, newBal.toStringAsFixed(2));

                // Amal qo'shish
                context.read<AmalCubit>().addAmal(AmalModel(
                  kategoriyaName:
                      _isQarzBerdim ? 'Qarz berdim' : 'Qarz oldim',
                  amount: amt.toStringAsFixed(2),
                  kategoriyaIconCode: (_isQarzBerdim
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      .codePoint,
                  kategoriyaColorValue: _activeColor.toARGB32(),
                  hisobName: _selectedHisob!.name,
                  isKirim: !_isQarzBerdim,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                ));

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: _activeColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Saqlash',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
