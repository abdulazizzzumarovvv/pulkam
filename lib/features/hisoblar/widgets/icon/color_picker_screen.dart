// color_picker_screen.dart
import 'package:flutter/material.dart';

class ColorPickerScreen extends StatefulWidget {
  final Color initialColor;
  const ColorPickerScreen({super.key, required this.initialColor});

  static Color randomColor() {
    final all = [
      Color(0xFFFF6B6B),
      Color(0xFFFF5252),
      Color(0xFF2979FF),
      Color(0xFF00E676),
      Color(0xFFFFAB00),
      Color(0xFF7C4DFF),
      Color(0xFF00BFA5),
      Color(0xFFFF4081),
      Color(0xFF546E7A),
      Color(0xFFFF3D00),
      Color(0xFF00BCD4),
      Color(0xFF8BC34A),
    ]..shuffle();
    return all.first;
  }

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  late Color _selected;

  final List<List<Color>> _colorGrid = [
    [
      Color(0xFFFF6B6B),
      Color(0xFFFF5252),
      Color(0xFFFF1744),
      Color(0xFFD50000),
    ],
    [
      Color(0xFFFF8A80),
      Color(0xFFFF6E40),
      Color(0xFFFF3D00),
      Color(0xFFDD2C00),
    ],
    [
      Color(0xFFFFAB40),
      Color(0xFFFF9100),
      Color(0xFFFF6D00),
      Color(0xFFE65100),
    ],
    [
      Color(0xFFFFD740),
      Color(0xFFFFAB00),
      Color(0xFFFF6F00),
      Color(0xFFF57F17),
    ],
    [
      Color(0xFFCCFF90),
      Color(0xFF69F0AE),
      Color(0xFF00E676),
      Color(0xFF00C853),
    ],
    [
      Color(0xFF64FFDA),
      Color(0xFF1DE9B6),
      Color(0xFF00BFA5),
      Color(0xFF004D40),
    ],
    [
      Color(0xFF80D8FF),
      Color(0xFF40C4FF),
      Color(0xFF0091EA),
      Color(0xFF01579B),
    ],
    [
      Color(0xFF82B1FF),
      Color(0xFF448AFF),
      Color(0xFF2979FF),
      Color(0xFF2962FF),
    ],
    [
      Color(0xFFB388FF),
      Color(0xFF7C4DFF),
      Color(0xFF651FFF),
      Color(0xFF6200EA),
    ],
    [
      Color(0xFFEA80FC),
      Color(0xFFE040FB),
      Color(0xFFD500F9),
      Color(0xFFAA00FF),
    ],
    [
      Color(0xFFFF80AB),
      Color(0xFFFF4081),
      Color(0xFFF50057),
      Color(0xFFC51162),
    ],
    [
      Color(0xFFCFD8DC),
      Color(0xFF90A4AE),
      Color(0xFF546E7A),
      Color(0xFF263238),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rang tanlang'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _colorGrid.map((row) {
            return Row(
              children: row.map((color) {
                final isSelected = color.value == _selected.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = color),
                    child: Container(
                      height: 70,
                      color: color,
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Saqlash'),
        ),
      ),
    );
  }
}
