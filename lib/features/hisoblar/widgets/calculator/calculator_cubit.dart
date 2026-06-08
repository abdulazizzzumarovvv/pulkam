// calculator_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(const CalculatorState());

  void inputDigit(String digit) {
    final s = state;
    final newDisplay = (s.display == '0' || s.shouldReplace)
        ? digit
        : (s.display.length < 15 ? s.display + digit : s.display);
    emit(s.copyWith(display: newDisplay, shouldReplace: false));
  }

  void inputDot() {
    final s = state;
    if (s.shouldReplace) {
      emit(s.copyWith(display: '0.', shouldReplace: false));
      return;
    }
    if (!s.display.contains('.')) {
      emit(s.copyWith(display: s.display + '.'));
    }
  }

  void inputOperator(String op) {
    final s = state;
    emit(s.copyWith(
      operand: double.tryParse(s.display),
      operator: op,
      expression: '${s.display} $op',
      shouldReplace: true,
      actionButton: ActionButtonType.equals,
    ));
  }

  void calculate() {
    final s = state;
    if (s.operand == null || s.operator == null) return;

    final b = double.tryParse(s.display) ?? 0;
    double result;
    switch (s.operator) {
      case '+': result = s.operand! + b; break;
      case '−': result = s.operand! - b; break;
      case '×': result = s.operand! * b; break;
      case '÷': result = b == 0 ? double.nan : s.operand! / b; break;
      default:  result = b;
    }

    final resultStr = result.isNaN
        ? 'Ошибка'
        : (result == result.truncateToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''));

    emit(s.copyWith(
      display: resultStr,
      expression: '${s.expression} ${s.display} =',
      clearOperand: true,
      clearOperator: true,
      shouldReplace: true,
      actionButton: ActionButtonType.check,
    ));
  }

  void backspace() {
    final s = state;
    if (s.shouldReplace || s.display.length <= 1) {
      emit(s.copyWith(display: '0', shouldReplace: false));
    } else {
      emit(s.copyWith(display: s.display.substring(0, s.display.length - 1)));
    }
  }

  void clear() {
    emit(const CalculatorState());
  }

  String get currentValue => state.display;
}