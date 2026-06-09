import 'package:flutter/material.dart';

enum KategoriyaTuri { chiqim, kirim }

class KategoriyaModel {
  final String name;
  final IconData icon;
  final Color color;
  final KategoriyaTuri turi;
  final String amount;

  KategoriyaModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.turi,
    this.amount = '0',
  });

  @override
  bool operator ==(Object other) =>
      other is KategoriyaModel &&
      other.name == name &&
      other.icon == icon &&
      other.color == color &&
      other.turi == turi;

  @override
  int get hashCode => Object.hash(name, icon, color, turi);
}