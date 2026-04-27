import 'dart:ui';

import 'package:flutter/material.dart';

// ── Theme tokens (samakan dengan login_page.dart) ────────────────────────
const kBgColors = [
  Color(0xFF0D0A2E),
  Color(0xFF130E3A),
  Color(0xFF0A0820),
];
const kAccentStart = Color(0xFF6366F1);
const kAccentEnd = Color(0xFF8B5CF6);
const kAccentLight = Color(0xFFA5B4FC);

/// Dark gradient + 2 glow blob, dipakai semua halaman counter (operator,
/// profile, select loket) supaya konsisten dengan login.
class CounterShell extends StatelessWidget {
  final Widget child;
  const CounterShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0820),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: kBgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -90,
              child: _glowBlob(kAccentStart, 320),
            ),
            Positioned(
              bottom: -70,
              left: -70,
              child: _glowBlob(kAccentEnd, 260),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }

  static Widget _glowBlob(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.25), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism container ala login form card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Gradient indigo→violet — primary action.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [kAccentStart, kAccentEnd],
          ),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: kAccentStart.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
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
}

/// Outlined glass button — secondary action.
class GhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onPressed;
  const GhostButton({
    super.key,
    required this.label,
    required this.icon,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: c),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: c,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand badge ala login (chip indigo dengan dot di kiri).
class BrandBadge extends StatelessWidget {
  final String label;
  const BrandBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: kAccentStart.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kAccentStart.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
              radius: 3, backgroundColor: Color(0xFF818CF8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kAccentLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill counter ("Skip 2×", dst).
class CountChip extends StatelessWidget {
  final String label;
  final Color color;
  const CountChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Dark-themed input decoration konsisten dengan login form.
InputDecoration darkInputDecoration({
  String? labelText,
  String? hintText,
  String? helperText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
  bool readOnly = false,
}) {
  OutlineInputBorder ring(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
    labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
    floatingLabelStyle: const TextStyle(color: kAccentLight),
    hintStyle: const TextStyle(color: Colors.white24),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: Colors.white30, size: 18),
    suffixIcon: suffixIcon,
    errorText: errorText,
    errorStyle: const TextStyle(color: Color(0xFFFC8181), fontSize: 12),
    filled: true,
    fillColor: Colors.white
        .withValues(alpha: readOnly ? 0.025 : 0.05),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: ring(Colors.white.withValues(alpha: 0.08)),
    enabledBorder: ring(Colors.white.withValues(alpha: 0.1)),
    focusedBorder: ring(kAccentStart, width: 1.5),
    errorBorder: ring(const Color(0xFFFC8181)),
    focusedErrorBorder: ring(const Color(0xFFFC8181), width: 1.5),
    disabledBorder: ring(Colors.white.withValues(alpha: 0.05)),
  );
}

/// Topbar standar (back / brand badge / actions).
class CounterTopbar extends StatelessWidget {
  final String? badgeLabel;
  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const CounterTopbar({
    super.key,
    this.badgeLabel,
    this.title,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: 'Kembali',
              color: Colors.white70,
              hoverColor: Colors.white.withValues(alpha: 0.06),
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack,
            )
          else
            const SizedBox(width: 8),
          if (badgeLabel != null) BrandBadge(label: badgeLabel!),
          if (title != null) ...[
            if (badgeLabel != null) const SizedBox(width: 12),
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          ...actions,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
