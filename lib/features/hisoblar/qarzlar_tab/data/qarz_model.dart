import 'package:hive/hive.dart';

part 'qarz_model.g.dart';

@HiveType(typeId: 4)
class QarzModel extends HiveObject {
  @HiveField(0)
  final String personName;

  @HiveField(1)
  final String amount;

  @HiveField(2)
  final String paid;

  @HiveField(3)
  final bool isQarzBerdim;

  @HiveField(4)
  final String hisobName;

  @HiveField(5)
  final int timestamp;

  @HiveField(6)
  final List<TolovModel> tolovlar;

  QarzModel({
    required this.personName,
    required this.amount,
    this.paid = '0',
    required this.isQarzBerdim,
    required this.hisobName,
    required this.timestamp,
    this.tolovlar = const [],
  });

  double get remaining =>
      (double.tryParse(amount) ?? 0) - (double.tryParse(paid) ?? 0);

  double get progress {
    final a = double.tryParse(amount) ?? 1;
    final p = double.tryParse(paid) ?? 0;
    if (a <= 0) return 0;
    return (p / a).clamp(0.0, 1.0);
  }

  // To'liq to'langan (bitgan) qarz
  bool get bajarilgan => (double.tryParse(amount) ?? 0) > 0 && remaining <= 0;

  // Bitgan sana — oxirgi to'lov vaqti (yo'q bo'lsa qarz sanasi)
  int get bitganSana {
    if (tolovlar.isEmpty) return timestamp;
    return tolovlar
        .map((t) => t.timestamp)
        .reduce((a, b) => a > b ? a : b);
  }
}

@HiveType(typeId: 5)
class TolovModel extends HiveObject {
  @HiveField(0)
  final String amount;

  @HiveField(1)
  final int timestamp;

  TolovModel({required this.amount, required this.timestamp});
}
