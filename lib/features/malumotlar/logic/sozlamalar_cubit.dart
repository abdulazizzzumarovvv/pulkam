import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Raqam formatlash ─────────────────────────────────────────────────────────
// formatKod: 'comma_dot' | 'space_dot' | 'dot_comma' | 'space_comma' | 'none_dot'
String appFmt(double v, String formatKod) {
  final abs = v.abs();
  final intPart = abs.truncate();
  final decPart = ((abs - intPart) * 100).round();
  final intStr = intPart.toString();

  String groupSep;
  String decSep;
  switch (formatKod) {
    case 'space_dot':
      groupSep = ' ';
      decSep = '.';
      break;
    case 'dot_comma':
      groupSep = '.';
      decSep = ',';
      break;
    case 'space_comma':
      groupSep = ' ';
      decSep = ',';
      break;
    case 'none_dot':
      groupSep = '';
      decSep = '.';
      break;
    case 'comma_dot':
    default:
      groupSep = ',';
      decSep = '.';
  }

  final buf = StringBuffer();
  for (int i = 0; i < intStr.length; i++) {
    if (i > 0 && (intStr.length - i) % 3 == 0 && groupSep.isNotEmpty) {
      buf.write(groupSep);
    }
    buf.write(intStr[i]);
  }
  final dec = decPart.toString().padLeft(2, '0');
  return '${buf.toString()}$decSep$dec';
}

class ReminderItem {
  final bool enabled;
  final int hour;
  final int minute;
  const ReminderItem({this.enabled = false, this.hour = 9, this.minute = 0});
  ReminderItem copyWith({bool? enabled, int? hour, int? minute}) =>
      ReminderItem(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

class SozlamalarState {
  final Color mavzuRang;
  final bool pinCode;
  final bool bildirishnomalar;
  final String valyutaKod;
  final String formatKod;
  final String pinValue;
  final String tilKod;
  final bool isPro;
  final bool widgetYoniq;
  final List<ReminderItem> reminders;

  const SozlamalarState({
    this.mavzuRang = const Color(0xFF13111F),
    this.pinCode = false,
    this.bildirishnomalar = true,
    this.valyutaKod = 'UZS',
    this.formatKod = 'comma_dot',
    this.pinValue = '',
    this.tilKod = '',
    this.isPro = false,
    this.widgetYoniq = false,
    this.reminders = const [
      ReminderItem(enabled: false, hour: 9,  minute: 0),
      ReminderItem(enabled: false, hour: 14, minute: 0),
      ReminderItem(enabled: false, hour: 21, minute: 0),
    ],
  });

  SozlamalarState copyWith({
    Color? mavzuRang,
    bool? pinCode,
    bool? bildirishnomalar,
    String? valyutaKod,
    String? formatKod,
    String? pinValue,
    String? tilKod,
    bool? isPro,
    bool? widgetYoniq,
    List<ReminderItem>? reminders,
  }) =>
      SozlamalarState(
        mavzuRang: mavzuRang ?? this.mavzuRang,
        pinCode: pinCode ?? this.pinCode,
        bildirishnomalar: bildirishnomalar ?? this.bildirishnomalar,
        valyutaKod: valyutaKod ?? this.valyutaKod,
        formatKod: formatKod ?? this.formatKod,
        pinValue: pinValue ?? this.pinValue,
        tilKod: tilKod ?? this.tilKod,
        isPro: isPro ?? this.isPro,
        widgetYoniq: widgetYoniq ?? this.widgetYoniq,
        reminders: reminders ?? this.reminders,
      );
}

class SozlamalarCubit extends Cubit<SozlamalarState> {
  static const _boxName = 'settings';
  static const _keyRang = 'mavzu_rang';
  static const _keyPin = 'pin_code';
  static const _keyBildirishnoma = 'bildirishnomalar';
  static const _keyValyuta = 'valyuta_kod';
  static const _keyFormat = 'format_kod';
  static const _keyPinValue = 'pin_value';
  static const _keyTil = 'til_kod';
  static const _keyPro = 'is_pro';
  static const _keyWidget = 'widget_yoniq';
  static const _keyProPlan = 'pro_plan'; // 'umrbod' | 'yillik' | 'oylik'
  static const _keyProExpiry = 'pro_expiry'; // millis, umrbodda yo'q
  static const keyProExpiredPending = 'pro_expired_pending';
  // reminder_N_enabled / reminder_N_hour / reminder_N_minute
  static String _rKey(int i, String f) => 'reminder_${i}_$f';

  SozlamalarCubit() : super(const SozlamalarState()) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    final rangVal = box.get(_keyRang) as int?;
    final pin = box.get(_keyPin) as bool? ?? false;
    final bildirishnoma = box.get(_keyBildirishnoma) as bool? ?? true;
    final valyuta = box.get(_keyValyuta) as String? ?? 'UZS';
    final format = box.get(_keyFormat) as String? ?? 'comma_dot';
    final pinVal = box.get(_keyPinValue) as String? ?? '';
    final til = box.get(_keyTil) as String? ?? '';
    var pro = true; // TEST: vaqtincha Pro yoqilgan (mikrofonni ko'rish uchun) — QAYTARISH KERAK: box.get(_keyPro) as bool? ?? false;
    final widgetYoniq = box.get(_keyWidget) as bool? ?? false;
    // Obuna muddati tugaganmi? (umrbodda expiry saqlanmaydi)
    final expiry = box.get(_keyProExpiry) as int?;
    if (pro &&
        expiry != null &&
        DateTime.now().millisecondsSinceEpoch > expiry) {
      pro = false;
      box.put(_keyPro, false);
      box.delete(_keyProExpiry);
      box.delete(_keyProPlan);
      // Bir martalik "obuna tugadi" dialogi uchun belgi
      box.put(keyProExpiredPending, true);
    }
    final defaults = const SozlamalarState().reminders;
    final reminders = List.generate(3, (i) => ReminderItem(
      enabled: box.get(_rKey(i, 'enabled')) as bool? ?? defaults[i].enabled,
      hour:    box.get(_rKey(i, 'hour'))    as int?  ?? defaults[i].hour,
      minute:  box.get(_rKey(i, 'minute'))  as int?  ?? defaults[i].minute,
    ));
    emit(state.copyWith(
      mavzuRang: rangVal != null ? Color(rangVal) : const Color(0xFF13111F),
      pinCode: pin,
      bildirishnomalar: bildirishnoma,
      valyutaKod: valyuta,
      formatKod: format,
      pinValue: pinVal,
      tilKod: til,
      isPro: pro,
      widgetYoniq: widgetYoniq,
      reminders: reminders,
    ));
  }

  void setWidgetYoniq(bool val) {
    Hive.box(_boxName).put(_keyWidget, val);
    emit(state.copyWith(widgetYoniq: val));
  }

  void setPro(bool val) {
    Hive.box(_boxName).put(_keyPro, val);
    emit(state.copyWith(isPro: val));
  }

  /// Pro'ni tarif bo'yicha faollashtirish:
  /// umrbod — muddatsiz, yillik — 365 kun, oylik — 30 kun.
  void activatePro(String plan) {
    final box = Hive.box(_boxName);
    box.put(_keyPro, true);
    box.put(_keyProPlan, plan);
    switch (plan) {
      case 'oylik':
        box.put(_keyProExpiry,
            DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch);
      case 'yillik':
        box.put(_keyProExpiry,
            DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch);
      default: // umrbod
        box.delete(_keyProExpiry);
    }
    emit(state.copyWith(isPro: true));
  }

  void setTil(String kod) {
    Hive.box(_boxName).put(_keyTil, kod);
    emit(state.copyWith(tilKod: kod));
  }

  void setValyuta(String kod) {
    Hive.box(_boxName).put(_keyValyuta, kod);
    emit(state.copyWith(valyutaKod: kod));
  }

  void setFormat(String kod) {
    Hive.box(_boxName).put(_keyFormat, kod);
    emit(state.copyWith(formatKod: kod));
  }

  void setMavzuRang(Color color) {
    Hive.box(_boxName).put(_keyRang, color.toARGB32());
    emit(state.copyWith(mavzuRang: color));
  }

  void setPinCode(bool val) {
    final box = Hive.box(_boxName);
    box.put(_keyPin, val);
    if (!val) {
      box.delete(_keyPinValue);
      emit(state.copyWith(pinCode: false, pinValue: ''));
    } else {
      emit(state.copyWith(pinCode: true));
    }
  }

  void savePinValue(String pin) {
    Hive.box(_boxName).put(_keyPinValue, pin);
    emit(state.copyWith(pinValue: pin));
  }

  void setBildirishnomalar(bool val) {
    Hive.box(_boxName).put(_keyBildirishnoma, val);
    emit(state.copyWith(bildirishnomalar: val));
  }

  Future<void> setReminder(int index, ReminderItem item) async {
    final box = Hive.box(_boxName);
    await box.put(_rKey(index, 'enabled'), item.enabled);
    await box.put(_rKey(index, 'hour'),    item.hour);
    await box.put(_rKey(index, 'minute'),  item.minute);
    final updated = List<ReminderItem>.from(state.reminders);
    updated[index] = item;
    emit(state.copyWith(reminders: updated));
  }
}
