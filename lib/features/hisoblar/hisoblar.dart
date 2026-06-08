import 'package:flutter/material.dart';
import 'maqsadlar_tab/ui/maqsadlar_tab.dart';
import 'qarzlar_tab/ui/qarzlar_tab.dart';
import 'hisoblar_tab/ui/hisoblar_tab.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class Hisoblar extends StatefulWidget {
  const Hisoblar({super.key});

  @override
  State<Hisoblar> createState() => _HisoblarState();
}

class _HisoblarState extends State<Hisoblar> {
  late List<Widget> tabs = [];

  @override
  void initState() {
    tabs..add(const HisoblarTab())..add(const MaqsadlarTab())..add(const QarzlarTab());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final hisobSum = context
        .watch<HisobCubit>()
        .state
        .hisoblar
        .fold(0.0, (sum, h) => sum + (double.tryParse(h.balance) ?? 0));

    // Maqsadlar hozirgi balanslari summasi
    final maqsadSum = context
        .watch<MaqsadCubit>()
        .state
        .maqsadlar
        .fold(0.0, (sum, m) => sum + (double.tryParse(m.balance) ?? 0));

    final totalSum = hisobSum + maqsadSum;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            children: [
              const Text('Umumiy balans'),
              const SizedBox(height: 4),
              Text('${totalSum.toInt()} UZS'),
            ],
          ),
          bottom: TabBar(tabs: [
            Tab(text: 'Hisoblar'),
            Tab(text: 'Maqsadlar'),
            Tab(text: 'Qarzlar'),
          ]),
        ),
        body: TabBarView(
          children: tabs,
        ),
      ),
    );
  }
}