import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';
import 'package:pulkam/services/notification_service.dart';

void showReminderDialog(BuildContext context) {
  final cubit = context.read<SozlamalarCubit>();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => BlocProvider.value(
      value: cubit,
      child: const _ReminderDialog(),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _ReminderDialog extends StatelessWidget {
  const _ReminderDialog();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SozlamalarCubit, SozlamalarState>(
      builder: (context, state) {
        final bg = state.mavzuRang;
        final cardBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.07), bg);
        final l10n = context.l10n;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              ),
            ),
            Dialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        l10n.eslatmalar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 8),
                    ...List.generate(3, (i) => _ReminderRow(index: i)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReminderRow extends StatefulWidget {
  final int index;
  const _ReminderRow({required this.index});

  @override
  State<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<_ReminderRow> {
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();
    final item = context.read<SozlamalarCubit>().state.reminders[widget.index];
    _hourCtrl = FixedExtentScrollController(initialItem: item.hour);
    _minCtrl  = FixedExtentScrollController(initialItem: item.minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _save({bool? enabled, int? hour, int? minute}) {
    final cubit = context.read<SozlamalarCubit>();
    final old   = cubit.state.reminders[widget.index];
    final next  = old.copyWith(
      enabled: enabled,
      hour:    hour,
      minute:  minute,
    );
    cubit.setReminder(widget.index, next).then((_) {
      _applyNotification(next, widget.index);
    });
  }

  void _applyNotification(ReminderItem item, int id) {
    if (item.enabled) {
      scheduleDaily(
        id,
        item.hour,
        item.minute,
        'PulKam 💰',
        "Bugungi xarajatlarni kiritdingizmi?",
      );
    } else {
      cancelNotification(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SozlamalarCubit>().state;
    final item  = state.reminders[widget.index];
    final bg    = state.mavzuRang;
    final rowBg = Color.alphaBlend(Colors.white.withValues(alpha: 0.05), bg);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // ── Soat picker ───────────────────────────────────────────
          _TimePicker(
            controller: _hourCtrl,
            itemCount: 24,
            label: (v) => v.toString().padLeft(2, '0'),
            onChanged: (v) => _save(hour: v),
            enabled: item.enabled,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: TextStyle(
                color: item.enabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ── Minut picker ──────────────────────────────────────────
          _TimePicker(
            controller: _minCtrl,
            itemCount: 60,
            label: (v) => v.toString().padLeft(2, '0'),
            onChanged: (v) => _save(minute: v),
            enabled: item.enabled,
          ),
          const Spacer(),
          // ── Toggle ────────────────────────────────────────────────
          CupertinoSwitch(
            value: item.enabled,
            activeTrackColor: const Color(0xFF34C759),
            onChanged: (v) async {
              final granted = await requestPermission();
              if (!granted) return;
              _save(enabled: v);
            },
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) label;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const _TimePicker({
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 90,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 36,
        looping: true,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: Colors.white.withValues(alpha: enabled ? 0.1 : 0.04),
        ),
        onSelectedItemChanged: enabled ? onChanged : (_) {},
        children: List.generate(
          itemCount,
          (i) => Center(
            child: Text(
              label(i),
              style: TextStyle(
                color: enabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
