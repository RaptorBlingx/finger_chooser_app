// lib/core/widgets/gradient_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Premium gradient button with animations and haptic feedback
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final bool isOutlined;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.isOutlined = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppTheme.primaryGradient;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppDurations.fast,
        curve: AppCurves.easeOut,
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: widget.isOutlined ? null : gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: widget.isOutlined
                ? Border.all(
                    width: 2,
                    color: AppTheme.primaryStart,
                  )
                : null,
            boxShadow: widget.isOutlined ? null : AppTheme.buttonShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    Text(
                      widget.text,
                      style: AppTheme.button.copyWith(
                        color: widget.isOutlined
                            ? AppTheme.primaryStart
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.normal).slideY(
          begin: 0.2,
          end: 0,
          duration: AppDurations.normal,
          curve: AppCurves.easeOut,
        );
  }
}
