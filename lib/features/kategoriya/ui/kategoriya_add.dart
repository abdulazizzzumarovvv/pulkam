import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/kategoriya_cubit.dart';
import '../data/kategoriya_model.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/icon_picker_dialog.dart';

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
    _selectedTuri = widget.kategoriyaToEdit?.turi ?? KategoriyaTuri.chiqim;
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
        title: Text(widget.kategoriyaToEdit != null
            ? 'Kategoriyani tahrirlash'
            : 'Yangi Kategoriya'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Nom
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kategoriya nomini kiriting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon tanlang
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

            // Turi tanlang — dropdown
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
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
                      if (value != null) {
                        setState(() => _selectedTuri = value);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Saqlash
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

                final newKategoriya = KategoriyaModel(
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  turi: _selectedTuri,
                );

                if (widget.kategoriyaToEdit != null) {
                  context.read<KategoriyaCubit>().updateKategoriya(
                    widget.kategoriyaToEdit!,
                    newKategoriya,
                  );
                } else {
                  context.read<KategoriyaCubit>().addKategoriya(newKategoriya);
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