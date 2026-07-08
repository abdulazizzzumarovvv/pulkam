/// Barcha hisoblar tab fayllari ulashadigan konstantalar, funksiyalar
/// va kichik widgetlar.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'hisoblar_tab/data/hisob_model.dart';
import 'maqsadlar_tab/data/maqsad_model.dart';
import 'qarzlar_tab/data/qarz_model.dart';

// ── Konstantalar ──────────────────────────────────────────────────────
const kHisobBg = Color(0xFF13111F);
const double kBtnSize = 52.0;
const double kBtnHalf = kBtnSize / 2;
const double kCardH = 168.0;
const double kHisobGap = 48.0;

const kQarzGreen = Color(0xFF27AE60);
const kQarzRed = Color(0xFFE74C3C);

const kPalette = <Color>[
  Color(0xFFFF6B6B),
  Color(0xFFFF5252),
  Color(0xFFFF1744),
  Color(0xFFD50000),
  Color(0xFFFF8A80),
  Color(0xFFFF6E40),
  Color(0xFFFF3D00),
  Color(0xFFDD2C00),
  Color(0xFFFFAB40),
  Color(0xFFFF9100),
  Color(0xFFFF6D00),
  Color(0xFFE65100),
  Color(0xFFFFD740),
  Color(0xFFFFAB00),
  Color(0xFFFF6F00),
  Color(0xFFF57F17),
  Color(0xFFCCFF90),
  Color(0xFF69F0AE),
  Color(0xFF00E676),
  Color(0xFF00C853),
  Color(0xFF64FFDA),
  Color(0xFF1DE9B6),
  Color(0xFF00BFA5),
  Color(0xFF004D40),
  Color(0xFF80D8FF),
  Color(0xFF40C4FF),
  Color(0xFF0091EA),
  Color(0xFF01579B),
  Color(0xFF82B1FF),
  Color(0xFF448AFF),
  Color(0xFF2979FF),
  Color(0xFF2962FF),
  Color(0xFFB388FF),
  Color(0xFF7C4DFF),
  Color(0xFF651FFF),
  Color(0xFF6200EA),
  Color(0xFFEA80FC),
  Color(0xFFE040FB),
  Color(0xFFD500F9),
  Color(0xFFAA00FF),
  Color(0xFFFF80AB),
  Color(0xFFFF4081),
  Color(0xFFF50057),
  Color(0xFFC51162),
  Color(0xFF90A4AE),
  Color(0xFF546E7A),
  Color(0xFF263238),
];

const kOylar = [
  'Yan',
  'Fev',
  'Mar',
  'Apr',
  'May',
  'Iyun',
  'Iyul',
  'Avg',
  'Sen',
  'Okt',
  'Noy',
  'Dek',
];

// ── Raqamlar uchun font (Roboto) ──────────────────────────────────────
TextStyle kNumStyle({
  double fontSize = 32,
  FontWeight fontWeight = FontWeight.bold,
  Color color = Colors.white,
  double? height,
}) =>
    GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );

// ── Yordamchi funksiyalar ─────────────────────────────────────────────
String hisobFmt(double v, String formatKod) => appFmt(v, formatKod);

String hisobDate(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.day} ${kOylar[d.month - 1]} ${d.year}';
}

// ── Balandlik helperlar ───────────────────────────────────────────────
double hisoblarHeight(List<HisobModel> list, bool expanded) {
  if (list.isEmpty) return kCardH;
  final n = list.length;
  return expanded ? n * kCardH + (n - 1) * kHisobGap + kBtnHalf : kCardH;
}

double maqsadlarHeight(List<MaqsadModel> list, bool expanded) {
  if (list.isEmpty) return kCardH;
  final n = list.length;
  return expanded ? n * kCardH + (n - 1) * kHisobGap + kBtnHalf : kCardH;
}

double qarzlarHeight(List<QarzModel> list, bool expanded) {
  if (list.isEmpty) return kCardH;
  final n = list.length;
  return expanded ? n * kCardH + (n - 1) * kHisobGap + kBtnHalf : kCardH;
}

// ── Bo'sh holat kartasi ───────────────────────────────────────────────
class HisobEmptyCard extends StatefulWidget {
  final String message;
  final IconData icon;
  const HisobEmptyCard({
    super.key,
    required this.message,
    this.icon = Icons.sentiment_satisfied_rounded,
  });

  @override
  State<HisobEmptyCard> createState() => _HisobEmptyCardState();
}

class _HisobEmptyCardState extends State<HisobEmptyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kCardH,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_ctrl.value);
                return Transform.translate(
                  offset: Offset(0, -6 * t),
                  child: Transform.scale(scale: 1 + 0.08 * t, child: child),
                );
              },
              child: Icon(widget.icon, color: Colors.grey[400], size: 42),
            ),
            const SizedBox(height: 12),
            Text(
              widget.message,
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Valyuta badge ─────────────────────────────────────────────────────
class HisobUzsBadge extends StatelessWidget {
  const HisobUzsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final kod = context.watch<SozlamalarCubit>().state.valyutaKod;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        kod,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Glass tugma ───────────────────────────────────────────────────────
class HisobGlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const HisobGlassBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: kBtnSize,
            height: kBtnSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ── BottomFill clipper (progress to'ldirgich uchun) ───────────────────
class HisobBottomFillClipper extends CustomClipper<Rect> {
  final double progress;
  const HisobBottomFillClipper(this.progress);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);

  @override
  bool shouldReclip(HisobBottomFillClipper oldClipper) =>
      oldClipper.progress != progress;
}

// ── Maqsad bajarilganda yonib turadigan olov ─────────────────────────
class HisobFlame extends StatefulWidget {
  const HisobFlame({super.key});

  @override
  State<HisobFlame> createState() => _HisobFlameState();
}

class _HisobFlameState extends State<HisobFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final glow = 12.0 + 16.0 * t;
        return Transform.scale(
          scale: 1 + 0.12 * t,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 42,
            color: const Color(0xFFFF7A1A),
            shadows: [
              BoxShadow(
                color: const Color(0xFFFF7A1A).withValues(alpha: 0.9),
                blurRadius: glow,
              ),
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.65),
                blurRadius: glow + 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
