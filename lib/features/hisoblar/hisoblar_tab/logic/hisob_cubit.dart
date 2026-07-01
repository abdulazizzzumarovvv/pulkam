import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/hisob_model.dart';

class HisobState {
  final List<HisobModel> hisoblar;
  HisobState(this.hisoblar);
}

class HisobCubit extends Cubit<HisobState> {
  HisobCubit() : super(HisobState([])) {
    _load();
  }

  Box<HisobModel> get _box => Hive.box<HisobModel>('hisoblar');

  void _load() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      _addDefaults();
    } else {
      emit(HisobState(list));
    }
  }

  Future<void> _addDefaults() async {
    await _box.add(HisobModel(
      name: 'Karta',
      balance: '0',
      iconCode: Icons.add_card_outlined.codePoint,
      colorValue: Colors.blue.toARGB32(),
    ));
    await _box.add(HisobModel(
      name: 'Naqd pul',
      balance: '0',
      iconCode: Icons.money.codePoint,
      colorValue: Colors.green.toARGB32(),
    ));
    emit(HisobState(_box.values.toList()));
  }

  Future<void> addHisob(HisobModel hisob) async {
    await _box.add(hisob);
    emit(HisobState(_box.values.toList()));
  }

  Future<void> updateHisob(HisobModel old, HisobModel updated) async {
    await _box.put(old.key, updated);
    emit(HisobState(_box.values.toList()));
  }

  Future<void> deleteHisob(HisobModel hisob) async {
    await hisob.delete();
    emit(HisobState(_box.values.toList()));
  }

  Future<void> updateBalance(HisobModel hisob, String yangiBalance) async {
    final updated = HisobModel(
      name: hisob.name,
      balance: yangiBalance,
      iconCode: hisob.iconCode,
      colorValue: hisob.colorValue,
    );
    await _box.put(hisob.key, updated);
    emit(HisobState(_box.values.toList()));
  }
}
