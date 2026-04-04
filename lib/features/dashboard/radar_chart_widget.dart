import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/models/attribute.dart';
import '../../core/constants/app_colors.dart';

class RadarChartWidget extends StatelessWidget {
  final List<Attribute> attributes;

  const RadarChartWidget({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarPainter(attributes),
      child: const SizedBox.expand(),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<Attribute> attributes;

  _RadarPainter(this.attributes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 28;
    final n = attributes.length;
    final maxLevel = attributes.map((a) => a.level).fold(1, max);

    // grid
    final gridPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = (2 * pi * i / n) - pi / 2;
        final p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // spokes
    final spokePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.2)
      ..strokeWidth = 0.8;

    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        spokePaint,
      );
    }

    // filled area
    final fillPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final dataPath = Path();
    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      final ratio = attributes[i].level / max(maxLevel, 10);
      final r = radius * ratio.clamp(0.05, 1.0);
      final p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      i == 0 ? dataPath.moveTo(p.dx, p.dy) : dataPath.lineTo(p.dx, p.dy);
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, borderPaint);

    // labels
    final textStyle = TextStyle(
      color: AppColors.text,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      final labelR = radius + 20;
      final p = Offset(center.dx + labelR * cos(angle), center.dy + labelR * sin(angle));
      final attr = attributes[i];
      final label = '${attr.icon} Lv.${attr.level}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.attributes != attributes;
}
