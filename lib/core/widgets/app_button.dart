import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chunky, rounded primary button with a springy press animation and a
/// built-in loading spinner. Optionally tinted with a custom [color].
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.color ?? scheme.primary;
    final fg = widget.color != null ? Colors.white : scheme.onPrimary;

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: _enabled ? bg : bg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.rButton),
          elevation: _enabled && !_pressed ? 4 : 0,
          shadowColor: bg.withValues(alpha: 0.5),
          child: InkWell(
            onTap: _enabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(AppTheme.rButton),
            child: SizedBox(
              height: 56,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 21, color: fg),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
