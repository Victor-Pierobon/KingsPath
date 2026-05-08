class Attribute {
  final String id; // fisico, inteligencia, sabedoria, espiritualidade, carisma, relacionamento
  final String name;
  final String icon;
  final int level;
  final int currentXp;
  final int totalXpEarned;
  final DateTime? decayAppliedUntil;

  // Dias de inatividade antes da punição começar, por atributo
  static const decayGraceDays = {
    'fisico': 3,
    'inteligencia': 5,
    'sabedoria': 10,
    'espiritualidade': 7,
    'carisma': 7,
    'relacionamento': 14,
  };

  const Attribute({
    required this.id,
    required this.name,
    required this.icon,
    required this.level,
    required this.currentXp,
    required this.totalXpEarned,
    this.decayAppliedUntil,
  });

  int get xpForNextLevel => 80 + 20 * level + 15 * level * level;

  double get xpProgress => currentXp / xpForNextLevel;

  Attribute copyWith({
    int? level,
    int? currentXp,
    int? totalXpEarned,
    DateTime? decayAppliedUntil,
    bool clearDecay = false,
  }) {
    return Attribute(
      id: id,
      name: name,
      icon: icon,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      decayAppliedUntil: clearDecay ? null : (decayAppliedUntil ?? this.decayAppliedUntil),
    );
  }

  Map<String, dynamic> toMap() => {
        'attribute': id,
        'level': level,
        'current_xp': currentXp,
        'total_xp_earned': totalXpEarned,
        'decay_applied_until': decayAppliedUntil?.toIso8601String().substring(0, 10),
      };

  static Attribute fromMap(Map<String, dynamic> map) {
    var id = map['attribute'] as String;
    // Migração de IDs antigos
    if (id == 'forca') id = 'fisico';
    if (id == 'destreza') id = 'espiritualidade';
    return Attribute(
      id: id,
      name: _nameFor(id),
      icon: _iconFor(id),
      level: int.tryParse(map['level'].toString()) ?? 1,
      currentXp: int.tryParse(map['current_xp'].toString()) ?? 0,
      totalXpEarned: int.tryParse(map['total_xp_earned'].toString()) ?? 0,
      decayAppliedUntil: map['decay_applied_until'] != null
          ? DateTime.tryParse(map['decay_applied_until'] as String)
          : null,
    );
  }

  static String _nameFor(String id) => const {
        'fisico': 'Físico',
        'inteligencia': 'Inteligência',
        'sabedoria': 'Sabedoria',
        'espiritualidade': 'Espiritualidade',
        'carisma': 'Carisma',
        'relacionamento': 'Relacionamento',
      }[id] ??
      id;

  static String _iconFor(String id) => const {
        'fisico': '💪',
        'inteligencia': '📘',
        'sabedoria': '🌿',
        'espiritualidade': '✨',
        'carisma': '👁',
        'relacionamento': '🤝',
      }[id] ??
      '?';

  static List<Attribute> defaults(String playerName) => const [
        'fisico',
        'inteligencia',
        'sabedoria',
        'espiritualidade',
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
