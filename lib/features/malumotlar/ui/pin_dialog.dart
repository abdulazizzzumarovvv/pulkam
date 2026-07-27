import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

// ── PIN o'rnatish dialogi (settings toggledan ochiladi) ──────────────────────
Future<void> showPinSetupDialog(BuildContext context) {
  final cubit = context.read<SozlamalarCubit>();
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => BlocProvider.value(
      value: cubit,
      child: const _PinDialog(mode: _PinMode.setup),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

// ── PIN kirish ekrani (app ochilganda) ───────────────────────────────────────
class PinLockScreen extends StatelessWidget {
  final VoidCallback onUnlocked;
  const PinLockScreen({super.key, required this.onUnlocked});

  @override
  Widget build(BuildContext context) {
    final bg = context.read<SozlamalarCubit>().state.mavzuRang;
    return Scaffold(
      backgroundColor: bg,
      body: _PinPad(
        mode: _PinMode.unlock,
        bg: bg,
        onSuccess: onUnlocked,
        onCancel: null,
      ),
    );
  }
}

// ── Ichki ────────────────────────────────────────────────────────────────────
enum _PinMode { setup, unlock }

class _PinDialog extends StatefulWidget {
  final _PinMode mode;
  const _PinDialog({super.key, required this.mode});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  @override
  Widget build(BuildContext context) {
    final bg = context.watch<SozlamalarCubit>().state.mavzuRang;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.6)),
        ),
        SafeArea(
          child: _PinPad(
            mode: widget.mode,
            bg: bg,
            onSuccess: () {
              Navigator.pop(context);
            },
            onCancel: () {
              context.read<SozlamalarCubit>().setPinCode(false);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

// ── Asosiy PIN pad widget ─────────────────────────────────────────────────────
class _PinPad extends StatefulWidget {
  final _PinMode mode;
  final Color bg;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  const _PinPad({
    required this.mode,
    required this.bg,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<_PinPad> with SingleTickerProviderStateMixin {
  final List<String> _digits = [];
  static const int _pinLen = 4;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _input(String d) {
    if (_digits.length >= _pinLen) return;
    setState(() => _digits.add(d));
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  void _onComplete() async {
    final pin = _digits.join();
    if (widget.mode == _PinMode.setup) {
      final cubit = context.read<SozlamalarCubit>();
      cubit.savePinValue(pin);
      cubit.setPinCode(true);
      await Future.delayed(const Duration(milliseconds: 120));
      widget.onSuccess();
    } else {
      final saved = context.read<SozlamalarCubit>().state.pinValue;
      if (pin == saved) {
        widget.onSuccess();
      } else {
        await _shakeCtrl.forward(from: 0);
        setState(() => _digits.clear());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.bg;
    final btnBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.09), bg);
    final btnBorder = Colors.white.withValues(alpha: 0.12);
    final filled = _digits.length == _pinLen;

    final l10n = context.l10n;
    final title = widget.mode == _PinMode.setup
        ? l10n.pinKodYarating
        : l10n.pinKodKiriting;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sarlavha
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // Nuqtalar
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) {
            final dx = _shakeCtrl.isAnimating
                ? 12 * (0.5 - (_shakeAnim.value % 1)).abs() * 2
                : 0.0;
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLen, (i) {
              final active = i < _digits.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: active ? 0.0 : 0.35),
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 40),

        // Klaviatura
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _row(['1', '2', '3'], btnBg, btnBorder),
              const SizedBox(height: 10),
              _row(['4', '5', '6'], btnBg, btnBorder),
              const SizedBox(height: 10),
              _row(['7', '8', '9'], btnBg, btnBorder),
              const SizedBox(height: 10),
              // Oxirgi qator: bo'sh | 0 | delete/check
              Row(
                children: [
                  // Chap: bekor qilish (setup) yoki bo'sh (unlock)
                  Expanded(
                    child: widget.onCancel != null
                        ? _KeyBtn(
                            bg: btnBg,
                            border: btnBorder,
                            onTap: widget.onCancel!,
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 24,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _KeyBtn(
                      bg: btnBg,
                      border: btnBorder,
                      child: Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () => _input('0'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // O'ng: delete → check (to'ldirilganda)
                  Expanded(
                    child: _KeyBtn(
                      bg: filled
                          ? Color.alphaBlend(
                              Colors.white.withValues(alpha: 0.18), bg)
                          : btnBg,
                      border: btnBorder,
                      onTap: filled ? _onComplete : _backspace,
                      child: Icon(
                        filled
                            ? Icons.check_rounded
                            : Icons.backspace_outlined,
                        color: Colors.white.withValues(alpha: filled ? 1.0 : 0.6),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(List<String> ds, Color bg, Color border) {
    return Row(
      children: [
        for (int i = 0; i < ds.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _KeyBtn(
              bg: bg,
              border: border,
              child: Text(
                ds[i],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => _input(ds[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _KeyBtn extends StatelessWidget {
  final Color bg;
  final Color border;
  final Widget child;
  final VoidCallback onTap;
  const _KeyBtn({
    required this.bg,
    required this.border,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}
