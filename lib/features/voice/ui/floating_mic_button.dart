import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/features/voice/ui/voice_input_dialog.dart';

const _kOltin = Color(0xFFD4AF37);
const _kOltinOchiq = Color(0xFFF5D061);
const _kSize = 52.0;

/// Floating dumaloq mikrofon — barcha ekranlar ustida turadi (Pro).
/// Sudrab istalgan joyga qo'yish mumkin, joyi eslab qolinadi.
class FloatingMicButton extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const FloatingMicButton({super.key, required this.navigatorKey});

  @override
  State<FloatingMicButton> createState() => _FloatingMicButtonState();
}

class _FloatingMicButtonState extends State<FloatingMicButton> {
  Offset? _pos;

  void _saqla() {
    if (_pos == null) return;
    final box = Hive.box('settings');
    box.put('mic_pos_x', _pos!.dx);
    box.put('mic_pos_y', _pos!.dy);
  }

  Offset _defaultPos(Size size) =>
      Offset(size.width - _kSize - 16, size.height - _kSize - 130);

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<SozlamalarCubit>().state.isPro;
    if (!isPro) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: voiceDialogOchiq,
      builder: (context, dialogOchiq, _) {
        // Gapirish rejimida floating tugma yashirinadi
        if (dialogOchiq) return const SizedBox.shrink();
        return _tugma(context);
      },
    );
  }

  Widget _tugma(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_pos == null) {
      final box = Hive.box('settings');
      final x = box.get('mic_pos_x') as double?;
      final y = box.get('mic_pos_y') as double?;
      _pos = (x != null && y != null) ? Offset(x, y) : _defaultPos(size);
    }
    // Ekran chegarasidan chiqib ketmasin
    final pos = Offset(
      _pos!.dx.clamp(4.0, size.width - _kSize - 4),
      _pos!.dy.clamp(
          MediaQuery.of(context).padding.top + 4, size.height - _kSize - 4),
    );

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _pos = _pos! + d.delta),
        onPanEnd: (_) => _saqla(),
        onTap: () {
          final ctx = widget.navigatorKey.currentContext;
          if (ctx != null) showVoiceInputDialog(ctx);
        },
        child: Container(
          width: _kSize,
          height: _kSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kOltinOchiq, _kOltin],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kOltin.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
