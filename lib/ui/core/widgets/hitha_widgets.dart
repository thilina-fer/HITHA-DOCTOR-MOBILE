import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/hitha_theme.dart';

final _lkr = NumberFormat('#,##0.00', 'en_US');
String formatLkr(double v) => 'LKR ${_lkr.format(v)}';

/// Three-petal lotus brand mark.
class HithaLotus extends StatelessWidget {
  const HithaLotus({super.key, this.size = 28, this.color = HithaColors.mint});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LotusPainter(color));
}

class _LotusPainter extends CustomPainter {
  _LotusPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
          Path()
            ..moveTo(w * .5, h * .08)
            ..cubicTo(w * .72, h * .35, w * .68, h * .78, w * .5, h * .94)
            ..cubicTo(w * .32, h * .78, w * .28, h * .35, w * .5, h * .08)
            ..close(),
          paint)
      ..drawPath(
          Path()
            ..moveTo(w * .44, h * .88)
            ..cubicTo(w * .14, h * .75, w * .05, h * .45, w * .25, h * .26)
            ..cubicTo(w * .36, h * .42, w * .38, h * .68, w * .44, h * .88),
          paint)
      ..drawPath(
          Path()
            ..moveTo(w * .56, h * .88)
            ..cubicTo(w * .86, h * .75, w * .95, h * .45, w * .75, h * .26)
            ..cubicTo(w * .64, h * .42, w * .62, h * .68, w * .56, h * .88),
          paint);
  }

  @override
  bool shouldRepaint(_LotusPainter old) => old.color != color;
}

/// 24px radius, white fill, 1px hairline border, subtle resting shadow.
class HithaCard extends StatelessWidget {
  const HithaCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(20),
    this.radius = HithaRadius.card,
    this.borderColor = HithaColors.hairline,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: HithaShadows.resting,
      ),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

/// Capsule, forest fill button, minimum 48dp height.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.color = HithaColors.forest,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: HithaColors.creamDark,
        disabledForegroundColor: HithaColors.inkFaint,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: HithaText.bodyMedium.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          else if (icon != null)
            Icon(icon, size: 18),
          if (loading || icon != null) const SizedBox(width: 8),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Capsule, white fill with hairline border.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: HithaColors.forest,
          side: const BorderSide(color: HithaColors.hairline),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: const StadiumBorder(),
          textStyle: HithaText.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(text),
          ],
        ),
      );
}

class TextLinkButton extends StatelessWidget {
  const TextLinkButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: HithaColors.mintDark,
          textStyle: HithaText.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      );
}

/// Capsule pill for status, category & verification badges.
class HithaPill extends StatelessWidget {
  const HithaPill({
    super.key,
    required this.text,
    this.background = HithaColors.sprout,
    this.foreground = HithaColors.moss,
    this.icon,
    this.dotColor,
  });

  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: ShapeDecoration(
          color: background,
          shape: StadiumBorder(side: BorderSide(color: foreground.withValues(alpha: 0.25))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 13, color: foreground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: HithaText.caption.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

/// Labelled text input with forest focus ring and full error handling.
class HithaTextField extends StatefulWidget {
  const HithaTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.hint,
    this.keyboardType,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;
  final int maxLines;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<HithaTextField> createState() => _HithaTextFieldState();
}

class _HithaTextFieldState extends State<HithaTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(HithaRadius.sub),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: HithaText.bodySmall.copyWith(fontWeight: FontWeight.w700, color: HithaColors.forest),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          obscureText: widget.isPassword ? _obscure : false,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: HithaText.body.copyWith(color: HithaColors.forest),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: HithaText.body.copyWith(color: HithaColors.inkFaint),
            errorText: widget.errorText,
            counterText: '',
            filled: true,
            fillColor: widget.errorText == null ? Colors.white : HithaColors.clayTint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: HithaColors.inkSoft),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffixIcon,
            enabledBorder: border(HithaColors.hairline),
            focusedBorder: border(HithaColors.forest, 1.5),
            errorBorder: border(HithaColors.clay),
            focusedErrorBorder: border(HithaColors.clay, 1.5),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.actionText, this.onAction});
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HithaText.h2),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: HithaText.bodySmall),
                  ],
                ],
              ),
            ),
            if (actionText != null && onAction != null)
              TextLinkButton(text: actionText!, onPressed: onAction!),
          ],
        ),
      );
}

class HithaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HithaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return Material(
      color: Colors.white,
      shape: const Border(bottom: BorderSide(color: HithaColors.hairline)),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: HithaSpacing.page),
            child: Row(
              children: [
                if (canPop) ...[
                  IconButton.filled(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(
                      backgroundColor: HithaColors.creamDark,
                      foregroundColor: HithaColors.forest,
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: HithaText.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(subtitle!, style: HithaText.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CaptionLabel extends StatelessWidget {
  const CaptionLabel(this.text, {super.key, this.color = HithaColors.inkFaint});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: HithaText.caption.copyWith(fontWeight: FontWeight.w700, color: color));
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: HithaText.bodySmall),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: mono
                    ? HithaText.mono.copyWith(fontWeight: FontWeight.w800)
                    : HithaText.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: HithaColors.forest),
              ),
            ),
          ],
        ),
      );
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.title, required this.message, this.action});
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => HithaCard(
        child: Column(
          children: [
            Text(title, style: HithaText.h3, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, style: HithaText.body, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      );
}

class HithaAvatar extends StatelessWidget {
  const HithaAvatar({super.key, required this.url, required this.size, this.radius = 18});
  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: size,
          height: size,
          color: HithaColors.cream,
          child: (url != null && url!.isNotEmpty)
              ? Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person, color: HithaColors.inkFaint, size: size * 0.55),
                )
              : Icon(Icons.person, color: HithaColors.inkFaint, size: size * 0.55),
        ),
      );
}

void showHithaSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? HithaColors.clay : HithaColors.forest,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
