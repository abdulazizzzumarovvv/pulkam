import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/data/hisob_model.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/kategoriya/logic/kategoriya_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/services/ai_voice_service.dart';
import 'package:pulkam/services/whisper_service.dart';
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
  final _recorder = AudioRecorder();
  late final AnimationController _pulse;
  _Holat _holat = _Holat.tinglash;
  String _matn = '';
  String _natijaMatn = ''; // muvaffaqiyat xulosasi
  bool _ishlangan = false; // ikki marta process bo'lmasin
  bool _yozilyapti = false;
  String? _audioPath;

  // Jimlik bo'yicha avto-to'xtash uchun
  StreamSubscription<Amplitude>? _ampSub;
  Timer? _jimlikTimer; // gapirmasa 2s dan keyin avto-stop
  bool _ovozKeldi = false; // hech bo'lmasa bir marta ovoz kelganmi

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
    _ampSub?.cancel();
    _jimlikTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // Ilova tili — Whisper'ga aniqlik uchun beriladi
  String get _lang {
    switch (context.l10n.lang) {
      case 'ru':
        return 'ru';
      case 'en':
        return 'en';
      default:
        return 'uz';
    }
  }

  Future<void> _boshla() async {
    // Mikrofon ruxsati
    final ruxsat = await _recorder.hasPermission();
    if (!mounted) return;
    if (!ruxsat) {
      _yopVaKorsat(context.l10n.ovozRuxsatYoq, yoriqnoma: false);
      return;
    }

    // Yozib olinadigan fayl yo'li
    final dir = await getTemporaryDirectory();
    _audioPath =
        '${dir.path}/pulkam_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    if (!mounted) return;

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _audioPath!,
      );
      _yozilyapti = true;
      _yozishBoshi = DateTime.now();

      // Amplitude oqimi — jimlik bo'yicha avto-to'xtash
      _ampSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 200))
          .listen(_amplitude);
    } catch (_) {
      if (mounted) _yopVaKorsat(context.l10n.ovozXato, yoriqnoma: false);
    }
  }

  DateTime? _yozishBoshi;
  double _tinchlik = -45.0; // fon shovqini darajasi (moslashuvchan)

  void _amplitude(Amplitude amp) {
    if (!mounted || !_yozilyapti) return;

    final cur = amp.current; // dBFS: -160 (jim) … 0 (baland)
    // ignore: avoid_print
    print('PULKAM_AMP cur=$cur tinchlik=$_tinchlik ovozKeldi=$_ovozKeldi');
    // Fon shovqinini sekin moslashtiramiz (past qiymatlarda)
    if (cur < _tinchlik + 3) {
      _tinchlik = _tinchlik * 0.9 + cur * 0.1;
    }
    // Gapiryapti = fon shovqinidan sezilarli baland
    final gapiryapti = cur > _tinchlik + 12;

    // Kamida 1.5s yozilmaguncha avto-stop yo'q (raqamlarni aytishga vaqt)
    final otgan = _yozishBoshi == null
        ? 0
        : DateTime.now().difference(_yozishBoshi!).inMilliseconds;

    if (gapiryapti) {
      _ovozKeldi = true;
      _jimlikTimer?.cancel();
      _jimlikTimer = null;
    } else if (_ovozKeldi && _jimlikTimer == null && otgan > 1500) {
      // Gapirdi, keyin jim bo'ldi — 2s jimlikdan keyin avto-stop
      _jimlikTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted && _holat == _Holat.tinglash) _ishla();
      });
    }
  }

  // ── Yozishni to'xtatib, Whisper → GPT orqali amalga aylantirish ─────
  Future<void> _ishla() async {
    if (_ishlangan || !mounted) return;
    _ishlangan = true;
    _jimlikTimer?.cancel();
    await _ampSub?.cancel();

    final l10n = context.l10n;

    // Yozishni to'xtatamiz
    String? path;
    try {
      path = await _recorder.stop();
      _yozilyapti = false;
    } catch (_) {
      path = _audioPath;
    }
    if (!mounted) return;

    // ignore: avoid_print
    print('PULKAM_STOP path=$path exists=${path != null && File(path).existsSync()} '
        'size=${path != null && File(path).existsSync() ? File(path).lengthSync() : -1}');

    if (path == null || !File(path).existsSync()) {
      _yopVaKorsat(l10n.ovozTushunmadim);
      return;
    }

    // Tahlil holati — spinner
    setState(() => _holat = _Holat.tahlil);

    // 1-bosqich: Whisper — audio → matn
    final matn = (await transcribeAudio(path, langHint: _lang))?.trim() ?? '';
    // ignore: avoid_print
    print('PULKAM_WHISPER natija="$matn"');
    // Fayl endi kerak emas — o'chiramiz
    try {
      File(path).deleteSync();
    } catch (_) {}
    if (!mounted) return;

    if (matn.isEmpty) {
      _yopVaKorsat(l10n.ovozTushunmadim);
      return;
    }
    setState(() => _matn = matn);

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
        // Qorong'i orqa fon
        Positioned.fill(
          child: GestureDetector(
            onTap: _holat == _Holat.tinglash
                ? () async {
                    _jimlikTimer?.cancel();
                    await _ampSub?.cancel();
                    try {
                      await _recorder.stop();
                    } catch (_) {}
                    if (mounted) Navigator.pop(context);
                  }
                : null,
            child: Container(
              color: bg.withValues(alpha: 0.92),
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
