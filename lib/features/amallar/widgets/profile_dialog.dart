import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulkam/features/profile/logic/profile_cubit.dart';
import 'package:pulkam/features/malumotlar/logic/sozlamalar_cubit.dart';
import 'package:pulkam/l10n.dart';

const _kAccent = Color(0xFF6C3CE1);

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  const _GlassIconBtn({required this.icon, required this.onTap, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent
                  ? _kAccent.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: accent
                    ? _kAccent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: accent
                  ? [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

Future<void> showProfileDialog(BuildContext context) {
  final profileCubit = context.read<ProfileCubit>();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yopish',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) =>
        _ProfileDialog(profileCubit: profileCubit),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _ProfileDialog extends StatefulWidget {
  final ProfileCubit profileCubit;
  const _ProfileDialog({required this.profileCubit});

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastNameCtrl;
  bool _nameError = false;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final existing = widget.profileCubit.state.profile;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    if (existing?.avatarPath != null) {
      _avatarFile = File(existing!.avatarPath!);
    }
    _nameCtrl.addListener(() {
      if (_nameError && _nameCtrl.text.trim().isNotEmpty) {
        setState(() => _nameError = false);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    widget.profileCubit.saveProfile(
      name: name,
      lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      avatarPath: _avatarFile?.path,
    );
    Navigator.pop(context);
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _input({
    required TextEditingController ctrl,
    required String hint,
    String? errorText,
  }) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 14,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFFE74C3C),
          fontWeight: FontWeight.w500,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: _border(Colors.white.withValues(alpha: 0.15)),
        focusedBorder: _border(_kAccent, width: 2),
        errorBorder: _border(const Color(0xFFE74C3C), width: 1.5),
        focusedErrorBorder: _border(const Color(0xFFE74C3C), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenH = MediaQuery.of(context).size.height;
    final kBg = context.read<SozlamalarCubit>().state.mavzuRang;

    return Stack(
      children: [
        // Blur orqa fon
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),

        // Dialog
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: screenH * 0.22,
            ),
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white.withValues(alpha: 0.12),
                              backgroundImage: _avatarFile != null
                                  ? FileImage(_avatarFile!)
                                  : null,
                              child: _avatarFile == null
                                  ? const Icon(
                                      CupertinoIcons.person_fill,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _kAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kBg, width: 2.5),
                                ),
                                child: const Icon(
                                  CupertinoIcons.camera_fill,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.profil,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Ism
                      _input(
                        ctrl: _nameCtrl,
                        hint: l10n.ismKiriting,
                        errorText: _nameError ? l10n.ismXato : null,
                      ),
                      const SizedBox(height: 10),
                      // Familiya
                      _input(
                        ctrl: _lastNameCtrl,
                        hint: l10n.familiyaKiriting,
                      ),
                      const SizedBox(height: 22),
                      // Tugmalar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GlassIconBtn(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 20),
                          _GlassIconBtn(
                            icon: Icons.check_rounded,
                            onTap: _save,
                            accent: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
