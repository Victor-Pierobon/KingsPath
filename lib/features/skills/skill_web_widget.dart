import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/attribute.dart';
import '../../core/models/skill.dart';

class SkillWebWidget extends StatefulWidget {
  final List<Attribute> attributes;
  final List<Skill> skills;
  final String? selectedSkillId;
  final ValueChanged<String> onSkillTap;

  const SkillWebWidget({
    super.key,
    required this.attributes,
    required this.skills,
    required this.selectedSkillId,
    required this.onSkillTap,
  });

  @override
  State<SkillWebWidget> createState() => _SkillWebWidgetState();
}

class _SkillWebWidgetState extends State<SkillWebWidget> {
  // Posições computadas por LayoutBuilder — chave: 'attr_<id>' ou skill.id
  Map<String, Offset> _positions = {};

  Map<String, Offset> _computePositions(Size size) {
    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);
    final attrRadius = min(size.width, size.height) / 2 * 0.62;

    // Nós de atributo: hexágono ao redor do centro
    final attrIds = widget.attributes.map((a) => a.id).toList();
    for (var i = 0; i < attrIds.length; i++) {
      final angle = (2 * pi * i / attrIds.length) - pi / 2;
      positions['attr_${attrIds[i]}'] = Offset(
        center.dx + attrRadius * cos(angle),
        center.dy + attrRadius * sin(angle),
      );
    }

    // Nós de habilidade: posicionados pelo centróide dos atributos conectados
    final attrPositions = {
      for (final id in attrIds)
        if (positions.containsKey('attr_$id')) id: positions['attr_$id']!,
    };

    for (var i = 0; i < widget.skills.length; i++) {
      final skill = widget.skills[i];
      final connectedPositions = skill.attributeIds
          .map((id) => attrPositions[id])
          .whereType<Offset>()
          .toList();

      Offset base;
      if (connectedPositions.isEmpty) {
        // Sem atributo: distribui ao redor do centro com ângulo áureo
        final angle = i * 2.399; // ângulo áureo em radianos
        base = Offset(
          center.dx + cos(angle) * 45,
          center.dy + sin(angle) * 45,
        );
      } else {
        final centroid = Offset(
          connectedPositions.map((p) => p.dx).reduce((a, b) => a + b) /
              connectedPositions.length,
          connectedPositions.map((p) => p.dy).reduce((a, b) => a + b) /
              connectedPositions.length,
        );
        // Posiciona 60% do caminho do centro ao centróide
        base = Offset(
          center.dx + (centroid.dx - center.dx) * 0.60,
          center.dy + (centroid.dy - center.dy) * 0.60,
        );
      }

      // Offset determinístico baseado no ID para distribuir habilidades do mesmo grupo
      final hash = skill.id.hashCode.abs();
      final spreadAngle = (hash % 628) / 100.0;
      final spreadDist = 22.0 + (hash % 28).toDouble();
      positions[skill.id] = Offset(
        base.dx + cos(spreadAngle) * spreadDist,
        base.dy + sin(spreadAngle) * spreadDist,
      );
    }

    return positions;
  }

  void _handleTap(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    String? nearest;
    double minDist = 22.0; // raio de toque

    for (final entry in _positions.entries) {
      if (entry.key.startsWith('attr_')) continue;
      final dist = (entry.value - local).distance;
      if (dist < minDist) {
        minDist = dist;
        nearest = entry.key;
      }
    }
    if (nearest != null) widget.onSkillTap(nearest);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _positions = _computePositions(size);

      return GestureDetector(
        onTapUp: _handleTap,
        child: CustomPaint(
          painter: _SkillWebPainter(
            attributes: widget.attributes,
            skills: widget.skills,
            positions: _positions,
            selectedSkillId: widget.selectedSkillId,
          ),
          size: size,
        ),
      );
    });
  }
}

class _SkillWebPainter extends CustomPainter {
  final List<Attribute> attributes;
  final List<Skill> skills;
  final Map<String, Offset> positions;
  final String? selectedSkillId;

  const _SkillWebPainter({
    required this.attributes,
    required this.skills,
    required this.positions,
    required this.selectedSkillId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawAttrSkillEdges(canvas);
    _drawSkillSkillEdges(canvas);
    _drawAttributeNodes(canvas);
    _drawSkillNodes(canvas);
  }

  void _drawAttrSkillEdges(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;
    for (final skill in skills) {
      final skillPos = positions[skill.id];
      if (skillPos == null) continue;
      for (final attrId in skill.attributeIds) {
        final attrPos = positions['attr_$attrId'];
        if (attrPos == null) continue;
        canvas.drawLine(attrPos, skillPos, paint);
      }
    }
  }

  void _drawSkillSkillEdges(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    final drawn = <String>{};
    for (final skill in skills) {
      final posA = positions[skill.id];
      if (posA == null) continue;
      for (final relId in skill.relatedSkillIds) {
        final key = [skill.id, relId]..sort();
        if (drawn.contains(key.join())) continue;
        drawn.add(key.join());
        final posB = positions[relId];
        if (posB == null) continue;
        canvas.drawLine(posA, posB, paint);
      }
    }
  }

  void _drawAttributeNodes(Canvas canvas) {
    for (final attr in attributes) {
      final pos = positions['attr_${attr.id}'];
      if (pos == null) continue;

      // Halo
      canvas.drawCircle(
        pos, 18,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Círculo
      canvas.drawCircle(pos, 14,
          Paint()..color = AppColors.surface);
      canvas.drawCircle(
        pos, 14,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Ícone
      final tp = TextPainter(
        text: TextSpan(
          text: attr.icon,
          style: const TextStyle(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawSkillNodes(Canvas canvas) {
    for (final skill in skills) {
      final pos = positions[skill.id];
      if (pos == null) continue;
      final b = skill.brightness;
      final isSelected = skill.id == selectedSkillId;
      final nodeColor = _brightnessToColor(b);

      // Glow halo — mais intenso se selecionado
      final glowRadius = isSelected ? 18.0 : 12.0;
      final glowAlpha = isSelected ? b * 0.55 : b * 0.28;
      canvas.drawCircle(
        pos, glowRadius,
        Paint()
          ..color = nodeColor.withValues(alpha: glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );

      // Nó
      canvas.drawCircle(pos, 8,
          Paint()..color = AppColors.background);
      canvas.drawCircle(
        pos, 8,
        Paint()
          ..color = nodeColor.withValues(alpha: b * 0.9 + 0.1)
          ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = isSelected ? 0 : 1.5,
      );
      if (isSelected) {
        canvas.drawCircle(
          pos, 8,
          Paint()
            ..color = AppColors.background.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: skill.name,
          style: TextStyle(
            color: nodeColor.withValues(alpha: b * 0.8 + 0.15),
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 70);
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy + 10),
      );
    }
  }

  Color _brightnessToColor(double b) {
    const bright = AppColors.accent;
    const dim = Color(0xFF1C3A3A);
    return Color.lerp(dim, bright, b)!;
  }

  @override
  bool shouldRepaint(_SkillWebPainter old) =>
      old.skills != skills ||
      old.selectedSkillId != selectedSkillId ||
      old.positions != positions;
}
