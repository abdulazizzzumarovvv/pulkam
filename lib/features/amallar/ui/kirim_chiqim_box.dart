import 'package:flutter/material.dart';

/// Ikkiga bo'lingan konteyner: chap (qizil) = Chiqim, o'ng (yashil) = Kirim.
/// Home va Statistika sahifalarida ishlatiladi.
class KirimChiqimBox extends StatelessWidget {
  final double kirim;
  final double chiqim;
  const KirimChiqimBox({super.key, required this.kirim, required this.chiqim});

  static const _red = Color(0xFFE74C3C);
  static const _green = Color(0xFF27AE60);

  String _fmt(double v) {
    final s = v.abs().toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write(',');
      buf.write(parts[0][i]);
    }
    return '${buf.toString()}.${parts[1]}';
  }

  Widget _half({
    required Color color,
    required String label,
    required double value,
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
                child: const Text(
                  'UZS',
                  style: TextStyle(
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
                    _fmt(value),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _half(color: _red, label: 'Chiqim', value: chiqim),
            ),
            Expanded(
              child: _half(color: _green, label: 'Kirim', value: kirim),
            ),
          ],
        ),
      ),
    );
  }
}
