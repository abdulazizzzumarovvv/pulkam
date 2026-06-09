import 'package:flutter/material.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/hisob_cubit.dart';
import '../data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';

class HisobAdd extends StatefulWidget {
  final HisobModel? hisobToEdit;
  const HisobAdd({super.key, this.hisobToEdit});

  @override
  State<HisobAdd> createState() => _HisobAddState();
}

class _HisobAddState extends State<HisobAdd> {
  String _balance = '0';
  TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.add_card_outlined;
  Color _selectedColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.hisobToEdit?.name ?? '',
    );
    _selectedIcon = widget.hisobToEdit?.icon ?? Icons.add_card_outlined;
    _selectedColor = widget.hisobToEdit?.color ?? Colors.grey;
    _balance = widget.hisobToEdit?.balance ?? '0';
  }

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
        onConfirm: (value) {
          setState(() => _balance = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi Hisob'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Hisob nomini kiriting',
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
              onTap: () {
                _openCalculator();
              },
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Iltimos, hisob nomini kiriting!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newHisob = HisobModel(
                  name: _nameController.text,
                  balance: _balance,
                  icon: _selectedIcon,
                  color: _selectedColor,
                );

                if (widget.hisobToEdit != null) {
                  context.read<HisobCubit>().updateHisob(
                    widget.hisobToEdit!,
                    newHisob,
                  );
                } else {
                  context.read<HisobCubit>().addHisob(newHisob);
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
