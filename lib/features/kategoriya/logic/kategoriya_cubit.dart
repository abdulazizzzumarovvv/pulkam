import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/kategoriya_model.dart';

class KategoriyaState {
  final List<KategoriyaModel> kategoriyalar;
  KategoriyaState(this.kategoriyalar);
}

class KategoriyaCubit extends Cubit<KategoriyaState> {
  KategoriyaCubit() : super(KategoriyaState([
    // Chiqim kategoriyalar
    KategoriyaModel(name: 'Oziq-ovqat', icon: Icons.restaurant_outlined, color: Color(0xFF7C4DFF), turi: KategoriyaTuri.chiqim),
    KategoriyaModel(name: 'Kafe', icon: Icons.coffee_outlined, color: Color(0xFFE91E63), turi: KategoriyaTuri.chiqim),
    KategoriyaModel(name: 'Transport', icon: Icons.directions_bus_outlined, color: Color(0xFF2979FF), turi: KategoriyaTuri.chiqim),
    KategoriyaModel(name: 'Salomatlik', icon: Icons.medical_services_outlined, color: Color(0xFF00BFA5), turi: KategoriyaTuri.chiqim),
    KategoriyaModel(name: 'Kiyim', icon: Icons.checkroom_outlined, color: Color(0xFFFF9100), turi: KategoriyaTuri.chiqim),
    KategoriyaModel(name: 'Oila', icon: Icons.people_outline, color: Color(0xFFFF5252), turi: KategoriyaTuri.chiqim),
    // Kirim kategoriyalar
    KategoriyaModel(name: 'Maosh', icon: Icons.work_outline, color: Color(0xFF00E676), turi: KategoriyaTuri.kirim),
    KategoriyaModel(name: 'Biznes', icon: Icons.business_outlined, color: Color(0xFF2979FF), turi: KategoriyaTuri.kirim),
    KategoriyaModel(name: 'Sovg\'a', icon: Icons.card_giftcard_outlined, color: Color(0xFFFF4081), turi: KategoriyaTuri.kirim),
    KategoriyaModel(name: 'Freelance', icon: Icons.laptop_outlined, color: Color(0xFFFFAB00), turi: KategoriyaTuri.kirim),
  ]));

  void addKategoriya(KategoriyaModel kategoriya) {
    emit(KategoriyaState([...state.kategoriyalar, kategoriya]));
  }

  void updateKategoriya(KategoriyaModel old, KategoriyaModel updated) {
    final list = state.kategoriyalar.map((k) => k == old ? updated : k).toList();
    emit(KategoriyaState(list));
  }

  void deleteKategoriya(KategoriyaModel kategoriya) {
    final list = state.kategoriyalar.where((k) => k != kategoriya).toList();
    emit(KategoriyaState(list));
  }
}