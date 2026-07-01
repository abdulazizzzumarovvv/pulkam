import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/qarz_model.dart';

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

  Future<void> deleteQarz(QarzModel qarz) async {
    await qarz.delete();
    _load();
  }
}
