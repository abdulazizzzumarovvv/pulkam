import 'package:flutter/material.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'main_screen/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'features/kategoriya/logic/kategoriya_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/hisoblar/hisoblar_tab/data/hisob_model.dart';
import 'features/hisoblar/maqsadlar_tab/data/maqsad_model.dart';
import 'features/kategoriya/data/kategoriya_model.dart';
import 'package:pulkam/features/amallar/data/amal_model.dart';
import 'package:pulkam/features/amallar/logic/amal_cubit.dart';
import 'package:pulkam/features/hisoblar/qarzlar_tab/data/qarz_model.dart';
import 'package:pulkam/features/hisoblar/qarzlar_tab/logic/qarz_cubit.dart';
import 'package:pulkam/features/ai_analiz/data/ai_analiz_model.dart';
import 'package:pulkam/features/ai_analiz/logic/ai_analiz_cubit.dart';

Future<void> _openBoxSafe<T>(String name) async {
  try {
    await Hive.openBox<T>(name);
  } catch (_) {
    try {
      await Hive.deleteBoxFromDisk(name);
    } catch (_) {}
    await Hive.openBox<T>(name);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HisobModelAdapter());
  Hive.registerAdapter(MaqsadModelAdapter());
  Hive.registerAdapter(KategoriyaModelAdapter());
  Hive.registerAdapter(AmalModelAdapter());
  Hive.registerAdapter(QarzModelAdapter());
  Hive.registerAdapter(TolovModelAdapter());
  Hive.registerAdapter(AiAnalizModelAdapter());

  await _openBoxSafe<HisobModel>('hisoblar');
  await _openBoxSafe<MaqsadModel>('maqsadlar');
  await _openBoxSafe<KategoriyaModel>('kategoriyalar');
  await _openBoxSafe<AmalModel>('amallar');
  await _openBoxSafe('settings');
  await _openBoxSafe<QarzModel>('qarzlar');
  await _openBoxSafe<AiAnalizModel>('ai_analiz');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HisobCubit>(create: (_) => HisobCubit()),
        BlocProvider<MaqsadCubit>(create: (_) => MaqsadCubit()),
        BlocProvider<KategoriyaCubit>(create: (_) => KategoriyaCubit()),
        BlocProvider<AmalCubit>(create: (_) => AmalCubit()),
        BlocProvider<SozlamalarCubit>(create: (_) => SozlamalarCubit()),
        BlocProvider<QarzCubit>(create: (_) => QarzCubit()),
        BlocProvider(create: (_) => AiAnalizCubit()),
      ],
      child: MaterialApp(
        title: 'PulKam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C3CE1),
            brightness: Brightness.light,
            surface: const Color(0xFFF5F0FF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F0FF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F0FF),
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black87,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF6C3CE1).withValues(alpha: 0.15),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF6C3CE1));
              }
              return IconThemeData(color: Colors.grey[600]);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: Color(0xFF6C3CE1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600);
              }
              return TextStyle(color: Colors.grey[600], fontSize: 12);
            }),
          ),
          tabBarTheme: const TabBarThemeData(
            indicatorColor: Color(0xFF6C3CE1),
            labelColor: Color(0xFF6C3CE1),
            unselectedLabelColor: Colors.grey,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C3CE1),
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C3CE1)),
            ),
          ),
          cardColor: Colors.white,
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
