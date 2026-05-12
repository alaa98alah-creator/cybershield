import 'package:cybershield/core/constants/app_constants.dart';
import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class TactileButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? shadowColor;
  final IconData? icon;
  final bool isFullWidth;
  final double? fontSize;
  final Gradient? gradient;

  const TactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.shadowColor,
    this.icon,
    this.isFullWidth = true,
    this.fontSize,
    this.gradient,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.shadowColor ?? AppColors.onPrimaryFixedVariant;
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final textColor = widget.textColor ?? AppColors.onPrimaryFixed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          0,
          _isPressed ? AppConstants.tactilePressOffset : 0,
          0,
        ),
        width: widget.isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          color: widget.gradient == null ? bgColor : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: Offset(
                0,
                _isPressed
                    ? AppConstants.tactilePressOffset
                    : AppConstants.tactileShadowDepth,
              ),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTypography.headlineLg.copyWith(
                    color: textColor,
                    fontSize: widget.fontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
