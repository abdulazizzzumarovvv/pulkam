import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/qarz_model.dart';
import '../../hisoblar_tab/logic/hisob_cubit.dart';
import '../../../amallar/logic/amal_cubit.dart';

class QarzState {
  final List<QarzModel> qarzlar;
  QarzState(this.qarzlar);
}

class QarzCubit extends Cubit<QarzState> {
  QarzCubit() : super(QarzState([])) {
    _load();
  }

  Box<QarzModel> get _box => Hive.box<QarzModel>('qarzlar');

  void _load() {
    final list = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    emit(QarzState(list));
  }

  Future<void> addQarz(QarzModel qarz) async {
    await _box.add(qarz);
    _load();
  }

  Future<void> addTolov(QarzModel qarz, String tolovAmount) async {
    final oldPaid = double.tryParse(qarz.paid) ?? 0;
    final added = double.tryParse(tolovAmount) ?? 0;
    final newPaid = (oldPaid + added).toStringAsFixed(2);
    final updated = QarzModel(
      personName: qarz.personName,
      amount: qarz.amount,
      paid: newPaid,
      isQarzBerdim: qarz.isQarzBerdim,
      hisobName: qarz.hisobName,
      timestamp: qarz.timestamp,
      tolovlar: [
        ...qarz.tolovlar,
        TolovModel(
          amount: added.toStringAsFixed(2),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ],
    );
    await _box.put(qarz.key, updated);
    _load();
  }

  Future<void> updateQarz(QarzModel old, QarzModel updated) async {
    await _box.put(old.key, updated);
    _load();
  }

  /// Qarzni o'chiradi VA ta'sirini ortga qaytaradi:
  ///  • hisob balansidan qarzning qolgan (chiqmagan) qismini teskari qaytaradi
  ///  • amallar tarixidan qarz yaratilgan yozuvni o'chiradi
  Future<void> deleteQarz(
    QarzModel qarz, {
    required HisobCubit hisobCubit,
    required AmalCubit amalCubit,
  }) async {
    // Chiqmagan (qolgan) qism — yaratishda +, to'lovlarda − bo'lgan sof effekt
    final qoldiq = qarz.remaining;
    final matches = hisobCubit.state.hisoblar.where(
      (h) => h.name == qarz.hisobName,
    );
    if (qoldiq != 0 && matches.isNotEmpty) {
      final hisob = matches.first;
      final bal = double.tryParse(hisob.balance) ?? 0;
      // Oldim: yaratishda karta +qoldiq bo'lgan → o'chirishda −qoldiq
      // Berdim: yaratishda karta −qoldiq bo'lgan → o'chirishda +qoldiq
      final newBal = qarz.isQarzBerdim ? bal + qoldiq : bal - qoldiq;
      await hisobCubit.updateBalance(hisob, newBal.toStringAsFixed(2));
    }

    // Amallar tarixidan qarz YARATILGAN yozuvni o'chirish (to'lovlar qoladi)
    await amalCubit.deleteQarzYaratilganAmal(
      hisobName: qarz.hisobName,
      timestamp: qarz.timestamp,
      isQarzBerdim: qarz.isQarzBerdim,
      amount: qarz.amount,
    );

    await qarz.delete();
    _load();
  }
}
