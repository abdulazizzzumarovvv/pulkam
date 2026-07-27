// Home-screen widget'ni ilova holati bilan sinxronlaydi va deep-link'larni
// ushlaydi (widget tugmalari bosilganda kerakli ekranni ochadi).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:pulkam/features/hisoblar/hisoblar_tab/logic/hisob_cubit.dart';
import 'package:pulkam/features/hisoblar/maqsadlar_tab/logic/maqsad_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';
import 'package:pulkam/services/widget_service.dart';

/// Widget deep-link'lari shu callback orqali ilova ekranlariga yo'naltiriladi.
/// route: 'home' | 'kirim' | 'chiqim' | 'voice' | 'pro'
typedef WidgetRouteHandler = void Function(String route);
WidgetRouteHandler? widgetRouteHandler;

class WidgetSync extends StatefulWidget {
  final Widget child;
  const WidgetSync({super.key, required this.child});

  @override
  State<WidgetSync> createState() => _WidgetSyncState();
}

class _WidgetSyncState extends State<WidgetSync> {
  String _lastPayload = '';

  @override
  void initState() {
    super.initState();
    // Ilova widget deep-link orqali ochilganda
    HomeWidget.setAppGroupId('pulkam');
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_onUri);
    HomeWidget.widgetClicked.listen(_onUri);
  }

  void _onUri(Uri? uri) {
    if (uri == null) return;
    // pulkam://widget/kirim  → route = "kirim"
    final route = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : uri.host;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widgetRouteHandler?.call(route);
    });
  }

  void _sync(BuildContext context) {
    // Ma'lumot doim yoziladi — foydalanuvchi widgetni qo'lda ham qo'shishi
    // mumkin (toggle faqat avto-qo'shish uchun). Bo'sh qolmasligi kerak.
    final soz = context.read<SozlamalarCubit>().state;

    final l10n = AppL10n(soz.tilKod.isEmpty ? 'uz' : soz.tilKod);
    final hisobSum = context.read<HisobCubit>().state.hisoblar.fold<double>(
        0, (s, h) => s + (double.tryParse(h.balance) ?? 0));
    final maqsadSum = context
        .read<MaqsadCubit>()
        .state
        .maqsadlar
        .where((m) => !m.bajarilgan)
        .fold<double>(0, (s, m) => s + (double.tryParse(m.balance) ?? 0));
    final total = hisobSum + maqsadSum;
    final balanceStr = appFmt(total, soz.formatKod);

    final payload = '$balanceStr|${soz.valyutaKod}|${soz.tilKod}'
        '|${soz.mavzuRang.toARGB32()}|${soz.isPro}';
    if (payload == _lastPayload) return; // o'zgarmagan bo'lsa qayta yozmaymiz
    _lastPayload = payload;

    updateHomeWidget(
      balance: balanceStr,
      currency: soz.valyutaKod,
      balanceLabel: l10n.umumiyBalans,
      kirimText: l10n.kirim,
      chiqimText: l10n.chiqim,
      voiceText: l10n.ovoz,
      themeColor: soz.mavzuRang,
      isPro: soz.isPro,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Har build'da (state o'zgarsa) widget'ni sinxronlaymiz
    _sync(context);
    return widget.child;
  }
}
