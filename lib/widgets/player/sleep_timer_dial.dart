import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/sleep_timer.dart';
import '../../core/theme/app_theme.dart';

/// Custom radial sleep-timer picker. Drag around the dial to set minutes.
/// Snaps to common stops (5, 10, 15, 20, 30, 45, 60).
class SleepTimerDial extends ConsumerStatefulWidget {
  const SleepTimerDial({super.key});

  @override
  ConsumerState<SleepTimerDial> createState() => _SleepTimerDialState();
}

class _SleepTimerDialState extends ConsumerState<SleepTimerDial> {
  static const List<int> _stops = <int>[5, 10, 15, 20, 30, 45, 60];
  int _minutes = 15;

  void _updateFromOffset(Offset local, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = local.dx - cx;
    final dy = local.dy - cy;
    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += math.pi * 2;
    final minutes = (angle / (math.pi * 2) * 60).round().clamp(1, 60);
    final snapped = _snap(minutes);
    if (snapped != _minutes) setState(() => _minutes = snapped);
  }

  int _snap(int m) {
    int best = _stops.first;
    int bestDist = (m - best).abs();
    for (final s in _stops) {
      final d = (m - s).abs();
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final timer = ref.watch(sleepTimerProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'SLEEP TIMER',
            style: TextStyle(
              color: theme.onSurfaceMuted,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, c) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) =>
                          _updateFromOffset(d.localPosition, c.biggest),
                      onTapDown: (d) =>
                          _updateFromOffset(d.localPosition, c.biggest),
                      child: CustomPaint(
                        painter: _DialPainter(
                          minutes: _minutes,
                          track: theme.onSurface.withValues(alpha: 0.08),
                          filled: theme.accent,
                          tick: theme.onSurfaceMuted,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '$_minutes',
                                style: TextStyle(
                                  color: theme.onSurface,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: -3,
                                ),
                              ),
                              Text(
                                'minutes',
                                style: TextStyle(
                                  color: theme.onSurfaceMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              if (timer != null && timer.isActive)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(sleepTimerProvider.notifier).cancel();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.error),
                      ),
                      child: Text(
                        'CANCEL TIMER',
                        style: TextStyle(
                          color: theme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              if (timer != null && timer.isActive) const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref
                        .read(sleepTimerProvider.notifier)
                        .start(Duration(minutes: _minutes));
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'START',
                      style: TextStyle(
                        color: theme.background,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.minutes,
    required this.track,
    required this.filled,
    required this.tick,
  });

  final int minutes;
  final Color track;
  final Color filled;
  final Color tick;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 16;
    final stroke = 14.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    final sweep = (minutes / 60) * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = filled
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    // Tick marks every 5 minutes.
    final tickPaint = Paint()..color = tick;
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + i * (math.pi * 2 / 12);
      final inner = c + Offset(math.cos(angle), math.sin(angle)) * (r - 22);
      final outer = c + Offset(math.cos(angle), math.sin(angle)) * (r - 16);
      canvas.drawLine(
        inner,
        outer,
        tickPaint
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
    // Knob.
    final knobAngle = -math.pi / 2 + sweep;
    final knob = c + Offset(math.cos(knobAngle), math.sin(knobAngle)) * r;
    canvas.drawCircle(knob, 9, Paint()..color = filled);
    canvas.drawCircle(knob, 4, Paint()..color = tick);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.minutes != minutes || old.filled != filled;
}
