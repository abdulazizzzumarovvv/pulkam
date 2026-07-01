import 'package:flutter_bloc/flutter_bloc.dart';

class AiAnalizState {
  final bool isLoading;
  final String? result;
  AiAnalizState({this.isLoading = false, this.result});
}

class AiAnalizCubit extends Cubit<AiAnalizState> {
  AiAnalizCubit() : super(AiAnalizState());
}
