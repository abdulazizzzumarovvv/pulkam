import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/kategoriya_cubit.dart';
import '../data/kategoriya_model.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_screen.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/color_picker_screen.dart';

class KategoriyaAdd extends StatefulWidget {
  final KategoriyaModel? kategoriyaToEdit;
  const KategoriyaAdd({super.key, this.kategoriyaToEdit});

  @override
  State<KategoriyaAdd> createState() => _KategoriyaAddState();
}

class _KategoriyaAddState extends State<KategoriyaAdd> {
  late TextEditingController _nameController;
  IconData _selectedIcon = Icons.star_outline;
  Color _selectedColor = Colors.grey;
  KategoriyaTuri _selectedTuri = KategoriyaTuri.chiqim;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.kategoriyaToEdit?.name ?? '',
    );
    _selectedIcon = widget.kategoriyaToEdit?.icon ?? Icons.star_outline;
    _selectedColor = widget.kategoriyaToEdit?.color ?? Colors.grey;
    _selectedTuri =
        widget.kategoriyaToEdit?.kategoriyaTuri ?? KategoriyaTuri.chiqim;
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
        title: Text(widget.kategoriyaToEdit != null
            ? 'Kategoriyani tahrirlash'
            : 'Yangi Kategoriya'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Kategoriya nomini kiriting',
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
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<KategoriyaTuri>(
                    isExpanded: true,
                    value: _selectedTuri,
                    items: const [
                      DropdownMenuItem(
                        value: KategoriyaTuri.chiqim,
                        child: Text('Chiqim'),
                      ),
                      DropdownMenuItem(
                        value: KategoriyaTuri.kirim,
                        child: Text('Kirim'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedTuri = value);
                    },
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
                      content: Text('Iltimos, kategoriya nomini kiriting!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final newKat = KategoriyaModel(
                  name: _nameController.text.trim(),
                  iconCode: _selectedIcon.codePoint,
                  colorValue: _selectedColor.toARGB32(),
                  turi: _selectedTuri == KategoriyaTuri.kirim
                      ? 'kirim'
                      : 'chiqim',
                );
                if (widget.kategoriyaToEdit != null) {
                  context.read<KategoriyaCubit>().updateKategoriya(
                        widget.kategoriyaToEdit!, newKat);
                } else {
                  context.read<KategoriyaCubit>().addKategoriya(newKat);
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
