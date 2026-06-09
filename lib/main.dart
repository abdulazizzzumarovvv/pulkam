import 'package:flutter/material.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/main_screen/logic/cubit.dart';
import 'main_screen/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'features/kategoriya/logic/kategoriya_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulKam',
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MainScreenCubit>(create: (context) => MainScreenCubit()),
          BlocProvider<HisobCubit>(create: (context) => HisobCubit()),
          BlocProvider<MaqsadCubit>(create: (context) => MaqsadCubit()),
          BlocProvider<KategoriyaCubit>(create: (context) => KategoriyaCubit()),
        ],
        child: const MainScreen(),
      ),
    );
  }
}
