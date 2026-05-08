import 'package:flutter/material.dart';
import 'attribute.dart';
import '../constants/app_ranks.dart';

enum Archetype { guerreiro, mago, rei, equilibrado }

class Player {
  final String name;
  final List<Attribute> attributes;

  const Player({required this.name, required this.attributes});

  int get globalLevel {
    final sum = attributes.fold(0, (acc, a) => acc + a.level);
    return (sum - 5).clamp(1, 9999);
  }

  Rank get rank => rankFromLevel(globalLevel);

  int _avg(List<String> ids) {
    final attrs = attributes.where((a) => ids.contains(a.id)).toList();
    if (attrs.isEmpty) return 0;
    return attrs.fold(0, (s, a) => s + a.level) ~/ attrs.length;
  }

  Archetype get archetype {
    final guerreiro = _avg(['fisico', 'espiritualidade']);
    final mago = _avg(['inteligencia', 'sabedoria']);
    final rei = _avg(['carisma', 'relacionamento']);
    final maxVal = [guerreiro, mago, rei].reduce((a, b) => a > b ? a : b);
    final diff = maxVal - [guerreiro, mago, rei].reduce((a, b) => a < b ? a : b);
    if (diff < 2) return Archetype.equilibrado;
    if (maxVal == guerreiro) return Archetype.guerreiro;
    if (maxVal == mago) return Archetype.mago;
    return Archetype.rei;
  }

  ({String label, String icon, Color color}) get archetypeInfo =>
      switch (archetype) {
        Archetype.guerreiro =>
          (label: 'Guerreiro', icon: '⚔', color: const Color(0xFFEF5350)),
        Archetype.mago =>
          (label: 'Mago', icon: '✦', color: const Color(0xFF7B5CF0)),
        Archetype.rei =>
          (label: 'Rei', icon: '♛', color: const Color(0xFFF0C040)),
        Archetype.equilibrado =>
          (label: 'Equilibrado', icon: '◈', color: const Color(0xFF4CAF50)),
      };

  static const _archetypeAttrs = {
    Archetype.guerreiro: ['fisico', 'espiritualidade'],
    Archetype.mago: ['inteligencia', 'sabedoria'],
    Archetype.rei: ['carisma', 'relacionamento'],
    Archetype.equilibrado: <String>[],
  };

  int get archetypeLevel => _avg(_archetypeAttrs[archetype]!);

  bool get archetypeBonusUnlocked =>
      archetype != Archetype.equilibrado && archetypeLevel >= 10;

  double xpBonusFor(String attributeId) {
    if (!archetypeBonusUnlocked) return 1.0;
    return (_archetypeAttrs[archetype]!.contains(attributeId)) ? 1.05 : 1.0;
  }

  Attribute? attribute(String id) {
    try {
      return attributes.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Player copyWithAttribute(Attribute updated) {
    return Player(
      name: name,
      attributes: attributes.map((a) => a.id == updated.id ? updated : a).toList(),
    );
  }
}
