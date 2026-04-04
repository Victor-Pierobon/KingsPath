class Attribute {
  final String id; // forca, inteligencia, sabedoria, destreza, carisma, relacionamento
  final String name;
  final String icon;
  final int level;
  final int currentXp;
  final int totalXpEarned;

  const Attribute({
    required this.id,
    required this.name,
    required this.icon,
    required this.level,
    required this.currentXp,
    required this.totalXpEarned,
  });

  int get xpForNextLevel => 100 + 40 * level + 10 * level * level;

  double get xpProgress => currentXp / xpForNextLevel;

  Attribute copyWith({int? level, int? currentXp, int? totalXpEarned}) {
    return Attribute(
      id: id,
      name: name,
      icon: icon,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
    );
  }

  Map<String, dynamic> toMap() => {
        'attribute': id,
        'level': level,
        'current_xp': currentXp,
        'total_xp_earned': totalXpEarned,
      };

  static Attribute fromMap(Map<String, dynamic> map) {
    final id = map['attribute'] as String;
    return Attribute(
      id: id,
      name: _nameFor(id),
      icon: _iconFor(id),
      level: int.tryParse(map['level'].toString()) ?? 1,
      currentXp: int.tryParse(map['current_xp'].toString()) ?? 0,
      totalXpEarned: int.tryParse(map['total_xp_earned'].toString()) ?? 0,
    );
  }

  static String _nameFor(String id) => const {
        'forca': 'Força',
        'inteligencia': 'Inteligência',
        'sabedoria': 'Sabedoria',
        'destreza': 'Destreza',
        'carisma': 'Carisma',
        'relacionamento': 'Relacionamento',
      }[id] ??
      id;

  static String _iconFor(String id) => const {
        'forca': '⚡',
        'inteligencia': '📘',
        'sabedoria': '🌿',
        'destreza': '💨',
        'carisma': '👁',
        'relacionamento': '🤝',
      }[id] ??
      '?';

  static List<Attribute> defaults(String playerName) => const [
        'forca',
        'inteligencia',
        'sabedoria',
        'destreza',
        'carisma',
        'relacionamento',
      ]
          .map((id) => Attribute(
                id: id,
                name: _nameFor(id),
                icon: _iconFor(id),
                level: 1,
                currentXp: 0,
                totalXpEarned: 0,
              ))
          .toList();
}
