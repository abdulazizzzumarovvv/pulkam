import 'package:flutter/material.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/hisob_cubit.dart';
import '../data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_screen.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/color_picker_screen.dart';

class HisobAdd extends StatefulWidget {
  final HisobModel? hisobToEdit;
  const HisobAdd({super.key, this.hisobToEdit});

  @override
  State<HisobAdd> createState() => _HisobAddState();
}

class _HisobAddState extends State<HisobAdd> {
  String _balance = '0';
  late TextEditingController _nameController;
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
        onConfirm: (value) => setState(() => _balance = value),
      ),
    );
  }

  Future<void> _openIconPicker() async {
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
  }

  void _aiIconRang() {
    setState(() {
      _selectedIcon = IconPickerScreen.randomIcon();
      _selectedColor = ColorPickerScreen.randomColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi Hisob'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Hisob nomini kiriting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openIconPicker,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Icon tanlang',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child:
                          Icon(_selectedIcon, size: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _aiIconRang,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF6C3CE1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI orqali icon va rang tanlash',
                      style: TextStyle(
                        color: Color(0xFF6C3CE1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                      const Text('Hozirgi balans'),
                      Text('$_balance UZS',
                          style: const TextStyle(color: Colors.grey)),
                    ],
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
                  name: _nameController.text.trim(),
                  balance: _balance,
                  iconCode: _selectedIcon.codePoint,
                  colorValue: _selectedColor.toARGB32(),
                );
                if (widget.hisobToEdit != null) {
                  context.read<HisobCubit>().updateHisob(
                        widget.hisobToEdit!, newHisob);
                } else {
                  context.read<HisobCubit>().addHisob(newHisob);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
