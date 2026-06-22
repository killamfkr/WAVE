import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Theme-aware skeleton loader. Replaces every spinner in the app — the spec
/// forbids `CircularProgressIndicator`/`LinearProgressIndicator`.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final base = theme.onSurface.withValues(alpha: 0.06);
    final highlight = theme.onSurface.withValues(alpha: 0.14);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + t * 2, -0.3),
                end: Alignment(1 + t * 2, 0.3),
                colors: <Color>[base, highlight, base],
                stops: const <double>[0.35, 0.5, 0.65],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Convenience: square shimmer used as the cover-art placeholder.
class ShimmerSquare extends StatelessWidget {
  const ShimmerSquare({super.key, required this.size, this.radius = 8});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// Convenience: circular shimmer for artist-portrait placeholders.
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
