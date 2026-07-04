import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/profile/logic/profile_cubit.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/hisoblar/qarzlar_tab/logic/qarz_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/services/ai_chat_service.dart';
import 'package:pulkam/l10n.dart';

const _kOltin = Color(0xFFD4AF37);
const _kOltinOchiq = Color(0xFFF5D061);

/// GPT asosidagi moliyaviy maslahatchi chat.
/// Ochilganda avtomatik to'liq tahlil qiladi.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // GPT tarixi (yashirin birinchi so'rov ham kiradi)
  final List<AiXabar> _tarix = [];
  // Ekranda ko'rinadigan xabarlar
  final List<AiXabar> _korinadigan = [];
  bool _yozmoqda = false;
  bool _boshlandi = false;

  static const _tarixKey = 'ai_chat_tarix';
  static const _tahlilFlagKey = 'ai_tahlil_qilingan';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_boshlandi) {
      _boshlandi = true;
      _tarixniYukla();
      final box = Hive.box('settings');
      final tahlilQilingan =
          box.get(_tahlilFlagKey) as bool? ?? false;
      if (!tahlilQilingan) {
        // Avto-tahlil FAQAT birinchi ochilishda — keyin faqat user so'rasa
        box.put(_tahlilFlagKey, true);
        _yubor(
          'Provide a full, friendly analysis of my current finances: where most '
          'money goes, where I can cut, saving and money-growing tips, and debt '
          'payoff advice if I have debts, otherwise goal advice.',
          korsat: false,
        );
      } else {
        _pastgaScroll();
      }
    }
  }

  // ── Chat tarixi: Hive'dan yuklash / saqlash ─────────────────────────
  void _tarixniYukla() {
    final saqlangan =
        Hive.box('settings').get(_tarixKey) as String?;
    if (saqlangan == null) return;
    try {
      final list = jsonDecode(saqlangan) as List;
      for (final e in list) {
        final x = AiXabar(e['u'] as bool, e['t'] as String);
        _korinadigan.add(x);
        _tarix.add(x);
      }
    } catch (_) {}
  }

  void _tarixniSaqla() {
    final list = _korinadigan
        .map((x) => {'u': x.isUser, 't': x.text})
        .toList();
    Hive.box('settings').put(_tarixKey, jsonEncode(list));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _pastgaScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Userning real ma'lumotlarini GPT uchun tayyorlash ───────────────
  String _malumotYig() {
    final soz = context.read<SozlamalarCubit>().state;
    final valyuta = soz.valyutaKod;
    final buf = StringBuffer();

    // Hisoblar
    final hisoblar = context.read<HisobCubit>().state.hisoblar;
    double jamiBalans = 0;
    buf.writeln('ACCOUNTS:');
    for (final h in hisoblar) {
      final b = double.tryParse(h.balance) ?? 0;
      jamiBalans += b;
      buf.writeln('- ${h.name}: ${b.toStringAsFixed(0)} $valyuta');
    }
    buf.writeln('Total balance: ${jamiBalans.toStringAsFixed(0)} $valyuta');

    // Oxirgi 30 kun amallar
    final now = DateTime.now().millisecondsSinceEpoch;
    final kun30 = now - 30 * 24 * 60 * 60 * 1000;
    final amallar = context
        .read<AmalCubit>()
        .state
        .amallar
        .where((a) => a.timestamp >= kun30)
        .toList();
    double kirim = 0, chiqim = 0;
    final katMap = <String, double>{};
    for (final a in amallar) {
      final v = double.tryParse(a.amount) ?? 0;
      if (a.isKirim) {
        kirim += v;
      } else {
        chiqim += v;
        katMap[a.kategoriyaName] = (katMap[a.kategoriyaName] ?? 0) + v;
      }
    }
    buf.writeln('\nLAST 30 DAYS:');
    buf.writeln('Income: ${kirim.toStringAsFixed(0)} $valyuta');
    buf.writeln('Expenses: ${chiqim.toStringAsFixed(0)} $valyuta');
    if (katMap.isNotEmpty) {
      buf.writeln('Expenses by category (descending):');
      final sorted = katMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        final pct = chiqim > 0 ? (e.value / chiqim * 100).round() : 0;
        buf.writeln(
            '- ${e.key}: ${e.value.toStringAsFixed(0)} $valyuta ($pct%)');
      }
    } else {
      buf.writeln('No expense records in the last 30 days.');
    }

    // Aktiv qarzlar
    final qarzlar = context
        .read<QarzCubit>()
        .state
        .qarzlar
        .where((q) => !q.bajarilgan)
        .toList();
    if (qarzlar.isEmpty) {
      buf.writeln('\nDEBTS: none');
    } else {
      buf.writeln('\nACTIVE DEBTS:');
      for (final q in qarzlar) {
        final turi = q.isQarzBerdim ? 'lent to' : 'owed to';
        buf.writeln(
            '- $turi ${q.personName}: remaining ${q.remaining.toStringAsFixed(0)} $valyuta');
      }
    }

    // Aktiv maqsadlar
    final maqsadlar = context
        .read<MaqsadCubit>()
        .state
        .maqsadlar
        .where((m) => !m.bajarilgan)
        .toList();
    if (maqsadlar.isEmpty) {
      buf.writeln('\nGOALS: none');
    } else {
      buf.writeln('\nACTIVE GOALS:');
      for (final m in maqsadlar) {
        buf.writeln(
            '- ${m.name}: saved ${m.balance} of ${m.target} $valyuta (${(m.progress * 100).round()}%)');
      }
    }

    return buf.toString();
  }

  // ── Xabar yuborish ──────────────────────────────────────────────────
  Future<void> _yubor(String matn, {bool korsat = true}) async {
    final q = matn.trim();
    if (q.isEmpty || _yozmoqda) return;
    _inputCtrl.clear();

    final xabar = AiXabar(true, q);
    setState(() {
      _tarix.add(xabar);
      if (korsat) _korinadigan.add(xabar);
      _yozmoqda = true;
    });
    _pastgaScroll();
    _tarixniSaqla();

    final profil = context.read<ProfileCubit>().state;
    final ism = profil.profile?.fullName ?? profil.name ?? '';

    final javob = await aiChatJavob(
      tarix: _tarix,
      malumot: _malumotYig(),
      til: context.l10n.lang,
      ism: ism,
    );
    if (!mounted) return;

    final aiMatn = javob ?? context.l10n.ovozXato;
    setState(() {
      final aiXabar = AiXabar(false, aiMatn);
      _tarix.add(aiXabar);
      _korinadigan.add(aiXabar);
      _yozmoqda = false;
    });
    _pastgaScroll();
    _tarixniSaqla();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bg = context.watch<SozlamalarCubit>().state.mavzuRang;

    // Hint chiplar: qarz bor — qarz hinta, yo'q — maqsad hinta
    final qarzBor = context
        .watch<QarzCubit>()
        .state
        .qarzlar
        .any((q) => !q.bajarilgan);
    final chips = [
      l10n.aiHintXarajat,
      l10n.aiHintTejash,
      l10n.aiHintKopaytirish,
      qarzBor ? l10n.aiHintQarz : l10n.aiHintMaqsad,
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_kOltinOchiq, _kOltin]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.aiSarlavha,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Xabarlar ───────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _korinadigan.length + (_yozmoqda ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _korinadigan.length) return _yozmoqdaBubble();
                  return _bubble(_korinadigan[i]);
                },
              ),
            ),

            // ── Hint chiplar ───────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _yubor(chips[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _kOltin.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      chips[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Input ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _yubor,
                        decoration: InputDecoration(
                          hintText: l10n.aiYozing,
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _yubor(_inputCtrl.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        gradient:
                            LinearGradient(colors: [_kOltinOchiq, _kOltin]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(AiXabar x) {
    return Align(
      alignment: x.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: x.isUser
              ? const LinearGradient(colors: [_kOltinOchiq, _kOltin])
              : null,
          color: x.isUser ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(x.isUser ? 18 : 4),
            bottomRight: Radius.circular(x.isUser ? 4 : 18),
          ),
        ),
        child: Text(
          x.text,
          style: TextStyle(
            color: x.isUser ? const Color(0xFF3E320A) : Colors.white,
            fontSize: 14,
            fontWeight: x.isUser ? FontWeight.w600 : FontWeight.w400,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _yozmoqdaBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => _Dot(delay: i * 200)),
          ),
        ),
      ),
    );
  }
}

// "Yozmoqda..." animatsiyali nuqta
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.25, end: 1.0).animate(_ctrl),
      child: const CircleAvatar(radius: 3, backgroundColor: _kOltin),
    );
  }
}
