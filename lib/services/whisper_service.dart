// OpenAI Whisper — audio faylni matnga aylantiradi (barcha telefonlarda
// bir xil ishlaydi, o'zbek/rus/ingliz tilini yaxshi taniydi).
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pulkam/config/api_keys.dart';

/// Audio faylni Whisper orqali matnga aylantiradi.
/// [langHint] — 'uz' | 'ru' | 'en' (aniqlik uchun, majburiy emas).
/// Xato bo'lsa null qaytaradi.
Future<String?> transcribeAudio(String filePath, {String? langHint}) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final uri = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $openAiApiKey'
      ..fields['model'] = 'whisper-1'
      // Javob — faqat matn (JSON emas)
      ..fields['response_format'] = 'text'
      // Moliya konteksti — raqamlarni to'g'ri yozishga yordam beradi
      ..fields['prompt'] =
          'Moliyaviy amal: kategoriya va summa. Masalan: oziq-ovqat 1 million 556 ming, transport 15 ming so\'m, kafe 20000.'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    // Til ko'rsatilsa — aniqroq bo'ladi
    if (langHint != null && langHint.isNotEmpty) {
      req.fields['language'] = langHint;
    }

    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) return null;
    // response_format=text — tanadagi matnning o'zi
    final text = utf8.decode(resp.bodyBytes).trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
