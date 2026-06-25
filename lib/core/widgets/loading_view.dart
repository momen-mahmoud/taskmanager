import 'package:flutter/material.dart';

/// Centered loading indicator with three bouncing dots — a playful alternative
/// to a plain spinner. Used as the `loading` branch of `AsyncValue`.
class LoadingView extends StatefulWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 22,
            width: 64,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (i) {
                    final t = (_controller.value - i * 0.18) % 1.0;
                    final bounce = (1 - (t * 2 - 1).abs()).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, -10 * bounce),
                      child: Container(
                        height: 13,
                        width: 13,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.5 + 0.5 * bounce),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 18),
            Text(widget.message!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
