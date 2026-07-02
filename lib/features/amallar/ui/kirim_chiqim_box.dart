import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';

/// Ikkiga bo'lingan konteyner: chap (qizil) = Chiqim, o'ng (yashil) = Kirim.
/// Home va Statistika sahifalarida ishlatiladi.
class KirimChiqimBox extends StatelessWidget {
  final double kirim;
  final double chiqim;
  const KirimChiqimBox({super.key, required this.kirim, required this.chiqim});

  static const _red = Color(0xFFE74C3C);
  static const _green = Color(0xFF27AE60);

  Widget _half({
    required Color color,
    required String label,
    required double value,
    required String currencyCode,
    required String formatKod,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currencyCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    appFmt(value, formatKod),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SozlamalarCubit>().state;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _half(
                color: _red,
                label: 'Chiqim',
                value: chiqim,
                currencyCode: state.valyutaKod,
                formatKod: state.formatKod,
              ),
            ),
            Expanded(
              child: _half(
                color: _green,
                label: 'Kirim',
                value: kirim,
                currencyCode: state.valyutaKod,
                formatKod: state.formatKod,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
