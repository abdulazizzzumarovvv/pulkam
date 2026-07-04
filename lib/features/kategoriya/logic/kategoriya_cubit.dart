import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/kategoriya_model.dart';

class KategoriyaState {
  final List<KategoriyaModel> kategoriyalar;
  KategoriyaState(this.kategoriyalar);
}

class KategoriyaCubit extends Cubit<KategoriyaState> {
  KategoriyaCubit() : super(KategoriyaState([])) {
    _load();
  }

  Box<KategoriyaModel> get _box => Hive.box<KategoriyaModel>('kategoriyalar');

  static const _nameToKey = {
    'Oziq-ovqat': 'oziq_ovqat',
    'Kafe': 'kafe',
    'Transport': 'transport',
    'Salomatlik': 'salomatlik',
    'Kiyim': 'kiyim',
    'Oila': 'oila',
    'Maosh': 'maosh',
    'Oylik': 'oylik',
    'Avans': 'avans',
    'Biznes': 'biznes',
    "Sovg'a": 'sovga',
    'Freelance': 'freelance',
  };

  void _load() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      _addDefaults();
    } else {
      _migrateDefaultKeys(list);
      emit(KategoriyaState(_box.values.toList()));
    }
  }

  Future<void> _migrateDefaultKeys(List<KategoriyaModel> list) async {
    for (final k in list) {
      if (k.defaultKey.isEmpty && _nameToKey.containsKey(k.name)) {
        await _box.put(k.key, KategoriyaModel(
          name: k.name,
          iconCode: k.iconCode,
          colorValue: k.colorValue,
          turi: k.turi,
          amount: k.amount,
          hisobIndex: k.hisobIndex,
          defaultKey: _nameToKey[k.name]!,
        ));
      }
    }
  }

  Future<void> _addDefaults() async {
    final defaults = [
      KategoriyaModel(name: 'Oziq-ovqat', defaultKey: 'oziq_ovqat', iconCode: Icons.restaurant_outlined.codePoint, colorValue: const Color(0xFF7C4DFF).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Kafe', defaultKey: 'kafe', iconCode: Icons.coffee_outlined.codePoint, colorValue: const Color(0xFFE91E63).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Transport', defaultKey: 'transport', iconCode: Icons.directions_bus_outlined.codePoint, colorValue: const Color(0xFF2979FF).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Salomatlik', defaultKey: 'salomatlik', iconCode: Icons.medical_services_outlined.codePoint, colorValue: const Color(0xFF00BFA5).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Kiyim', defaultKey: 'kiyim', iconCode: Icons.checkroom_outlined.codePoint, colorValue: const Color(0xFFFF9100).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Oila', defaultKey: 'oila', iconCode: Icons.people_outline.codePoint, colorValue: const Color(0xFFFF5252).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Oylik', defaultKey: 'oylik', iconCode: Icons.work_outline.codePoint, colorValue: const Color(0xFF00E676).toARGB32(), turi: 'kirim'),
      KategoriyaModel(name: 'Avans', defaultKey: 'avans', iconCode: Icons.payments_outlined.codePoint, colorValue: const Color(0xFF2979FF).toARGB32(), turi: 'kirim'),
      KategoriyaModel(name: 'Freelance', defaultKey: 'freelance', iconCode: Icons.laptop_outlined.codePoint, colorValue: const Color(0xFFFFAB00).toARGB32(), turi: 'kirim'),
    ];
    for (final k in defaults) {
      await _box.add(k);
    }
    emit(KategoriyaState(_box.values.toList()));
  }

  Future<void> addKategoriya(KategoriyaModel kategoriya) async {
    await _box.add(kategoriya);
    emit(KategoriyaState(_box.values.toList()));
  }

  Future<void> updateKategoriya(KategoriyaModel old, KategoriyaModel updated) async {
    await _box.put(old.key, updated);
    emit(KategoriyaState(_box.values.toList()));
  }

  Future<void> deleteKategoriya(KategoriyaModel kategoriya) async {
    await kategoriya.delete();
    emit(KategoriyaState(_box.values.toList()));
  }

  Future<void> updateAmount(KategoriyaModel kategoriya, String yangiAmount) async {
    final updated = KategoriyaModel(
      name: kategoriya.name,
      iconCode: kategoriya.iconCode,
      colorValue: kategoriya.colorValue,
      turi: kategoriya.turi,
      amount: yangiAmount,
      hisobIndex: kategoriya.hisobIndex,
    );
    await _box.put(kategoriya.key, updated);
    emit(KategoriyaState(_box.values.toList()));
  }
}
