import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/features/amallar/ui/amallar_screen.dart';
import 'package:pulkam/features/hisoblar/hisoblar.dart';
import 'package:pulkam/features/kategoriya/ui/kategoriya.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/features/pro/ui/pro_page.dart';
import 'package:pulkam/features/hisoblar/widgets/calculator/kirim_chiqim_sheet.dart';
import 'package:pulkam/features/malumotlar/ui/malumotlar_screen.dart';
import 'package:pulkam/services/tutorial_service.dart';
import 'package:pulkam/l10n.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 1;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);

    // Tutorial servisi uchun callbacklar
    tutorialQaytaBoshla = _turBoshla;
    tutorialSahifaga = (page) async {
      if (!_pageController.hasClients) return;
      await _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final box = Hive.box('settings');

      // Obuna muddati tugagan — bir martalik dialog
      final proTugagan =
          box.get(SozlamalarCubit.keyProExpiredPending) as bool? ?? false;
      if (proTugagan) {
        box.delete(SozlamalarCubit.keyProExpiredPending);
        showProTugadiDialog(context);
        return;
      }

      // Birinchi kirishda: Pro sahifasi → yopilgach tutorial turi
      final korildi = box.get('pro_page_korildi') as bool? ?? false;
      if (!korildi) {
        box.put('pro_page_korildi', true);
        await showProPage(context);
        if (!mounted) return;
        final tutorialKorildi =
            box.get('tutorial_korildi') as bool? ?? false;
        if (!tutorialKorildi) {
          box.put('tutorial_korildi', true);
          _turBoshla();
        }
      }
    });
  }

  // ── Tutorial turini boshlash (settings'dagi "Yo'riqnoma"dan ham) ────
  void _turBoshla() {
    startTutorial(
      context,
      sheetOch: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KirimChiqimSheet()),
        );
      },
      settingsOch: () async {
        final route = MaterialPageRoute<void>(
            builder: (_) => const MalumotlarScreen());
        Navigator.push(context, route);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        await showTutorialIzoh(context, context.l10n.tutSettingsIchi);
        if (!mounted) return;
        if (route.isActive) Navigator.of(context).pop();
        await Future.delayed(const Duration(milliseconds: 350));
      },
    );
  }

  @override
  void dispose() {
    tutorialSahifaga = null;
    tutorialQaytaBoshla = null;
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          Kategoriya(),
          AmallarScreen(),
          Hisoblar(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<SozlamalarCubit, SozlamalarState>(
        builder: (context, soz) => _GlassPillNavBar(
          selectedIndex: _index,
          onTap: _onNavTap,
          accentColor: soz.mavzuRang,
        ),
      ),
    );
  }
}

class _GlassPillNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const _GlassPillNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 44, bottom: 30, top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 66,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.chart_bar,
                    filledIcon: CupertinoIcons.chart_bar_fill,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.house,
                    filledIcon: CupertinoIcons.house_fill,
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.creditcard,
                    filledIcon: CupertinoIcons.creditcard_fill,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                    accentColor: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _NavIcon({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.onTap,
    required this.isSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Tanlangan pill background: mavzu rangidan biroz ochroq
    final pillBg = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.18),
      accentColor,
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? pillBg : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Icon(
            isSelected ? filledIcon : outlinedIcon,
            size: 24,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}