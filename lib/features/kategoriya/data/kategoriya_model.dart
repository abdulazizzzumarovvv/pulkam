import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'kategoriya_model.g.dart';

enum KategoriyaTuri { chiqim, kirim }

@HiveType(typeId: 2)
class KategoriyaModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int iconCode;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final String turi;

  @HiveField(4)
  final String amount;

  @HiveField(5)
  final int hisobIndex;

  KategoriyaModel({
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.turi,
    this.amount = '0',
    this.hisobIndex = -1,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  KategoriyaTuri get kategoriyaTuri =>
      turi == 'kirim' ? KategoriyaTuri.kirim : KategoriyaTuri.chiqim;
}
