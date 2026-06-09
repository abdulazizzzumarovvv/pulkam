import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/kategoriya_cubit.dart';
import '../data/kategoriya_model.dart';
import '../../hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import '../../hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:dotted_border/dotted_border.dart';
import 'kategoriya_add.dart';
import 'package:pulkam/features/kategoriya/widgets/operatsiya_sheet.dart';

class Kategoriya extends StatefulWidget {
  const Kategoriya({super.key});

  @override
  State<Kategoriya> createState() => _KategoriyaState();
}

class _KategoriyaState extends State<Kategoriya> {
  KategoriyaTuri _tanlangan = KategoriyaTuri.chiqim;
  DateTime _selectedMonth = DateTime.now();

  void _prevMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
  });

  String get _monthLabel {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hisobSum = context.watch<HisobCubit>().state.hisoblar.fold(
      0.0,
      (sum, h) => sum + (double.tryParse(h.balance) ?? 0),
    );
    final maqsadSum = context.watch<MaqsadCubit>().state.maqsadlar.fold(
      0.0,
      (sum, m) => sum + (double.tryParse(m.balance) ?? 0),
    );
    final totalSum = hisobSum + maqsadSum;

    return BlocBuilder<KategoriyaCubit, KategoriyaState>(
      builder: (context, state) {
        final filtered = state.kategoriyalar
            .where((k) => k.turi == _tanlangan)
            .toList();

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Column(
              children: [
                const Text('Umumiy balans'),
                const SizedBox(height: 4),
                Text('${totalSum.toInt()} UZS'),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                // Oy tanlash
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _monthLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chiqim / Kirim toggle
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _tanlangan = KategoriyaTuri.chiqim,
                          ),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: _tanlangan == KategoriyaTuri.chiqim
                                  ? Colors.transparent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _tanlangan == KategoriyaTuri.chiqim
                                  ? Border.all(color: Colors.red, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chiqim',
                                  style: TextStyle(
                                    color: _tanlangan == KategoriyaTuri.chiqim
                                        ? Colors.black
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '0 UZS',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _tanlangan = KategoriyaTuri.kirim),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: _tanlangan == KategoriyaTuri.kirim
                                  ? Colors.transparent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _tanlangan == KategoriyaTuri.kirim
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kirim',
                                  style: TextStyle(
                                    color: _tanlangan == KategoriyaTuri.kirim
                                        ? Colors.black
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '0 UZS',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kategoriyalar grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: filtered.length + 1, // +1 Add tugmasi
                    itemBuilder: (_, i) {
                      if (i == filtered.length) {
                        return DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: const Radius.circular(12),
                            color: Colors.grey[400]!,
                            dashPattern: const [8, 4],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<KategoriyaCubit>(),
                                        child: const KategoriyaAdd(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Qo\'shish',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final kategoriya = filtered[i];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: context.read<KategoriyaCubit>(),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<HisobCubit>(),
                                  ),
                                ],
                                child: OperatsiyaSheet(kategoriya: kategoriya),
                              ),
                            );
                          },
                          child: _KategoriyaCard(kategoriya: kategoriya),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KategoriyaCard extends StatelessWidget {
  final KategoriyaModel kategoriya;

  const _KategoriyaCard({required this.kategoriya});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kategoriya.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: kategoriya.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(kategoriya.icon, color: kategoriya.color, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kategoriya.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${kategoriya.amount} UZS',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
