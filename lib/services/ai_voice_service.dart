import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulkam/config/api_keys.dart';

/// GPT tahlil natijasi
class VoiceParseResult {
  final bool ok;

  /// ok=false bo'lsa: 'kategoriya' | 'tushunmadim' | 'xato'
  final String sabab;
  final bool isKirim;
  final double summa;
  final String kategoriyaName; // ro'yxatdagi aniq nom
  final String? hisobName; // ro'yxatdagi aniq nom yoki null

  const VoiceParseResult({
    required this.ok,
    this.sabab = '',
    this.isKirim = false,
    this.summa = 0,
    this.kategoriyaName = '',
    this.hisobName,
  });
}

/// Ovozdan olingan matnni GPT orqali tahlil qiladi:
/// summa, kategoriya, kirim/chiqim va (aytilgan bo'lsa) hisobni ajratadi.
Future<VoiceParseResult> parseVoiceText({
  required String text,
  required List<({String name, String display, String turi})> kategoriyalar,
  required List<String> hisoblar,
}) async {
  final katRoyxat = kategoriyalar
      .map((k) => '- "${k.name}" (${k.turi}${k.display != k.name ? ', ya\'ni: ${k.display}' : ''})')
      .join('\n');
  final hisobRoyxat = hisoblar.map((h) => '"$h"').join(', ');

  final systemPrompt = '''
You are a highly accurate personal-finance voice command parser. The user dictates a transaction in Uzbek, Russian or English. Speech-to-text output may contain recognition errors — interpret generously by sound and meaning.

CATEGORIES (use the exact quoted name in your answer):
$katRoyxat

ACCOUNTS: $hisobRoyxat

OUTPUT — strict JSON, nothing else:
{"ok":true,"turi":"chiqim"|"kirim","summa":<number>,"kategoriya":"<exact category name>","hisob":"<exact account name or null>"}
{"ok":false,"sabab":"kategoriya"}  ← amount understood but no listed category fits the meaning
{"ok":false,"sabab":"tushunmadim"} ← not a transaction, or amount missing/unclear

AMOUNT RULES (critical):
- "ming"/"минг"/"тысяч"/"тыс"/"k"/"thousand" = ×1000 → "15 ming" = 15000, "besh yuz ming" = 500000
- "million"/"млн"/"миллион" = ×1000000 → "1.5 million" = 1500000
- Spelled numbers count: "o'n besh ming" = 15000, "yigirma ming" = 20000, "двадцать тысяч" = 20000
- CURRENCY WORDS ARE JUST LABELS — ignore them completely, NEVER convert. The user may say any currency name (so'm, sum, сум, dollar, dollars, доллар, euro, евро, rubl, рубль, USD, \$): the number stays as spoken. "1700 dollar" = 1700. "5 dollar" = 5. "100 ming so'm" = 100000.
- STT often garbles: "15000 so'm", "15 000", "o'n besh ming so'm" — all = 15000

CATEGORY MATCHING (semantic, tolerant to STT errors):
- kofe, kafe, choy, coffee, restoran, ovqatlanish tashqarida → "Kafe"
- non, sut, bozor, supermarket, do'kon, oziq, gruzinka, mahsulot → "Oziq-ovqat"
- metro, taksi, avtobus, benzin, yo'l, taxi, транспорт → "Transport"
- dori, apteka, shifokor, vrach, dorixona → "Salomatlik"
- kiyim, oyoq kiyim, futbolka, магазин одежды → "Kiyim"
- oila, bola, farzand → "Oila"
- oylik, maosh, зарплата, salary, ish haqi → income category
- avans, аванс → "Avans"; freelance, frilans, zakaz → "Freelance"
- Match by MEANING, not exact words. Only return sabab:"kategoriya" when truly nothing fits.

OTHER RULES:
- turi defaults to "chiqim". Use "kirim" only for clear income (oldim/keldi/kirim/получил/salary) or income-type categories.
- Chosen category's type MUST equal turi.
- "hisob": only when an account is explicitly named ("naqddan"/"kartadan"/"с карты") else null.

EXAMPLES:
"kofe 15 ming so'm" → {"ok":true,"turi":"chiqim","summa":15000,"kategoriya":"Kafe","hisob":null}
"transport 1700 dollar" → {"ok":true,"turi":"chiqim","summa":1700,"kategoriya":"Transport","hisob":null}
"kofe 5 dollar" → {"ok":true,"turi":"chiqim","summa":5,"kategoriya":"Kafe","hisob":null}
"metro 1700" → {"ok":true,"turi":"chiqim","summa":1700,"kategoriya":"Transport","hisob":null}
"non va sut 25 ming" → {"ok":true,"turi":"chiqim","summa":25000,"kategoriya":"Oziq-ovqat","hisob":null}
"оплатил такси двадцать тысяч" → {"ok":true,"turi":"chiqim","summa":20000,"kategoriya":"Transport","hisob":null}
"oylik keldi 5 million" → {"ok":true,"turi":"kirim","summa":5000000,"kategoriya":"Oylik","hisob":null}
"kartadan dori 40 ming" → {"ok":true,"turi":"chiqim","summa":40000,"kategoriya":"Salomatlik","hisob":"Karta"}
"salom qalaysan" → {"ok":false,"sabab":"tushunmadim"}''';

  try {
    final resp = await http
        .post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiApiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'temperature': 0,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': text},
            ],
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode != 200) {
      return const VoiceParseResult(ok: false, sabab: 'xato');
    }

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    final content =
        data['choices'][0]['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;

    if (parsed['ok'] != true) {
      final sabab = parsed['sabab'] as String? ?? 'tushunmadim';
      return VoiceParseResult(ok: false, sabab: sabab);
    }

    final summa = (parsed['summa'] as num?)?.toDouble() ?? 0;
    final kategoriya = parsed['kategoriya'] as String? ?? '';
    if (summa <= 0 || kategoriya.isEmpty) {
      return const VoiceParseResult(ok: false, sabab: 'tushunmadim');
    }

    return VoiceParseResult(
      ok: true,
      isKirim: parsed['turi'] == 'kirim',
      summa: summa,
      kategoriyaName: kategoriya,
      hisobName: parsed['hisob'] as String?,
    );
  } catch (_) {
    return const VoiceParseResult(ok: false, sabab: 'xato');
  }
}
