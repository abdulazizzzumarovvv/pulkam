import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/features/malumotlar/ui/pin_dialog.dart';
import 'package:pulkam/l10n.dart';
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
import 'package:pulkam/features/profile/data/profile_model.dart';
import 'package:pulkam/features/profile/logic/profile_cubit.dart';
import 'package:pulkam/services/notification_service.dart';
import 'package:pulkam/features/voice/ui/floating_mic_button.dart';
import 'package:pulkam/services/widget_sync.dart';
// appQulflangan uchun ham shu import ishlatiladi

// Floating mikrofon dialogi uchun global navigator
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class _HomeGate extends StatefulWidget {
  const _HomeGate();

  @override
  State<_HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<_HomeGate> {
  bool _unlocked = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final soz = context.watch<SozlamalarCubit>().state;
    final needsPin = soz.pinCode && soz.pinValue.isNotEmpty;

    if (!_initialized) {
      _initialized = true;
      _unlocked = !needsPin;
    }

    final qulflangan = needsPin && !_unlocked;
    // Qulf ekranida floating mikrofon ko'rinmasin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appQulflangan.value = qulflangan;
    });

    if (!qulflangan) return const MainScreen();
    return PinLockScreen(onUnlocked: () => setState(() => _unlocked = true));
  }
}

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
  Hive.registerAdapter(ProfileModelAdapter());

  await _openBoxSafe<HisobModel>('hisoblar');
  await _openBoxSafe<MaqsadModel>('maqsadlar');
  await _openBoxSafe<KategoriyaModel>('kategoriyalar');
  await _openBoxSafe<AmalModel>('amallar');
  await _openBoxSafe('settings');
  await _openBoxSafe<QarzModel>('qarzlar');
  await _openBoxSafe<AiAnalizModel>('ai_analiz');
  await _openBoxSafe<ProfileModel>('profiles');
  await initNotifications();

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
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
      ],
      child: BlocBuilder<SozlamalarCubit, SozlamalarState>(
        builder: (context, sozState) {
          final bgColor = sozState.mavzuRang;
          final tilKod = sozState.tilKod;
          final locale = tilKod.isEmpty ? null : Locale(tilKod);
          return MaterialApp(
            title: 'PulKam',
            debugShowCheckedModeBanner: false,
            navigatorKey: appNavigatorKey,
            // Floating mikrofon — barcha ekranlar ustида (Pro)
            builder: (context, child) => Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
                children: [
                  ?child,
                  FloatingMicButton(navigatorKey: appNavigatorKey),
                ],
              ),
            ),
            locale: locale,
            supportedLocales: kSupportedLocales,
            localizationsDelegates: const [
              AppL10nDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supported) {
              if (tilKod.isNotEmpty) return Locale(tilKod);
              if (deviceLocale != null) {
                for (final s in supported) {
                  if (s.languageCode == deviceLocale.languageCode) return s;
                }
              }
              return const Locale('uz');
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C3CE1),
                brightness: Brightness.light,
                surface: const Color(0xFFF5F0FF),
              ),
              textTheme: GoogleFonts.spaceGroteskTextTheme(),
              scaffoldBackgroundColor: bgColor,
              appBarTheme: AppBarTheme(
                backgroundColor: bgColor,
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
            home: const WidgetSync(child: _HomeGate()),
          );
        },
      ),
    );
  }
}
