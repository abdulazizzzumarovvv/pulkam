import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/data/maqsad_model.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';

class MaqsadAdd extends StatefulWidget {
  final MaqsadModel? maqsadToEdit;
  const MaqsadAdd({super.key, this.maqsadToEdit});

  @override
  State<MaqsadAdd> createState() => _MaqsadAddState();
}

class _MaqsadAddState extends State<MaqsadAdd> {
  String _balance = '0';
  String _target = '0';
  TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.add_card_outlined;
  Color _selectedColor = Colors.grey;

  void _openCalculator({required Function(String) onConfirm}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalculatorSheet(currency: 'UZS', onConfirm: onConfirm),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.maqsadToEdit?.name ?? '',
    );
    _balance = widget.maqsadToEdit?.balance ?? '0';
    _target = widget.maqsadToEdit?.target ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.maqsadToEdit != null ? 'Maqsadni tahrirlash' : 'Yangi Maqsad',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Maqsad nomini kiriting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => const IconPickerDialog(),
                );
                if (result != null) {
                  setState(() {
                    _selectedIcon = result['icon'] as IconData;
                    _selectedColor = result['color'] as Color;
                  });
                }
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Icon tanlang'),
                    ),
                    Container(
                      height: 60,
                      width: 55,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Icon(_selectedIcon, size: 25, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _openCalculator(
                onConfirm: (value) => setState(() => _balance = value),
              ),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Hozirgi balans'), Text(_balance + ' UZS')],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _openCalculator(
                onConfirm: (value) => setState(() => _target = value),
              ),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Maqsad puli'), Text('$_target UZS')],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Iltimos, maqsad nomini kiriting!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newMaqsad = MaqsadModel(
                  name: _nameController.text,
                  balance: _balance,
                  target: _target,
                  icon: Icons.flag_outlined,
                );

                if (widget.maqsadToEdit != null) {
                  context.read<MaqsadCubit>().updateMaqsad(
                    widget.maqsadToEdit!,
                    newMaqsad,
                  );
                } else {
                  context.read<MaqsadCubit>().addMaqsad(newMaqsad);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
