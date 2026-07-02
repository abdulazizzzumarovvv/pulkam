import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/l10n.dart';

part 'hisob_model.g.dart';

@HiveType(typeId: 0)
class HisobModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String balance;

  @HiveField(2)
  final int iconCode;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String defaultKey;

  HisobModel({
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.colorValue,
    this.defaultKey = '',
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  String displayName(AppL10n l10n) =>
      defaultKey.isNotEmpty ? l10n.defaultHisobNom(defaultKey) : name;
}
