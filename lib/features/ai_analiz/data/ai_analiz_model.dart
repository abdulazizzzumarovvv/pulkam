import 'package:hive/hive.dart';

part 'ai_analiz_model.g.dart';

@HiveType(typeId: 6)
class AiAnalizModel extends HiveObject {
  @HiveField(0)
  final String result;

  @HiveField(1)
  final int timestamp;

  AiAnalizModel({required this.result, required this.timestamp});
}
