// Home-screen widget bilan aloqa: ma'lumot yozish va deep-link'larni ushlash.
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

const String _androidWidgetName = 'PulkamWidgetProvider';

/// Widgetga ko'rsatiladigan ma'lumotlarni yozadi va yangilaydi.
Future<void> updateHomeWidget({
  required String balance,
  required String currency,
  required String balanceLabel,
  required String kirimText,
  required String chiqimText,
  required String voiceText,
  required Color themeColor,
  required bool isPro,
}) async {
  await HomeWidget.saveWidgetData<String>('balance', balance);
  await HomeWidget.saveWidgetData<String>('currency', currency);
  await HomeWidget.saveWidgetData<String>('balanceLabel', balanceLabel);
  await HomeWidget.saveWidgetData<String>('kirimText', kirimText);
  await HomeWidget.saveWidgetData<String>('chiqimText', chiqimText);
  await HomeWidget.saveWidgetData<String>('voiceText', voiceText);
  await HomeWidget.saveWidgetData<String>('themeColor', _hex(themeColor));
  await HomeWidget.saveWidgetData<bool>('isPro', isPro);
  await HomeWidget.updateWidget(androidName: _androidWidgetName);
}

/// Widgetni telefon bosh ekraniga qo'shishni so'raydi (Android 8+/qo'llab-quvvatlansa).
/// Muvaffaqiyatli chaqirilsa true (tizim dialogi chiqadi), xato bo'lsa false.
Future<bool> requestPinWidget() async {
  try {
    await HomeWidget.requestPinWidget(androidName: _androidWidgetName);
    return true;
  } catch (_) {
    return false;
  }
}

String _hex(Color c) {
  final argb = c.toARGB32();
  return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
