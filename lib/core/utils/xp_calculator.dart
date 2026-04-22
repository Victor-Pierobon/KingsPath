import '../models/attribute.dart';
import '../models/quest.dart';

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

// Nova curva: rápida nos níveis iniciais, exigente no late game
int xpForLevel(int level) => 80 + 20 * level + 15 * level * level;

double difficultyMultiplier(QuestDifficulty d) => switch (d) {
      QuestDifficulty.facil => 1.0,
      QuestDifficulty.medio => 1.5,
      QuestDifficulty.dificil => 3.0,
      QuestDifficulty.epico => 7.0,
    };

int applyDifficulty(int baseXp, QuestDifficulty difficulty) =>
    (baseXp * difficultyMultiplier(difficulty)).round();

LevelUpResult addXp(Attribute attr, int xp) {
  final oldLevel = attr.level;
  var currentXp = attr.currentXp + xp;
  var level = attr.level;

  while (true) {
    final needed = xpForLevel(level);
    if (currentXp >= needed) {
      currentXp -= needed;
      level++;
    } else {
      break;
    }
  }

  return LevelUpResult(
    attribute: attr.copyWith(
      level: level,
      currentXp: currentXp,
      totalXpEarned: attr.totalXpEarned + xp,
    ),
    leveledUp: level > oldLevel,
    oldLevel: oldLevel,
  );
}
