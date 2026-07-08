import 'package:hive/hive.dart';

part 'amal_model.g.dart';

@HiveType(typeId: 3)
class AmalModel extends HiveObject {
  @HiveField(0)
  final String kategoriyaName;

  @HiveField(1)
  final String amount;

  @HiveField(2)
  final int kategoriyaIconCode;

  @HiveField(3)
  final int kategoriyaColorValue;

  @HiveField(4)
  final String hisobName;

  @HiveField(5)
  final bool isKirim;

  @HiveField(6)
  final int timestamp;

  // Kartadan-kartaga (hisob→hisob) o'tkazma bo'lsa true.
  // Bunday amal neytral ko'rsatiladi va statistika/balansga ta'sir qilmaydi.
  @HiveField(7)
  final bool isTransfer;

  AmalModel({
    required this.kategoriyaName,
    required this.amount,
    required this.kategoriyaIconCode,
    required this.kategoriyaColorValue,
    required this.hisobName,
    required this.isKirim,
    required this.timestamp,
    this.isTransfer = false,
  });
}
