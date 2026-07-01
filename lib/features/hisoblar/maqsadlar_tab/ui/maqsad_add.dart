import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/calculator_sheet.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/data/maqsad_model.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_screen.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/color_picker_screen.dart';

class MaqsadAdd extends StatefulWidget {
  final MaqsadModel? maqsadToEdit;
  const MaqsadAdd({super.key, this.maqsadToEdit});

  @override
  State<MaqsadAdd> createState() => _MaqsadAddState();
}

class _MaqsadAddState extends State<MaqsadAdd> {
  String _balance = '0';
  String _target = '0';
  late TextEditingController _nameController;
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
    _selectedIcon = widget.maqsadToEdit?.icon ?? Icons.add_card_outlined;
    _selectedColor = widget.maqsadToEdit?.color ?? Colors.grey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: Text(
          widget.maqsadToEdit != null ? 'Maqsadni tahrirlash' : 'Yangi Maqsad',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Maqsad nomini kiriting',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                      child: Icon(_selectedIcon, size: 24, color: Colors.white),
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
              onTap: () => _openCalculator(
                  onConfirm: (v) => setState(() => _balance = v)),
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
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openCalculator(
                  onConfirm: (v) => setState(() => _target = v)),
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
                      const Text('Maqsad puli'),
                      Text('$_target UZS',
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
                      content: Text('Iltimos, maqsad nomini kiriting!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final newMaqsad = MaqsadModel(
                  name: _nameController.text.trim(),
                  balance: _balance,
                  target: _target,
                  iconCode: _selectedIcon.codePoint,
                  colorValue: _selectedColor.toARGB32(),
                );
                if (widget.maqsadToEdit != null) {
                  context.read<MaqsadCubit>().updateMaqsad(
                        widget.maqsadToEdit!, newMaqsad);
                } else {
                  context.read<MaqsadCubit>().addMaqsad(newMaqsad);
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
