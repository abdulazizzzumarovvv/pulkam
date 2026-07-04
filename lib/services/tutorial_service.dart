import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pulkam/l10n.dart';

const _kOltin = Color(0xFFD4AF37);

/// Tutorial uchun global kalitlar — ekranlar o'z elementlariga o'rnatadi
class TutorialKeys {
  static final plus = GlobalKey(); // Amallar: + tugma
  static final avatar = GlobalKey(); // Amallar: profil avatari
  static final settings = GlobalKey(); // Amallar: sozlamalar tugmasi
  static final sheetKategoriya = GlobalKey(); // Sheet: kategoriya grid
  static final sheetKarta = GlobalKey(); // Sheet: karta tanlagich
  static final sheetKalkulyator = GlobalKey(); // Sheet: kalkulyator
}

/// MainScreen o'rnatadi: asosiy PageView'ni sahifaga o'tkazish
Future<void> Function(int page)? tutorialSahifaga;

/// Hisoblar o'rnatadi: tablarni birrov ko'rsatish (qarzlar → maqsadlar → hisoblar)
Future<void> Function()? tutorialTablarKorsat;

/// Tutorial rejimida sheet ochish uchun flag (kirim_chiqim_sheet o'qiydi)
bool tutorialSheetRejimi = false;

/// MainScreen o'rnatadi: turni qaytadan boshlash (settings "Yo'riqnoma"dan)
void Function()? tutorialQaytaBoshla;

// ── Bitta coach mark bosqichi ─────────────────────────────────────────
Future<bool> _coach(
  BuildContext context, {
  required GlobalKey key,
  required String matn,
  ContentAlign align = ContentAlign.bottom,
  ShapeLightFocus shape = ShapeLightFocus.RRect,
}) {
  final l10n = context.l10n;
  final completer = Completer<bool>(); // true = davom, false = skip

  TutorialCoachMark(
    targets: [
      TargetFocus(
        keyTarget: key,
        shape: shape,
        radius: 16,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: align,
            builder: (context, controller) => Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23212E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    matn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: controller.next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: _kOltin,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.tutKeyingi,
                          style: const TextStyle(
                            color: Color(0xFF3E320A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
    colorShadow: Colors.black,
    opacityShadow: 0.85,
    textSkip: l10n.tutOtkazish,
    onFinish: () {
      if (!completer.isCompleted) completer.complete(true);
    },
    onSkip: () {
      if (!completer.isCompleted) completer.complete(false);
      return true;
    },
  ).show(context: context, rootOverlay: true);

  return completer.future;
}

// ── Markaziy izoh kartasi (elementga bog'lanmagan bosqichlar) ─────────
Future<bool> showTutorialIzoh(
  BuildContext context,
  String matn, {
  bool yakuniy = false,
}) async {
  final l10n = context.l10n;
  bool davom = true;
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Tutorial',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, _) => Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF23212E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kOltin.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    matn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // O'tkazib yuborish (yakuniy bosqichda yo'q)
                      if (!yakuniy) ...[
                        GestureDetector(
                          onTap: () {
                            davom = false;
                            Navigator.pop(ctx);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            child: Text(
                              l10n.tutOtkazish,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Keyingi / Tushunarli
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 9),
                          decoration: BoxDecoration(
                            color: _kOltin,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            yakuniy ? l10n.tushunarli : l10n.tutKeyingi,
                            style: const TextStyle(
                              color: Color(0xFF3E320A),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  return davom;
}

Future<void> _kut(int ms) => Future.delayed(Duration(milliseconds: ms));

/// Sheet ichidagi 3 bosqich: kategoriya → karta → kalkulyator.
/// KirimChiqimSheet tutorial rejimida chaqiradi.
Future<void> showSheetTutorial(
  BuildContext context, {
  required String kategoriyaMatn,
  required String kartaMatn,
  required String kalkulyatorMatn,
}) async {
  if (!await _coach(context,
      key: TutorialKeys.sheetKategoriya, matn: kategoriyaMatn)) {
    return;
  }
  if (!context.mounted) return;
  if (!await _coach(context,
      key: TutorialKeys.sheetKarta,
      matn: kartaMatn,
      align: ContentAlign.top)) {
    return;
  }
  if (!context.mounted) return;
  await _coach(context,
      key: TutorialKeys.sheetKalkulyator,
      matn: kalkulyatorMatn,
      align: ContentAlign.top);
}

/// To'liq tutorial turi. [context] — MainScreen konteksti.
/// [sheetOch] — kirim-chiqim sheetini tutorial rejimida ochib, yopilishini kutadi.
Future<void> startTutorial(
  BuildContext context, {
  required Future<void> Function() sheetOch,
  required Future<void> Function() settingsOch,
}) async {
  // 1. "+" tugma
  if (!context.mounted) return;
  if (!await _coach(context,
      key: TutorialKeys.plus,
      matn: context.l10n.tutPlus,
      shape: ShapeLightFocus.Circle)) {
    return;
  }

  // 2. Sheet ichi (kategoriya → karta → kalkulyator) — sheet o'zi boshqaradi
  tutorialSheetRejimi = true;
  await sheetOch();
  tutorialSheetRejimi = false;

  // 3. Statistika sahifasi
  if (!context.mounted) return;
  await tutorialSahifaga?.call(0);
  await _kut(400);
  if (!context.mounted) return;
  if (!await showTutorialIzoh(context, context.l10n.tutStatistika)) {
    await tutorialSahifaga?.call(1);
    return;
  }

  // 4. Hisoblar sahifasi + tablar namoyishi
  await tutorialSahifaga?.call(2);
  await _kut(400);
  if (!context.mounted) return;
  if (!await showTutorialIzoh(context, context.l10n.tutHisoblar)) {
    await tutorialSahifaga?.call(1);
    return;
  }
  await tutorialTablarKorsat?.call();

  // 5. Asosiy sahifaga qaytish → sozlamalar
  await tutorialSahifaga?.call(1);
  await _kut(400);
  if (!context.mounted) return;
  if (!await _coach(context,
      key: TutorialKeys.settings,
      matn: context.l10n.tutSettings,
      shape: ShapeLightFocus.Circle)) {
    return;
  }
  await settingsOch();

  // 6. Profil avatari
  if (!context.mounted) return;
  if (!await _coach(context,
      key: TutorialKeys.avatar,
      matn: context.l10n.tutProfil,
      shape: ShapeLightFocus.Circle)) {
    return;
  }

  // 7. Birinchi kirim — "+" tugma yana
  if (!context.mounted) return;
  if (!await _coach(context,
      key: TutorialKeys.plus,
      matn: context.l10n.tutBirinchiKirim,
      shape: ShapeLightFocus.Circle)) {
    return;
  }

  // 8. Yakuniy xabar — support
  if (!context.mounted) return;
  await showTutorialIzoh(context, context.l10n.tutSupport, yakuniy: true);
}
