import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'maqsad_model.g.dart';

@HiveType(typeId: 1)
class MaqsadModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String balance;

  @HiveField(2)
  final String target;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final int completedAt; // bajarilgan sana (ms), 0 = bajarilmagan

  MaqsadModel({
    required this.name,
    required this.balance,
    required this.target,
    required this.iconCode,
    required this.colorValue,
    this.isCompleted = false,
    this.completedAt = 0,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  double get progress {
    final current = double.tryParse(balance) ?? 0;
    final goal = double.tryParse(target) ?? 1;
    return (current / goal).clamp(0.0, 1.0);
  }

  bool get bajarilgan => progress >= 1.0;
}
