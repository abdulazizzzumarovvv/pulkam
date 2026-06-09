import 'package:flutter/material.dart';

class HisobModel {
  final String name;
  final String balance;
  final IconData icon;
  final Color color;

  HisobModel({
    required this.name,
    required this.balance,
    required this.icon,
    this.color = Colors.grey,
  });

  @override
  bool operator ==(Object other) =>
      other is HisobModel &&
      other.name == name &&
      other.balance == balance &&
      other.icon == icon &&
      other.color == color;

  @override
  int get hashCode => Object.hash(name, balance, icon, color);
}