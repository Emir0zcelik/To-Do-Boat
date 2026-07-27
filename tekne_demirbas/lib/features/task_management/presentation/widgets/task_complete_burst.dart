import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

/// Checkbox tamamlandığında kısa bir confetti / particle patlaması gösterir.
void showTaskCompleteBurst(BuildContext context, {Offset? origin}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final size = MediaQuery.sizeOf(context);
  final burstOrigin = origin ?? Offset(size.width * 0.85, size.height * 0.35);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => IgnorePointer(
      child: TaskCompleteBurst(
        origin: burstOrigin,
        onCompleted: () {
          entry.remove();
        },
      ),
    ),
  );
  overlay.insert(entry);
}

class TaskCompleteBurst extends StatefulWidget {
  const TaskCompleteBurst({
    super.key,
    required this.origin,
    required this.onCompleted,
  });

  final Offset origin;
  final VoidCallback onCompleted;

  @override
  State<TaskCompleteBurst> createState() => _TaskCompleteBurstState();
}

class _TaskCompleteBurstState extends State<TaskCompleteBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  static const _colors = [
    Appstyles.primaryBlue,
    Appstyles.secondaryBlue,
    Color(0xFF4CAF50),
    Color(0xFFFFC107),
    Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _particles = List.generate(28, (i) {
      final angle = (i / 28) * math.pi * 2 + random.nextDouble() * 0.4;
      final speed = 90 + random.nextDouble() * 140;
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed - 40,
        color: _colors[i % _colors.length],
        size: 4 + random.nextDouble() * 5,
        spin: (random.nextDouble() - 0.5) * 8,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BurstPainter(
            progress: Curves.easeOutCubic.transform(_controller.value),
            origin: widget.origin,
            particles: _particles,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  const _Particle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    required this.spin,
  });

  final double dx;
  final double dy;
  final Color color;
  final double size;
  final double spin;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.origin,
    required this.particles,
  });

  final double progress;
  final Offset origin;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final gravity = 180.0 * progress * progress;

    for (final p in particles) {
      final x = origin.dx + p.dx * progress;
      final y = origin.dy + p.dy * progress + gravity;
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * progress);
      final half = p.size / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(half * 0.4),
        ),
        paint,
      );
      canvas.restore();
    }

    // Merkez check pulse
    final pulse = (1.0 - progress);
    if (pulse > 0) {
      final ringPaint = Paint()
        ..color = Appstyles.secondaryBlue.withValues(alpha: pulse * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(origin, 12 + progress * 36, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
