import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

class _Format {
  final String nom;
  final String kod;
  final String misol;
  const _Format(this.nom, this.kod, this.misol);
}

const _kFormatlar = [
  _Format('Vergul va nuqta', 'comma_dot', '1,000,000.00'),
  _Format("Bo'sh joy va nuqta", 'space_dot', '1 000 000.00'),
  _Format('Nuqta va vergul', 'dot_comma', '1.000.000,00'),
  _Format("Bo'sh joy va vergul", 'space_comma', '1 000 000,00'),
  _Format('Separatorsiz', 'none_dot', '1000000.00'),
];

Future<void> showFormatDialog(BuildContext context) {
  final soz = context.read<SozlamalarCubit>();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => _FormatDialog(
      cubit: soz,
      bg: soz.state.mavzuRang,
      selected: soz.state.formatKod,
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _FormatDialog extends StatefulWidget {
  final SozlamalarCubit cubit;
  final Color bg;
  final String selected;
  const _FormatDialog({
    required this.cubit,
    required this.bg,
    required this.selected,
  });

  @override
  State<_FormatDialog> createState() => _FormatDialogState();
}

class _FormatDialogState extends State<_FormatDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  Widget _tile(_Format f) {
    final isSelected = f.kod == _selected;
    return InkWell(
      onTap: () => setState(() => _selected = f.kod),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: isSelected ? 5.5 : 1.5,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.nom,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: isSelected ? 1.0 : 0.85),
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    f.misol,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.bg;
    final cardBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);

    return Stack(
      children: [
        // Blur background
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
        ),

        // Dialog
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MediaQuery.of(context).size.height * 0.15,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Text(
                        context.l10n.raqamFormati,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08)),

                    // Ro'yxat
                    ..._kFormatlar.map(_tile),

                    // Tugmalar
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GlassCircleBtn(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 20),
                          _GlassCircleBtn(
                            icon: Icons.check_rounded,
                            onTap: () {
                              widget.cubit.setFormat(_selected);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child:
                Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 24),
          ),
        ),
      ),
    );
  }
}
