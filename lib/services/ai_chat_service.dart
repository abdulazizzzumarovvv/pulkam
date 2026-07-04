import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulkam/config/api_keys.dart';

/// Chat xabari (GPT tarixiga yuboriladi)
class AiXabar {
  final bool isUser;
  final String text;
  const AiXabar(this.isUser, this.text);
}

/// GPT bilan moliyaviy chat — faqat finance mavzusida javob beradi.
/// [malumot] — userning real statistikasi (balans, xarajatlar, qarzlar...).
Future<String?> aiChatJavob({
  required List<AiXabar> tarix,
  required String malumot,
  required String til,
  String ism = '',
}) async {
  final tilNomi = switch (til) {
    'ru' => 'Russian',
    'en' => 'English',
    _ => 'Uzbek',
  };

  final systemPrompt = '''
You are PulKam's built-in personal finance advisor. PulKam is a personal expense tracking app.
${ism.isNotEmpty ? "The user's name is $ism — address them by name warmly when appropriate." : ''}

USER'S REAL FINANCIAL DATA (current, from the app):
$malumot

STRICT RULES:
1. ALWAYS respond in $tilNomi, regardless of the question's language.
2. Greetings and light small talk ARE allowed: reply warmly and steer to finances. E.g. to "Salom" reply like "Salom${ism.isNotEmpty ? ' $ism' : ''}! Finanslaringizni hisoblashga tayyormisiz? 💰" (in $tilNomi). Also fine: "rahmat", "qalaysan", "xayr" — answer briefly and kindly.
3. For SUBSTANTIVE non-finance questions (politics, coding, recipes, homework...), politely refuse in one short sentence meaning "Sorry, I can only give financial advice" in $tilNomi — nothing more.
4. Base advice on the USER'S REAL DATA above. Reference concrete numbers and category names from it.
5. Analysis approach:
   - Show where most money goes (top categories) and estimate where spending can realistically be cut (suggest ~10-20% cuts with resulting monthly savings).
   - Give practical money-saving tips tied to their top categories.
   - Give simple, safe money-growing suggestions (emergency fund, saving % of income). No risky investment advice, no specific stocks/crypto.
   - If the user HAS active debts: prioritize advice on paying them off faster (snowball/avalanche, how many months at current pace, what to cut to speed up).
   - If NO debts: focus on reaching their goals faster (how much/month is needed, when they'll reach each goal at current pace, what to trim to accelerate).
6. FORMAT — beautiful plain text (rendered in a mobile chat bubble):
   - Short sections separated by blank lines, relevant emojis (📊 💰 💡 🎯 ⚠️), bullet lines starting with "•".
   - NO markdown symbols: no **, no ##, no tables.
   - Keep answers compact: max ~180 words unless a full analysis is requested.
7. Format numbers with thousands separators (e.g. 1 700 000).''';

  final messages = <Map<String, String>>[
    {'role': 'system', 'content': systemPrompt},
    for (final x in tarix)
      {'role': x.isUser ? 'user' : 'assistant', 'content': x.text},
  ];

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
            'temperature': 0.4,
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) return null;
    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    return (data['choices'][0]['message']['content'] as String).trim();
  } catch (_) {
    return null;
  }
}
