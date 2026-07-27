import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

void showTilDialog(BuildContext context) {
  final cubit = context.read<SozlamalarCubit>();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => BlocProvider.value(
      value: cubit,
      child: const _TilDialog(),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _TilItem {
  final String kod;
  final String nom;
  final String emoji;
  const _TilItem(this.kod, this.nom, this.emoji);
}

List<_TilItem> _buildTillar(AppL10n l10n) => [
      _TilItem('', l10n.defaultTil, '🌐'),
      _TilItem('uz', "O'zbek", '🇺🇿'),
      _TilItem('ru', 'Русский', '🇷🇺'),
      _TilItem('en', 'English', '🇬🇧'),
    ];

class _TilDialog extends StatelessWidget {
  const _TilDialog();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SozlamalarCubit, SozlamalarState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final tillar = _buildTillar(l10n);
        final bg = state.mavzuRang;
        final cardBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
        final selected = state.tilKod;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
            Dialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      l10n.tilniTanlang,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tillar.length,
                      separatorBuilder: (ctx, i) => Divider(
                        height: 1,
                        indent: 56,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      itemBuilder: (ctx, i) {
                        final t = tillar[i];
                        final isSelected = t.kod == selected;
                        return InkWell(
                          onTap: () {
                            context.read<SozlamalarCubit>().setTil(t.kod);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Text(t.emoji,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    t.nom,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_rounded,
                                      color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
