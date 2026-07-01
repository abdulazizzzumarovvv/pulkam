import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulkam/features/amallar/ui/amallar_screen.dart';
import 'package:pulkam/features/hisoblar/hisoblar.dart';
import 'package:pulkam/features/kategoriya/ui/kategoriya.dart';

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
  }

  @override
  void dispose() {
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
      bottomNavigationBar: _GlassPillNavBar(
        selectedIndex: _index,
        onTap: _onNavTap,
      ),
    );
  }
}

class _GlassPillNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassPillNavBar({
    required this.selectedIndex,
    required this.onTap,
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
                // 1. KATEGORIYA
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.chart_bar,
                    filledIcon: CupertinoIcons.chart_bar_fill,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                const SizedBox(width: 5),
                
                // 2. AMALLAR (ASOSIY)
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.house,
                    filledIcon: CupertinoIcons.house_fill,
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                const SizedBox(width: 5),
                
                // 3. HISOBLAR
                Expanded(
                  child: _NavIcon(
                    outlinedIcon: CupertinoIcons.creditcard,
                    filledIcon: CupertinoIcons.creditcard_fill,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
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

  const _NavIcon({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Icon(
            // Tanlangan bo'lsa filledIcon, aks holda outlinedIcon chiziladi
            isSelected ? filledIcon : outlinedIcon,
            size: 24,
            color: isSelected
                ? Colors.black
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}