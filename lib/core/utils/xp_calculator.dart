import '../models/attribute.dart';

class LevelUpResult {
  final Attribute attribute;
  final bool leveledUp;
  final int oldLevel;

  const LevelUpResult({
    required this.attribute,
    required this.leveledUp,
    required this.oldLevel,
  });
}

LevelUpResult addXp(Attribute attr, int xp) {
  final oldLevel = attr.level;
  var currentXp = attr.currentXp + xp;
  var level = attr.level;

  while (true) {
    final needed = 100 + 40 * level + 10 * level * level;
    if (currentXp >= needed) {
      currentXp -= needed;
      level++;
    } else {
      break;
    }
  }

  final updated = attr.copyWith(
    level: level,
    currentXp: currentXp,
    totalXpEarned: attr.totalXpEarned + xp,
  );

  return LevelUpResult(
    attribute: updated,
    leveledUp: level > oldLevel,
    oldLevel: oldLevel,
  );
}
