// icon_picker_dialog.dart
import 'package:flutter/material.dart';
import 'icon_picker_screen.dart';
import 'package:pulkam/features/hisoblar/widgets/icon/color_picker_screen.dart';

class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({super.key});

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  late IconData _selectedIcon;
  late Color _selectedColor;

  // _allIcons va _allColors o'rniga:
  void _randomize() {
    setState(() {
      _selectedIcon = IconPickerScreen.randomIcon();
      _selectedColor = ColorPickerScreen.randomColor();
    });
  }

  // initState da ham:
  @override
  void initState() {
    super.initState();
    _selectedIcon = IconPickerScreen.randomIcon();
    _selectedColor = ColorPickerScreen.randomColor();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_selectedIcon, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Iconni o\'zgartiring',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Icon tanlang + Rang tanlang
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    label: 'Icon tanlang',
                    icon: Icons.grid_view_rounded,
                    onTap: () async {
                      final result = await Navigator.push<IconData>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IconPickerScreen(
                            initialIcon: _selectedIcon,
                            accentColor: _selectedColor,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() => _selectedIcon = result);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PickerButton(
                    label: 'Rang tanlang',
                    icon: Icons.palette_outlined,
                    onTap: () async {
                      final result = await Navigator.push<Color>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ColorPickerScreen(initialColor: _selectedColor),
                        ),
                      );
                      if (result != null) {
                        setState(() => _selectedColor = result);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Random
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _randomize,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Random Icon va Rang',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Saqlash
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'icon': _selectedIcon,
                'color': _selectedColor,
              }),
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

class _PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
