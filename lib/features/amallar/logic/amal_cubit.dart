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

  List<AmalModel> forMonth(int year, int month) {
    return state.amallar.where((a) {
      final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
      return dt.year == year && dt.month == month;
    }).toList();
  }
}
