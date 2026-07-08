import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

// ── Tarif ma'lumotlari (tilga qarab valyuta) ──────────────────────────
class _PlanInfo {
  final String umrbodNarx;
  final String yillikNarx;
  final String yillikHafta;
  final String oylikNarx;
  final String oylikHafta;
  final String chegirma;
  const _PlanInfo({
    required this.umrbodNarx,
    required this.yillikNarx,
    required this.yillikHafta,
    required this.oylikNarx,
    required this.oylikHafta,
    required this.chegirma,
  });
}

// Narxlar til/valyuta sozlamasidan qat'i nazar DOIM so'mda.
// (so'z "so'm/сум/soʻm" faqat matn — summa o'zgarmaydi)
_PlanInfo _planInfo(String lang) {
  final som = switch (lang) {
    'ru' => 'сум',
    'en' => 'soʻm',
    _ => "so'm",
  };
  return _PlanInfo(
    umrbodNarx: '249 900 $som',
    yillikNarx: '159 900 $som',
    yillikHafta: '3 075 $som',
    oylikNarx: '14 900 $som',
    oylikHafta: '3 440 $som',
    chegirma: '-11%',
  );
}

/// Pro sahifasini ochish.
/// HOZIRCHA (Click integratsiyasigacha): sahifa ochilmaydi, "Tez orada" xabari.
Future<void> showProPage(BuildContext context) async {
  final l10n = context.l10n;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_clock_rounded, color: Color(0xFFF5D061), size: 20),
          const SizedBox(width: 10),
          Text(
            l10n.comingSoon,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E2233),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Pro sahifasini haqiqatan ochish (Click ulanganda ishlatiladi).
Future<void> openProPageReal(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProPage(), fullscreenDialog: true),
  );
}

/// "PRO obunangiz tugadi" dialogi — muddat tugaganda bir marta ko'rsatiladi.
void showProTugadiDialog(BuildContext context) {
  final l10n = context.l10n;
  final bg = context.read<SozlamalarCubit>().state.mavzuRang;
  final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => Dialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Xira toj ikonasi — obuna tugagan
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.grey[400],
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.proTugadi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proTugadiMatn,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            // PRO olish — oq tugma, Pro sahifaga otadi
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogCtx);
                showProPage(context);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    l10n.proOlish,
                    style: TextStyle(
                      color: bg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  // 0 = umrbod, 1 = yillik, 2 = oylik
  int _tanlangan = 1;

  // ── Oltin tabrik dialogi (obuna muvaffaqiyatli bo'lganda) ───────────
  void _showTabrikDialog(BuildContext rootCtx, Color cardColor) {
    const oltin = Color(0xFFD4AF37);
    const oltinOchiq = Color(0xFFF5D061);
    final l10n = rootCtx.l10n;

    showDialog(
      context: rootCtx,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: oltin.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Oltin toj ikonasi
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [oltinOchiq, oltin],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: oltin.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.proMuvaffaqiyat,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              // Oltin tugma
              GestureDetector(
                onTap: () => Navigator.pop(dialogCtx),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [oltinOchiq, oltin],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      l10n.ajoyib,
                      style: const TextStyle(
                        color: Color(0xFF3E320A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── "Davom ettirish" → obuna sheet (simulyatsiya) ───────────────────
  void _davomEtish() {
    final l10n = context.l10n;
    final soz = context.read<SozlamalarCubit>();
    final bg = soz.state.mavzuRang;
    final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
    final plan = _planInfo(l10n.lang);
    final tarif = switch (_tanlangan) {
      0 => l10n.proUmrbod,
      1 => l10n.proYillik,
      _ => l10n.proOylik,
    };
    final narx = switch (_tanlangan) {
      0 => plan.umrbodNarx,
      1 => plan.yillikNarx,
      _ => plan.oylikNarx,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(sheetCtx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tortish chizig'i
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Sarlavha
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5D061), Color(0xFFD4AF37)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.appName} PRO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        tarif,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Tarif xulosasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tarif,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    narx,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Izoh
            Text(
              _tanlangan == 0 ? l10n.proUmrbodIzoh : l10n.proObunaTasdiq,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Obuna bo'lish — oq tugma
            GestureDetector(
              onTap: () {
                final rootCtx =
                    Navigator.of(context, rootNavigator: true).context;
                soz.activatePro(switch (_tanlangan) {
                  0 => 'umrbod',
                  1 => 'yillik',
                  _ => 'oylik',
                });
                Navigator.pop(sheetCtx); // sheet yopiladi
                Navigator.pop(context); // pro page yopiladi
                _showTabrikDialog(rootCtx, kCard);
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Center(
                  child: Text(
                    l10n.proObunaBolish,
                    style: TextStyle(
                      color: bg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final soz = context.watch<SozlamalarCubit>().state;
    final bg = soz.mavzuRang;
    final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
    final plan = _planInfo(l10n.lang);
    final isPro = soz.isPro;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Yuqori qator: X + PulKam Pro (yonma-yon) ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pro',
                            style: TextStyle(
                              color: bg,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // X tugma bilan simmetriya uchun bo'sh joy
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    // Tagline
                    Text(
                      l10n.proTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Umrbod (Cheklangan taklif) ─────────────────────
                    _PlanCard(
                      cardColor: kCard,
                      title: l10n.proUmrbod,
                      price: plan.umrbodNarx,
                      subtitle:
                          '${l10n.proBirMartalik} · ${l10n.proUmrbodIzoh}',
                      badge: l10n.proCheklanganTaklif,
                      badgeColor: const Color(0xFFFF8A3C),
                      tint: const Color(0xFFFF8A3C),
                      selected: _tanlangan == 0,
                      onTap: () => setState(() => _tanlangan = 0),
                    ),
                    const SizedBox(height: 12),

                    // ── Yillik ─────────────────────────────────────────
                    _PlanCard(
                      cardColor: kCard,
                      title: l10n.proYillik,
                      price: plan.yillikNarx,
                      subtitle:
                          '${plan.yillikHafta} / ${l10n.proHaftasiga}',
                      badge: '${plan.chegirma} ${l10n.proChegirma}',
                      badgeColor: const Color(0xFF27AE60),
                      selected: _tanlangan == 1,
                      onTap: () => setState(() => _tanlangan = 1),
                    ),
                    const SizedBox(height: 12),

                    // ── Oylik ──────────────────────────────────────────
                    _PlanCard(
                      cardColor: kCard,
                      title: l10n.proOylik,
                      price: plan.oylikNarx,
                      subtitle: '${plan.oylikHafta} / ${l10n.proHaftasiga}',
                      selected: _tanlangan == 2,
                      onTap: () => setState(() => _tanlangan = 2),
                    ),
                    const SizedBox(height: 24),

                    // ── Imkoniyatlar (oq star iconlar bilan) ──────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _BenefitRow(text: l10n.proFoydaOvoz),
                          const SizedBox(height: 14),
                          _BenefitRow(text: l10n.proFoydaAnaliz),
                          const SizedBox(height: 14),
                          _BenefitRow(text: l10n.proFoydaKategoriya),
                          const SizedBox(height: 14),
                          _BenefitRow(text: l10n.proFoydaQarzMaqsad),
                          const SizedBox(height: 14),
                          _BenefitRow(text: l10n.proFoydaMavzu),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Fixed bottom: Davom ettirish (oq tugma) ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GestureDetector(
                onTap: isPro ? null : _davomEtish,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isPro
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isPro
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPro) ...[
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          isPro ? l10n.proAllaqachon : l10n.proDavomEtish,
                          style: TextStyle(
                            color: isPro ? Colors.white : bg,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarif kartasi ─────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final Color cardColor;
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final Color badgeColor;
  final Color? tint; // konteyner rangi (masalan, olov rang)
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.cardColor,
    required this.title,
    required this.price,
    required this.subtitle,
    this.badge,
    this.badgeColor = const Color(0xFF27AE60),
    this.tint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = context.read<SozlamalarCubit>().state.mavzuRang;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tint != null
              ? Color.alphaBlend(tint!.withValues(alpha: 0.22), cardColor)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.white
                : tint?.withValues(alpha: 0.55) ??
                    Colors.white.withValues(alpha: 0.1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        // FittedBox — uzun yozuv qisqarmasdan sig'adi
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badge!,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            // Tanlash belgisi — oq
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, color: bg, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Imkoniyat qatori (oq star icon bilan) ─────────────────────────────
class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
