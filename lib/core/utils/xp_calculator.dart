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

class LevelDownResult {
  final Attribute attribute;
  final bool leveledDown;
  final int oldLevel;

  const LevelDownResult({
    required this.attribute,
    required this.leveledDown,
    required this.oldLevel,
  });
}

int xpForLevel(int level) => 80 + 20 * level + 15 * level * level;

double difficultyMultiplier(QuestDifficulty d) => switch (d) {
      QuestDifficulty.facil => 1.0,
      QuestDifficulty.medio => 1.5,
      QuestDifficulty.dificil => 3.0,
      QuestDifficulty.epico => 7.0,
    };

int applyDifficulty(int baseXp, QuestDifficulty difficulty) =>
    (baseXp * difficultyMultiplier(difficulty)).round();

// XP perdido por dia de inatividade — escala com nível global do jogador
// Nível 1-9: 5/dia | 10-19: 8/dia | 20-29: 11/dia | 50: 20/dia
int decayXpPerDay(int globalLevel) => 5 + (globalLevel ~/ 10) * 3;

// XP de quest calculado no momento da conclusão — escala com nível global
// Fácil: ~20 | Médio: ~50 | Difícil: ~120 | Épico: ~300  (valores no Lv.1)
int questXpForLevel(int globalLevel, QuestDifficulty difficulty) {
  final base = switch (difficulty) {
    QuestDifficulty.facil => 20,
    QuestDifficulty.medio => 50,
    QuestDifficulty.dificil => 120,
    QuestDifficulty.epico => 300,
  };
  return (base * (1.0 + globalLevel * 0.04)).round();
}

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

LevelDownResult subtractXp(Attribute attr, int xp) {
  final oldLevel = attr.level;
  var currentXp = attr.currentXp - xp;
  var level = attr.level;

  while (currentXp < 0 && level > 1) {
    level--;
    currentXp += xpForLevel(level);
  }
  if (currentXp < 0) currentXp = 0;

  return LevelDownResult(
    attribute: attr.copyWith(level: level, currentXp: currentXp),
    leveledDown: level < oldLevel,
    oldLevel: oldLevel,
  );
}
