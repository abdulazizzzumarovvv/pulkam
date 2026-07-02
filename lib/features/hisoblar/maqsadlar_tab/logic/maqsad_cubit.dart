import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/maqsad_model.dart';

class MaqsadState {
  final List<MaqsadModel> maqsadlar;
  MaqsadState(this.maqsadlar);
}

class MaqsadCubit extends Cubit<MaqsadState> {
  MaqsadCubit() : super(MaqsadState([])) {
    _load();
  }

  Box<MaqsadModel> get _box => Hive.box<MaqsadModel>('maqsadlar');

  static const _nameToKey = {
    'Mening orzularim': 'orzular',
  };

  void _load() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      _addDefaults();
    } else {
      _migrateDefaultKeys();
      emit(MaqsadState(_box.values.toList()));
    }
  }

  Future<void> _migrateDefaultKeys() async {
    for (final m in _box.values) {
      if (m.defaultKey.isEmpty && _nameToKey.containsKey(m.name)) {
        await _box.put(m.key, MaqsadModel(
          name: m.name,
          balance: m.balance,
          target: m.target,
          iconCode: m.iconCode,
          colorValue: m.colorValue,
          isCompleted: m.isCompleted,
          completedAt: m.completedAt,
          defaultKey: _nameToKey[m.name]!,
        ));
      }
    }
  }

  Future<void> _addDefaults() async {
    await _box.add(MaqsadModel(
      name: 'Mening orzularim',
      balance: '0',
      target: '1000000',
      iconCode: Icons.auto_awesome.codePoint,
      colorValue: Colors.purple.toARGB32(),
      defaultKey: 'orzular',
    ));
    emit(MaqsadState(_box.values.toList()));
  }

  // Balans nishonga yetganda completedAt sanasini belgilaydi (yoki tozalaydi)
  int _completion(String balance, String target, int oldCompletedAt) {
    final bal = double.tryParse(balance) ?? 0;
    final goal = double.tryParse(target) ?? 0;
    if (goal > 0 && bal >= goal) {
      return oldCompletedAt > 0
          ? oldCompletedAt
          : DateTime.now().millisecondsSinceEpoch;
    }
    return 0;
  }

  Future<void> addMaqsad(MaqsadModel maqsad) async {
    final m = MaqsadModel(
      name: maqsad.name,
      balance: maqsad.balance,
      target: maqsad.target,
      iconCode: maqsad.iconCode,
      colorValue: maqsad.colorValue,
      isCompleted: maqsad.isCompleted,
      completedAt: _completion(maqsad.balance, maqsad.target, 0),
    );
    await _box.add(m);
    emit(MaqsadState(_box.values.toList()));
  }

  Future<void> updateMaqsad(MaqsadModel old, MaqsadModel updated) async {
    final m = MaqsadModel(
      name: updated.name,
      balance: updated.balance,
      target: updated.target,
      iconCode: updated.iconCode,
      colorValue: updated.colorValue,
      isCompleted: updated.isCompleted,
      completedAt: _completion(updated.balance, updated.target, old.completedAt),
    );
    await _box.put(old.key, m);
    emit(MaqsadState(_box.values.toList()));
  }

  Future<void> deleteMaqsad(MaqsadModel maqsad) async {
    await maqsad.delete();
    emit(MaqsadState(_box.values.toList()));
  }

  Future<void> updateBalance(MaqsadModel maqsad, String yangiBalance) async {
    final updated = MaqsadModel(
      name: maqsad.name,
      balance: yangiBalance,
      target: maqsad.target,
      iconCode: maqsad.iconCode,
      colorValue: maqsad.colorValue,
      isCompleted: maqsad.isCompleted,
      completedAt: _completion(yangiBalance, maqsad.target, maqsad.completedAt),
    );
    await _box.put(maqsad.key, updated);
    emit(MaqsadState(_box.values.toList()));
  }
}
