import 'package:flutter/material.dart';

class MaqsadModel {
  final String name;
  final String balance;
  final String target;
  final IconData icon;

  MaqsadModel({
    required this.name,
    required this.balance,
    required this.target,
    required this.icon,
  });

  double get progress {
    final current = double.tryParse(balance) ?? 0;
    final goal = double.tryParse(target) ?? 1;
    return (current / goal).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is MaqsadModel &&
      other.name == name &&
      other.balance == balance &&
      other.target == target &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(name, balance, target, icon);
}