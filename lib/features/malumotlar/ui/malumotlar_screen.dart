import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/features/malumotlar/ui/valyuta_dialog.dart';
import 'package:pulkam/features/malumotlar/ui/format_dialog.dart';
import 'package:pulkam/features/malumotlar/ui/pin_dialog.dart';
import 'package:pulkam/features/malumotlar/ui/til_dialog.dart';
import 'package:pulkam/features/malumotlar/ui/reminder_dialog.dart';
import 'package:pulkam/services/widget_service.dart';
import 'package:pulkam/features/pro/ui/pro_page.dart';
import 'package:pulkam/services/tutorial_service.dart';
import 'package:pulkam/l10n.dart';

class MalumotlarScreen extends StatelessWidget {
  const MalumotlarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SozlamalarCubit, SozlamalarState>(
      builder: (context, state) {
        final bg = state.mavzuRang;
        final cardColor = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
        final textColor = Colors.white;
        final subtextColor = Colors.white.withValues(alpha: 0.5);
        final dividerColor = Colors.white.withValues(alpha: 0.08);
        final l10n = context.l10n;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/app_icon_transparent.png',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 10),
                Text(
                  // Nom hech qachon tarjima qilinmaydi — doim "PulKam"
                  'PulKam',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                // PRO pill — Pulkam so'zining o'ng tarafida, bosilsa Pro sahifa
                GestureDetector(
                  onTap: () => showProPage(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: state.isPro
                          ? const LinearGradient(
                              colors: [Color(0xFFF5D061), Color(0xFFD4AF37)],
                            )
                          : null,
                      color: state.isPro
                          ? null
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      state.isPro ? 'PRO' : l10n.proOlish,
                      style: TextStyle(
                        color: state.isPro
                            ? const Color(0xFF3E320A)
                            : Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sozlamalar ─────────────────────────────────────────
                _SectionLabel(label: l10n.sozlamalar, color: subtextColor),
                const SizedBox(height: 8),
                _Card(
                  color: cardColor,
                  dividerColor: dividerColor,
                  items: [
                    _RowItem(
                      icon: Icons.currency_exchange_rounded,
                      iconBg: const Color(0xFF2979FF),
                      label: l10n.asosiyVaIuta,
                      trailing: Text(
                        state.valyutaKod,
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                      onTap: () => showValyutaDialog(context),
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _RowItem(
                      icon: Icons.format_list_numbered_rounded,
                      iconBg: const Color(0xFF00BFA5),
                      label: l10n.formatlash,
                      trailing: Text(
                        appFmt(1000000, state.formatKod),
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                      onTap: () => showFormatDialog(context),
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _RowItem(
                      icon: Icons.palette_rounded,
                      iconBg: const Color(0xFF7C4DFF),
                      label: l10n.mavzular,
                      onTap: () => _showMavzuDialog(context, state.mavzuRang),
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _RowItem(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFFF6D00),
                      label: l10n.til,
                      trailing: Text(
                        _tilNomi(state.tilKod, l10n),
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                      onTap: () => showTilDialog(context),
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _ToggleItem(
                      icon: Icons.widgets_rounded,
                      iconBg: const Color(0xFF00BCD4),
                      label: l10n.widget,
                      value: state.widgetYoniq,
                      onChanged: (v) async {
                        context.read<SozlamalarCubit>().setWidgetYoniq(v);
                        if (v) {
                          final ok = await requestPinWidget();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? l10n.widgetQoshildi : l10n.widgetQollanma,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      textColor: textColor,
                      themeBg: bg,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Xavfsizlik ─────────────────────────────────────────
                _SectionLabel(label: l10n.xavfsizlik, color: subtextColor),
                const SizedBox(height: 8),
                _Card(
                  color: cardColor,
                  dividerColor: dividerColor,
                  items: [
                    _ToggleItem(
                      icon: CupertinoIcons.lock_fill,
                      iconBg: const Color(0xFFFF3B30),
                      label: l10n.pinKod,
                      value: state.pinCode,
                      onChanged: (v) {
                        if (v) {
                          showPinSetupDialog(context);
                        } else {
                          context.read<SozlamalarCubit>().setPinCode(false);
                        }
                      },
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _RowItem(
                      icon: CupertinoIcons.bell_fill,
                      iconBg: const Color(0xFFFFAB00),
                      label: l10n.eslatmalar,
                      onTap: () => showReminderDialog(context),
                      textColor: textColor,
                      themeBg: bg,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Boshqa ─────────────────────────────────────────────
                _SectionLabel(label: l10n.boshqa, color: subtextColor),
                const SizedBox(height: 8),
                _Card(
                  color: cardColor,
                  dividerColor: dividerColor,
                  items: [
                    _RowItem(
                      icon: Icons.info_outline_rounded,
                      iconBg: const Color(0xFF546E7A),
                      label: l10n.bizHaqimizda,
                      onTap: () => _showAboutDialog(context, cardColor),
                      textColor: textColor,
                      themeBg: bg,
                    ),
                    _RowItem(
                      icon: Icons.menu_book_rounded,
                      iconBg: const Color(0xFF00BCD4),
                      label: l10n.yoriqnoma,
                      onTap: () {
                        // Settings'ni yopib turni qaytadan boshlash
                        Navigator.pop(context);
                        Future.delayed(
                          const Duration(milliseconds: 400),
                          () => tutorialQaytaBoshla?.call(),
                        );
                      },
                      textColor: textColor,
                      themeBg: bg,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Biz haqimizda: markazda mini icon + qisqa tavsif ─────────────────
  void _showAboutDialog(BuildContext context, Color cardColor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini icon — o'rtada
              Image.asset(
                'assets/icon/app_icon_transparent.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 14),
              Text(
                dialogCtx.l10n.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${dialogCtx.l10n.appName} — ${dialogCtx.l10n.aboutMatn}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _tilNomi(String kod, AppL10n l10n) {
    switch (kod) {
      case 'uz': return "O'zbek";
      case 'ru': return 'Русский';
      case 'en': return 'English';
      default:   return l10n.defaultTil;
    }
  }

  void _showMavzuDialog(BuildContext context, Color current) {
    final cubit = context.read<SozlamalarCubit>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Yopish',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim, _) => BlocProvider.value(
        value: cubit,
        child: _MavzuDialog(current: current),
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

// ── Mavzu dialog ─────────────────────────────────────────────────────────────
class _MavzuDialog extends StatefulWidget {
  final Color current;
  const _MavzuDialog({required this.current});

  @override
  State<_MavzuDialog> createState() => _MavzuDialogState();
}

class _MavzuDialogState extends State<_MavzuDialog> {
  late Color _selected;

  static const List<_ThemeOption> _themes = [
    _ThemeOption('tungi_qora',     Color(0xFF13111F)),
    _ThemeOption('zangori_tun',    Color(0xFF0D1B2A)),
    _ThemeOption('qora_dengiz',    Color(0xFF0A1628)),
    _ThemeOption('qorongu_yashil', Color(0xFF0D2118)),
    _ThemeOption('jimjit_tog',     Color(0xFF1A1A2E)),
    _ThemeOption('binafsha_tun',   Color(0xFF1E0A3C)),
    _ThemeOption('bordo',          Color(0xFF1C0A0A)),
    _ThemeOption('shokolad',       Color(0xFF1A0F00)),
    _ThemeOption('marjonsiz',      Color(0xFF0F1C1A)),
    _ThemeOption('kok_qovoq',      Color(0xFF0E1A1F)),
    _ThemeOption('kumush_tun',     Color(0xFF1A1A1A)),
    _ThemeOption('granit',         Color(0xFF141414)),
    _ThemeOption('qongir_tog',     Color(0xFF1B1209)),
    _ThemeOption('toq_moviy',      Color(0xFF091525)),
    _ThemeOption('zaytun_tun',     Color(0xFF141A09)),
    _ThemeOption('temir',          Color(0xFF101418)),
    _ThemeOption('indigo',         Color(0xFF0D0F2B)),
    _ThemeOption('toq_qongir',     Color(0xFF1A1209)),
    _ThemeOption('toq_zangori',    Color(0xFF05101F)),
    _ThemeOption('shinam_qora',    Color(0xFF111111)),
  ];

  // PRO gradient mavzular — tanlansa gradientning quyuq bazaviy rangi qo'llanadi
  static const List<_GradThemeOption> _gradThemes = [
    _GradThemeOption('grad_kosmos',   [Color(0xFF0F0C29), Color(0xFF302B63)]),
    _GradThemeOption('grad_shafaq',   [Color(0xFF1A0A1E), Color(0xFF6B2D5C)]),
    _GradThemeOption('grad_okean',    [Color(0xFF051937), Color(0xFF004D7A)]),
    _GradThemeOption('grad_aurora',   [Color(0xFF041B2D), Color(0xFF004E66)]),
    _GradThemeOption('grad_lava',     [Color(0xFF200122), Color(0xFF6F0000)]),
    _GradThemeOption('grad_tunola',   [Color(0xFF16121E), Color(0xFF432371)]),
    _GradThemeOption('grad_binafsha', [Color(0xFF1D0B33), Color(0xFF4A1B6D)]),
    _GradThemeOption('grad_izumrud',  [Color(0xFF04160F), Color(0xFF0B4F3A)]),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  void _pickRandom() {
    final idx = DateTime.now().millisecondsSinceEpoch % _themes.length;
    setState(() => _selected = _themes[idx].color);
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.watch<SozlamalarCubit>().state.mavzuRang;
    final cardBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              context.l10n.mavzu,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Grid: oddiy mavzular + PRO gradient mavzular
          SizedBox(
            height: 400,
            child: Builder(builder: (context) {
              final isPro =
                  context.watch<SozlamalarCubit>().state.isPro;
              const gridDelegate =
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
              );
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  // ── Oddiy mavzular ─────────────────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: gridDelegate,
                    itemCount: _themes.length,
                    itemBuilder: (_, i) {
                      final t = _themes[i];
                      final isSelected =
                          t.color.toARGB32() == _selected.toARGB32();
                      return GestureDetector(
                        onTap: () => setState(() => _selected = t.color),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                color: t.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.15),
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: t.color
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 20)
                                  : null,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              context.l10n.mavzuNom(t.key),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.65),
                                fontSize: 9,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ── PRO mavzular sarlavhasi ────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            context.l10n.proMavzular,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Gradient mavzular ──────────────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: gridDelegate,
                    itemCount: _gradThemes.length,
                    itemBuilder: (_, i) {
                      final g = _gradThemes[i];
                      final locked = !isPro;
                      final isSelected = !locked &&
                          g.colors.first.toARGB32() ==
                              _selected.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          if (locked) {
                            showProPage(context);
                            return;
                          }
                          setState(() => _selected = g.colors.first);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: g.colors,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white
                                              .withValues(alpha: 0.15),
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 20)
                                      : null,
                                ),
                                // Locked: PRO badge ustida
                                if (locked)
                                  Positioned(
                                    top: -4,
                                    right: -8,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'PRO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              context.l10n.mavzuNom(g.key),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(
                                    alpha: locked ? 0.35 : 0.65),
                                fontSize: 9,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Glass tugmalar: ❌ | 🔀 | ✓
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Row(
              children: [
                // Bekor qilish
                Expanded(
                  child: _GlassBtn(
                    icon: Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.12),
                    iconColor: Colors.white.withValues(alpha: 0.7),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                // Random
                Expanded(
                  child: _GlassBtn(
                    icon: Icons.shuffle_rounded,
                    color: Colors.white.withValues(alpha: 0.12),
                    iconColor: Colors.white.withValues(alpha: 0.7),
                    onTap: _pickRandom,
                  ),
                ),
                const SizedBox(width: 10),
                // Saqlash
                Expanded(
                  child: _GlassBtn(
                    icon: Icons.check_rounded,
                    color: Colors.white.withValues(alpha: 0.12),
                    iconColor: Colors.white.withValues(alpha: 0.7),
                    onTap: () {
                      context.read<SozlamalarCubit>().setMavzuRang(_selected);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ],
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  const _GlassBtn({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

class _ThemeOption {
  final String key;
  final Color color;
  const _ThemeOption(this.key, this.color);
}

// PRO gradient mavzu — ikki rangli gradient, bazaviy rang = colors.first
class _GradThemeOption {
  final String key;
  final List<Color> colors;
  const _GradThemeOption(this.key, this.colors);
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
    );
  }
}

class _Card extends StatelessWidget {
  final Color color;
  final Color dividerColor;
  final List<Widget> items;
  const _Card(
      {required this.color,
      required this.dividerColor,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(children: items),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color textColor;
  final Color themeBg;
  final bool showDivider;

  const _RowItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.themeBg,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white.withValues(alpha: 0.75);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: TextStyle(fontSize: 15, color: textColor)),
                ),
                if (trailing != null) ...[trailing!, const SizedBox(width: 6)],
                Icon(Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.3), size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 62,
            color: Colors.white.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final Color themeBg;
  final bool showDivider;

  const _ToggleItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.textColor,
    required this.themeBg,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white.withValues(alpha: 0.75);
    final switchActive = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.28),
      themeBg,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    Text(label, style: TextStyle(fontSize: 15, color: textColor)),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: switchActive,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 62,
            color: Colors.white.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}
