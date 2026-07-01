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

  void _load() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      _addDefaults();
    } else {
      emit(KategoriyaState(list));
    }
  }

  Future<void> _addDefaults() async {
    final defaults = [
      KategoriyaModel(name: 'Oziq-ovqat', iconCode: Icons.restaurant_outlined.codePoint, colorValue: const Color(0xFF7C4DFF).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Kafe', iconCode: Icons.coffee_outlined.codePoint, colorValue: const Color(0xFFE91E63).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Transport', iconCode: Icons.directions_bus_outlined.codePoint, colorValue: const Color(0xFF2979FF).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Salomatlik', iconCode: Icons.medical_services_outlined.codePoint, colorValue: const Color(0xFF00BFA5).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Kiyim', iconCode: Icons.checkroom_outlined.codePoint, colorValue: const Color(0xFFFF9100).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Oila', iconCode: Icons.people_outline.codePoint, colorValue: const Color(0xFFFF5252).toARGB32(), turi: 'chiqim'),
      KategoriyaModel(name: 'Maosh', iconCode: Icons.work_outline.codePoint, colorValue: const Color(0xFF00E676).toARGB32(), turi: 'kirim'),
      KategoriyaModel(name: 'Biznes', iconCode: Icons.business_outlined.codePoint, colorValue: const Color(0xFF2979FF).toARGB32(), turi: 'kirim'),
      KategoriyaModel(name: "Sovg'a", iconCode: Icons.card_giftcard_outlined.codePoint, colorValue: const Color(0xFFFF4081).toARGB32(), turi: 'kirim'),
      KategoriyaModel(name: 'Freelance', iconCode: Icons.laptop_outlined.codePoint, colorValue: const Color(0xFFFFAB00).toARGB32(), turi: 'kirim'),
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
