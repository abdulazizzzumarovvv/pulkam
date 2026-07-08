import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/l10n.dart';

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

  @HiveField(7)
  final String defaultKey;

  @HiveField(8)
  final int deadline; // maqsad muddati (ms), 0 = belgilanmagan

  MaqsadModel({
    required this.name,
    required this.balance,
    required this.target,
    required this.iconCode,
    required this.colorValue,
    this.isCompleted = false,
    this.completedAt = 0,
    this.defaultKey = '',
    this.deadline = 0,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  String displayName(AppL10n l10n) =>
      defaultKey.isNotEmpty ? l10n.defaultHisobNom(defaultKey) : name;

  double get progress {
    final current = double.tryParse(balance) ?? 0;
    final goal = double.tryParse(target) ?? 1;
    return (current / goal).clamp(0.0, 1.0);
  }

  bool get bajarilgan => progress >= 1.0;
}
