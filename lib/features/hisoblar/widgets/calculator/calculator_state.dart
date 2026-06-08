// calculator_state.dart
part of 'calculator_cubit.dart';

enum ActionButtonType { check, equals }

class CalculatorState {
  final String display;       // то что видно крупно
  final String expression;    // история вверху
  final double? operand;
  final String? operator;
  final bool shouldReplace;
  final ActionButtonType actionButton;

  const CalculatorState({
    this.display = '0',
    this.expression = '',
    this.operand,
    this.operator,
    this.shouldReplace = false,
    this.actionButton = ActionButtonType.check,
  });

  CalculatorState copyWith({
    String? display,
    String? expression,
    double? operand,
    String? operator,
    bool clearOperand = false,
    bool clearOperator = false,
    bool? shouldReplace,
    ActionButtonType? actionButton,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      expression: expression ?? this.expression,
      operand: clearOperand ? null : (operand ?? this.operand),
      operator: clearOperator ? null : (operator ?? this.operator),
      shouldReplace: shouldReplace ?? this.shouldReplace,
      actionButton: actionButton ?? this.actionButton,
    );
  }
}