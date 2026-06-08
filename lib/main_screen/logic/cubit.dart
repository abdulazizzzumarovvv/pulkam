import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit() : super(MainScreenState(selectedIndex: 0));

  void setSelectedIndex(int index) => emit(MainScreenState(selectedIndex: index));
}