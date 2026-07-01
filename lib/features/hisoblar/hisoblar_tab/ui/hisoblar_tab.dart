import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../hisoblar_shared.dart';
import '../data/hisob_model.dart';
import '../../widgets/calculator/kirim_chiqim_sheet.dart';
import '../../widgets/calculator/hisob_transfer_sheet.dart';

// ── Hisoblar stack ─────────────────────────────────────────────────────
class HisobStack extends StatelessWidget {
  final List<HisobModel> hisoblar;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const HisobStack({
    super.key,
    required this.hisoblar,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (hisoblar.isEmpty) {
      return const HisobEmptyCard(
        message: 'Hisob mavjud emas',
        icon: Icons.account_balance_wallet_rounded,
      );
    }
    final n = hisoblar.length;
    final h = hisoblarHeight(hisoblar, expanded);
    return SizedBox(
      width: double.infinity,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(n, (k) {
          final i = n - 1 - k;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            top: expanded ? i * (kCardH + kHisobGap) : 0,
            left: 0,
            right: 0,
            height: kCardH,
            child: GestureDetector(
              onTap: onToggle,
              child: HisobCard(
                hisob: hisoblar[i],
                allHisoblar: hisoblar,
                stackExpanded: expanded,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Hisob kartasi ─────────────────────────────────────────────────────
class HisobCard extends StatelessWidget {
  final HisobModel hisob;
  final List<HisobModel> allHisoblar;
  final bool stackExpanded;
  final void Function(Object) onEdit;
  final void Function(Object) onDelete;
  const HisobCard({
    super.key,
    required this.hisob,
    required this.allHisoblar,
    required this.stackExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final balance = double.tryParse(hisob.balance) ?? 0;
    final formatted = hisobFmt(balance);
    final dotIdx = formatted.indexOf('.');
    final intPart = formatted.substring(0, dotIdx);
    final decPart = formatted.substring(dotIdx);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: hisob.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: hisob.color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hisob.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const HisobUzsBadge(),
                    const SizedBox(width: 8),
                    Text(
                      intPart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 2),
                      child: Text(
                        decPart,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -kBtnHalf,
          left: 20,
          child: AnimatedOpacity(
            opacity: stackExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !stackExpanded,
              child: Row(
                children: [
                  HisobGlassBtn(
                    icon: Icons.edit_outlined,
                    onTap: () => onEdit(hisob),
                  ),
                  const SizedBox(width: 12),
                  HisobGlassBtn(
                    icon: Icons.swap_vert_rounded,
                    onTap: () => _showTopUp(context),
                  ),
                  const SizedBox(width: 12),
                  HisobGlassBtn(
                    icon: Icons.swap_horiz_rounded,
                    onTap: () => _showTransfer(context),
                  ),
                  const SizedBox(width: 12),
                  HisobGlassBtn(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => onDelete(hisob),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTopUp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KirimChiqimSheet(hisob: hisob),
    );
  }

  void _showTransfer(BuildContext context) {
    final others = allHisoblar.where((h) => h.key != hisob.key).toList();
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O'tkazish uchun boshqa hisob mavjud emas"),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HisobTransferSheet(source: hisob, boshqalar: others),
    );
  }
}
