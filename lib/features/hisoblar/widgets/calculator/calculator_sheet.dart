// calculator_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'calculator_cubit.dart';

class CalculatorSheet extends StatefulWidget {
  final String currency;        // например 'UZS'
  final void Function(String value) onConfirm;

  const CalculatorSheet({
    super.key,
    this.currency = 'UZS',
    required this.onConfirm,
  });

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  late final CalculatorCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CalculatorCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _onActionButton(BuildContext context, ActionButtonType type) {
    if (type == ActionButtonType.equals) {
      _cubit.calculate();
    } else {
      // check — подтверждаем и закрываем
      widget.onConfirm(_cubit.currentValue);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                const SizedBox(height: 10),
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // дисплей
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (state.expression.isNotEmpty)
                        Text(
                          state.expression,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.display} ${widget.currency}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // кнопки
                _CalcGrid(
                  onAction: () => _onActionButton(context, state.actionButton),
                  actionButtonType: state.actionButton,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Сетка кнопок ────────────────────────────────────────────
class _CalcGrid extends StatelessWidget {
  final VoidCallback onAction;
  final ActionButtonType actionButtonType;

  const _CalcGrid({
    required this.onAction,
    required this.actionButtonType,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();

    // layout как на скриншоте:
    // [÷][7][8][9][⌫]
    // [×][4][5][6][ ✓/= (rowspan 2) ]
    // [−][1][2][3]
    // [+][ 0 (colspan 2) ][.]

    const btnH = 64.0;
    const gap = 4.0;

    Widget numBtn(String label, VoidCallback onTap) {
      return _CalcButton(
        label: label,
        onTap: onTap,
        bgColor: const Color(0xFF1E1E1E),
        textColor: Colors.white,
        height: btnH,
      );
    }

    Widget opBtn(String label, VoidCallback onTap) {
      return _CalcButton(
        label: label,
        onTap: onTap,
        bgColor: const Color(0xFF1E1E1E),
        textColor: Colors.white,
        height: btnH,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // row 1: ÷ 7 8 9 ⌫
          Row(
            children: [
              Expanded(child: opBtn('÷', () => cubit.inputOperator('÷'))),
              const SizedBox(width: gap),
              Expanded(child: numBtn('7', () => cubit.inputDigit('7'))),
              const SizedBox(width: gap),
              Expanded(child: numBtn('8', () => cubit.inputDigit('8'))),
              const SizedBox(width: gap),
              Expanded(child: numBtn('9', () => cubit.inputDigit('9'))),
              const SizedBox(width: gap),
              Expanded(
                child: _CalcButton(
                  label: '⌫',
                  onTap: cubit.backspace,
                  bgColor: const Color(0xFF1E1E1E),
                  textColor: Colors.white,
                  height: btnH,
                  icon: Icons.backspace_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: gap),

          // row 2+3: [×][4][5][6] + [−][1][2][3] с action-кнопкой справа (2 ряда высотой)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // левая часть: 2 ряда
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: opBtn('×', () => cubit.inputOperator('×'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('4', () => cubit.inputDigit('4'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('5', () => cubit.inputDigit('5'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('6', () => cubit.inputDigit('6'))),
                        ],
                      ),
                      const SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(child: opBtn('−', () => cubit.inputOperator('−'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('1', () => cubit.inputDigit('1'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('2', () => cubit.inputDigit('2'))),
                          const SizedBox(width: gap),
                          Expanded(child: numBtn('3', () => cubit.inputDigit('3'))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: gap),

                // action-кнопка (занимает 2 ряда)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 16 - gap * 4) / 5,
                  child: GestureDetector(
                    onTap: onAction,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6FBD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: actionButtonType == ActionButtonType.equals
                              ? const Text(
                                  '=',
                                  key: ValueKey('eq'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                  key: ValueKey('check'),
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // row 4: + [0 (2x)] .
          Row(
            children: [
              Expanded(child: opBtn('+', () => cubit.inputOperator('+'))),
              const SizedBox(width: gap),
              // 0 занимает 2 колонки
              Expanded(
                flex: 2,
                child: _CalcButton(
                  label: '0',
                  onTap: () => cubit.inputDigit('0'),
                  bgColor: const Color(0xFF1E1E1E),
                  textColor: Colors.white,
                  height: btnH,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(child: numBtn('.', cubit.inputDot)),
              const SizedBox(width: gap),
              // пустое место под action-кнопку (чтобы ширина совпадала)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 16 - gap * 4) / 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final double height;
  final IconData? icon;

  const _CalcButton({
    required this.label,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
    required this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: 20)
              : Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }
}