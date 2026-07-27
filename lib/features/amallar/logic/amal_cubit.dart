import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/amal_model.dart';

class AmalState {
  final List<AmalModel> amallar;
  AmalState(this.amallar);
}

class AmalCubit extends Cubit<AmalState> {
  AmalCubit() : super(AmalState([])) {
    _load();
  }

  Box<AmalModel> get _box => Hive.box<AmalModel>('amallar');

  void _load() {
    final list = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    emit(AmalState(list));
  }

  Future<void> addAmal(AmalModel amal) async {
    await _box.add(amal);
    _load();
  }

  Future<void> deleteAmal(AmalModel amal) async {
    await amal.delete();
    _load();
  }

  /// Qarz o'chirilganda — o'sha qarz YARATILGAN amal yozuvini topib o'chiradi.
  /// Moslik: hisob nomi + timestamp + kategoriya (Qarz oldim/berdim) + summa.
  Future<void> deleteQarzYaratilganAmal({
    required String hisobName,
    required int timestamp,
    required bool isQarzBerdim,
    required String amount,
  }) async {
    final kat = isQarzBerdim ? 'Qarz berdim' : 'Qarz oldim';
    final amt = double.tryParse(amount) ?? 0;
    for (final a in _box.values.toList()) {
      final ayni = a.hisobName == hisobName &&
          a.timestamp == timestamp &&
          a.kategoriyaName == kat &&
          (double.tryParse(a.amount) ?? 0) == amt;
      if (ayni) {
        await a.delete();
        break; // faqat bitta yozuvni o'chiramiz
      }
    }
    _load();
  }

  List<AmalModel> forMonth(int year, int month) {
    return state.amallar.where((a) {
      final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
      return dt.year == year && dt.month == month;
    }).toList();
  }
}
