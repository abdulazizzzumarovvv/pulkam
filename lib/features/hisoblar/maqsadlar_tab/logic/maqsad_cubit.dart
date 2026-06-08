import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/maqsad_model.dart';

class MaqsadState {
  final List<MaqsadModel> maqsadlar;
  MaqsadState(this.maqsadlar);
}

class MaqsadCubit extends Cubit<MaqsadState> {
  MaqsadCubit() : super(MaqsadState([
    MaqsadModel(
      name: 'Mening orzularim',
      balance: '0',
      target: '1000000',
      icon: Icons.stadium_sharp,
    ),
  ]));

  void addMaqsad(MaqsadModel maqsad) {
    emit(MaqsadState([...state.maqsadlar, maqsad]));
  }

  void updateMaqsad(MaqsadModel old, MaqsadModel updated) {
    final list = state.maqsadlar.map((m) => m == old ? updated : m).toList();
    emit(MaqsadState(list));
  }

  void deleteMaqsad(MaqsadModel maqsad) {
    final list = state.maqsadlar.where((m) => m != maqsad).toList();
    emit(MaqsadState(list));
  }
}