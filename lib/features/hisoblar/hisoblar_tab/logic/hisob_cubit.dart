import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hisob_model.dart';
import 'package:flutter/material.dart';

class HisobState {
  final List<HisobModel> hisoblar;
  HisobState(this.hisoblar);
}

class HisobCubit extends Cubit<HisobState> {
  HisobCubit() : super(HisobState([
    HisobModel(name: 'Karta', balance: '0', icon: Icons.add_card_outlined),
    HisobModel(name: 'Naqd pul', balance: '0', icon: Icons.money),
  ]));

  void addHisob(HisobModel hisob) {
    emit(HisobState([...state.hisoblar, hisob]));
  }

  void updateHisob(HisobModel old, HisobModel updated) {
    final list = state.hisoblar.map((h) => h == old ? updated : h).toList();
    emit(HisobState(list));
  }

  void deleteHisob(HisobModel hisob) {
  final list = state.hisoblar.where((h) => h != hisob).toList();
  emit(HisobState(list));
}
}