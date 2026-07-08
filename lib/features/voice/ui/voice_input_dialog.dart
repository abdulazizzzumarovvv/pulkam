import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/kategoriya/logic/kategoriya_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/services/ai_voice_service.dart';
import 'package:pulkam/l10n.dart';

const _kOltin = Color(0xFFD4AF37);
const _kOltinOchiq = Color(0xFFF5D061);

/// Ovoz dialogi ochiqmi — floating mikrofon shu payt yashirinadi
final ValueNotifier<bool> voiceDialogOchiq = ValueNotifier(false);

/// Ovoz orqali kirim-chiqim qo'shish dialogi (Pro).
Future<void> showVoiceInputDialog(BuildContext context) async {
  if (voiceDialogOchiq.value) return; // ikki marta ochilmasin
  voiceDialogOchiq.value = true;
  try {
    await _showVoiceDialogIchki(context);
  } finally {
    voiceDialogOchiq.value = false;
  }
}

Future<void> _showVoiceDialogIchki(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Ovoz',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim, _) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<AmalCubit>()),
        BlocProvider.value(value: context.read<HisobCubit>()),
        BlocProvider.value(value: context.read<KategoriyaCubit>()),
        BlocProvider.value(value: context.read<SozlamalarCubit>()),
      ],
      child: const _VoiceDialog(),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

enum _Holat { tinglash, tahlil, muvaffaqiyat }

class _VoiceDialog extends StatefulWidget {
  const _VoiceDialog();

  @override
  State<_VoiceDialog> createState() => _VoiceDialogState();
}

class _VoiceDialogState extends State<_VoiceDialog>
    with SingleTickerProviderStateMixin {
  final _speech = SpeechToText();
  late final AnimationController _pulse;
  _Holat _holat = _Holat.tinglash;
  String _matn = '';
  String _natijaMatn = ''; // muvaffaqiyat xulosasi
  bool _ishlangan = false; // ikki marta process bo'lmasin

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boshla());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _speech.cancel();
    super.dispose();
  }

  String get _localeId {
    switch (context.l10n.lang) {
      case 'ru':
        return 'ru-RU';
      case 'en':
        return 'en-US';
      default:
        return 'uz-UZ';
    }
  }

  Future<void> _boshla() async {
    // Tahlil FAQAT user mikrofonni qayta bosganda boshlanadi —
    // shuning uchun status/error da avtomatik ishlov yo'q.
    final ok = await _speech.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
    if (!mounted) return;
    if (!ok) {
      _yopVaKorsat(context.l10n.ovozRuxsatYoq, yoriqnoma: false);
      return;
    }

    // Ilova tiliga mos locale: qurilma ro'yxatida aniq mosi bo'lsa — o'sha,
    // yaqin varianti bo'lsa — o'sha; topilmasa ham baribir so'ralgan tilni
    // majburan beramiz (Google STT ro'yxatda bo'lmasa ham ko'pincha qabul qiladi).
    String localeId = _localeId;
    try {
      String norm(String s) => s.replaceAll('_', '-').toLowerCase();
      final locales = await _speech.locales();
      final target = norm(_localeId);
      final prefix = target.split('-').first;
      final exact =
          locales.where((l) => norm(l.localeId) == target).firstOrNull;
      final oxshash = locales
          .where((l) => norm(l.localeId).startsWith(prefix))
          .firstOrNull;
      localeId = (exact ?? oxshash)?.localeId ?? _localeId;
    } catch (_) {
      localeId = _localeId;
    }
    if (!mounted) return;

    _speech.listen(
      // Eski parametr deprecated bo'lsa ham ba'zi qurilmalarda faqat shu
      // ishlaydi — ikkala usulda ham beramiz.
      // ignore: deprecated_member_use
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        partialResults: true,
        pauseFor: const Duration(seconds: 8),
        listenFor: const Duration(seconds: 60),
      ),
      onResult: (result) {
        if (!mounted) return;
        // Faqat matnni yig'amiz — tahlil mikrofon bosilganda
        setState(() => _matn = result.recognizedWords);
      },
    );
  }

  // ── Matnni GPT'ga yuborib amalga aylantirish ────────────────────────
  Future<void> _ishla() async {
    if (_ishlangan || !mounted) return;
    _ishlangan = true;
    _speech.stop();

    final l10n = context.l10n;
    final matn = _matn.trim();
    if (matn.isEmpty) {
      _yopVaKorsat(l10n.ovozTushunmadim);
      return;
    }

    setState(() => _holat = _Holat.tahlil);

    final kategoriyalar = context
        .read<KategoriyaCubit>()
        .state
        .kategoriyalar
        .map((k) =>
            (name: k.name, display: k.displayName(l10n), turi: k.turi))
        .toList();
    final hisoblar = context.read<HisobCubit>().state.hisoblar;

    final natija = await parseVoiceText(
      text: matn,
      kategoriyalar: kategoriyalar,
      hisoblar: hisoblar.map((h) => h.name).toList(),
    );
    if (!mounted) return;

    if (!natija.ok) {
      switch (natija.sabab) {
        case 'kategoriya':
          _yopVaKorsat(l10n.ovozKatTopilmadi);
        case 'xato':
          _yopVaKorsat(l10n.ovozXato, yoriqnoma: false);
        default:
          _yopVaKorsat(l10n.ovozTushunmadim);
      }
      return;
    }

    // Kategoriyani topish — asl nom yoki tarjima nomi bo'yicha
    final katListasi = context.read<KategoriyaCubit>().state.kategoriyalar;
    final izlangan = natija.kategoriyaName.toLowerCase();
    final kat = katListasi
        .where((k) =>
            k.name.toLowerCase() == izlangan ||
            k.displayName(l10n).toLowerCase() == izlangan)
        .firstOrNull;
    if (kat == null) {
      _yopVaKorsat(l10n.ovozKatTopilmadi);
      return;
    }

    // Hisobni topish: aytilgan bo'lsa — o'sha,
    // aks holda eng katta balansli hisob
    HisobModel? hisob;
    if (natija.hisobName != null) {
      hisob = hisoblar
          .where((h) =>
              h.name.toLowerCase() == natija.hisobName!.toLowerCase())
          .firstOrNull;
    }
    if (hisob == null && hisoblar.isNotEmpty) {
      hisob = hisoblar.reduce((a, b) =>
          (double.tryParse(a.balance) ?? 0) >=
                  (double.tryParse(b.balance) ?? 0)
              ? a
              : b);
    }
    if (hisob == null) {
      _yopVaKorsat(l10n.ovozXato, yoriqnoma: false);
      return;
    }

    // Chiqimda balans tekshiruvi
    final bal = double.tryParse(hisob.balance) ?? 0;
    if (!natija.isKirim && natija.summa > bal) {
      _yopVaKorsat(l10n.ovozBalansYetmaydi, yoriqnoma: false);
      return;
    }

    // Saqlash — kirim_chiqim_sheet bilan bir xil tartibda
    final newBal =
        natija.isKirim ? bal + natija.summa : bal - natija.summa;
    context.read<HisobCubit>().updateHisob(
          hisob,
          HisobModel(
            name: hisob.name,
            balance: newBal.toStringAsFixed(2),
            iconCode: hisob.iconCode,
            colorValue: hisob.colorValue,
            defaultKey: hisob.defaultKey,
          ),
        );
    context.read<AmalCubit>().addAmal(
          AmalModel(
            kategoriyaName: kat.name,
            amount: natija.summa.toStringAsFixed(2),
            kategoriyaIconCode: kat.iconCode,
            kategoriyaColorValue: kat.colorValue,
            hisobName: hisob.name,
            isKirim: natija.isKirim,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // Muvaffaqiyat holati — qisqa ko'rsatib avto-yopish
    final fmtKod = context.read<SozlamalarCubit>().state.formatKod;
    final valyuta = context.read<SozlamalarCubit>().state.valyutaKod;
    final belgi = natija.isKirim ? '+' : '−';
    setState(() {
      _holat = _Holat.muvaffaqiyat;
      _natijaMatn =
          '${kat.displayName(l10n)}  $belgi${appFmt(natija.summa, fmtKod)} $valyuta';
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // Ovoz dialogini yopib, sabab + yo'riqnoma dialogini ko'rsatish
  void _yopVaKorsat(String sarlavha, {bool yoriqnoma = true}) {
    if (!mounted) return;
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    final bg = context.read<SozlamalarCubit>().state.mavzuRang;
    Navigator.pop(context);
    _korsatYoriqnoma(rootCtx, bg, sarlavha, yoriqnoma);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bg = context.watch<SozlamalarCubit>().state.mavzuRang;

    final (String holatMatn, Widget doira) = switch (_holat) {
      _Holat.tinglash => (
          _matn.isEmpty ? l10n.ovozGapiring : _matn,
          _micDoira(),
        ),
      _Holat.tahlil => (
          _matn.isEmpty ? l10n.ovozTahlil : '«$_matn»\n${l10n.ovozTahlil}',
          _spinnerDoira(),
        ),
      _Holat.muvaffaqiyat => (
          '${l10n.ovozQoshildi}\n$_natijaMatn',
          _checkDoira(),
        ),
    };

    return Stack(
      children: [
        // Blur orqa fon
        Positioned.fill(
          child: GestureDetector(
            onTap: _holat == _Holat.tinglash
                ? () {
                    _speech.cancel();
                    Navigator.pop(context);
                  }
                : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: bg.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),

        // O'rtada: dumaloq mikrofon + matn
        Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                doira,
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    holatMatn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                // Ko'rsatma: gapirib bo'lgach mikrofonni bosish kerak
                if (_holat == _Holat.tinglash) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      l10n.ovozBosing,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tinglash: pulsatsiyalanuvchi oltin doira + mikrofon ─────────────
  Widget _micDoira() {
    return GestureDetector(
      // Bosilsa — tinglashni to'xtatib darhol tahlil
      onTap: _ishla,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          final t = _pulse.value;
          return Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kOltinOchiq, _kOltin],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kOltin.withValues(alpha: 0.35 + 0.25 * t),
                  blurRadius: 24 + 20 * t,
                  spreadRadius: 2 + 8 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 48),
      ),
    );
  }

  // ── Tahlil: spinner ─────────────────────────────────────────────────
  Widget _spinnerDoira() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(34),
      child: const CircularProgressIndicator(
        color: _kOltin,
        strokeWidth: 3,
      ),
    );
  }

  // ── Muvaffaqiyat: yashil check ──────────────────────────────────────
  Widget _checkDoira() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
    );
  }
}

// ── Yo'riqnoma dialogi: sabab + qanday gapirish kerak ─────────────────
void _korsatYoriqnoma(
  BuildContext context,
  Color bg,
  String sarlavha,
  bool yoriqnoma,
) {
  final kCard = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
  final l10n = context.l10n;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => Dialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kOltin.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.mic_off_rounded, color: _kOltin, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sarlavha,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            if (yoriqnoma) ...[
              const SizedBox(height: 16),
              Text(
                l10n.ovozYoriqnoma,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
            ],
            const SizedBox(height: 20),
            // OK — oq tugma
            GestureDetector(
              onTap: () => Navigator.pop(dialogCtx),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    l10n.tushunarli,
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
