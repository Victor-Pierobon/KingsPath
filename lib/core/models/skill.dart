class Skill {
  final String id;
  final String name;
  final List<String> attributeIds;
  final List<String> relatedSkillIds;
  final DateTime? lastPracticedAt;
  final DateTime createdAt;

  const Skill({
    required this.id,
    required this.name,
    required this.attributeIds,
    this.relatedSkillIds = const [],
    this.lastPracticedAt,
    required this.createdAt,
  });

  // 0.0 = apagada | 1.0 = pleno brilho. Nunca chega a zero — habilidade nunca é perdida.
  double get brightness {
    if (lastPracticedAt == null) return 0.35;
    final days = DateTime.now().difference(lastPracticedAt!).inDays;
    if (days <= 7) return 1.0;
    if (days <= 30) return 0.72;
    if (days <= 90) return 0.48;
    return 0.25;
  }

  String get brightnessLabel {
    if (lastPracticedAt == null) return 'Nunca praticada';
    final days = DateTime.now().difference(lastPracticedAt!).inDays;
    if (days == 0) return 'Praticada hoje';
    if (days <= 7) return 'Praticada há $days dia${days > 1 ? 's' : ''}';
    if (days <= 30) return 'Praticada há ${(days / 7).floor()} semana${(days / 7).floor() > 1 ? 's' : ''}';
    if (days <= 90) return 'Praticada há ${(days / 30).floor()} mês';
    return 'Praticada há mais de 3 meses';
  }

  Skill copyWith({
    String? name,
    List<String>? attributeIds,
    List<String>? relatedSkillIds,
    DateTime? lastPracticedAt,
  }) {
    return Skill(
      id: id,
      name: name ?? this.name,
      attributeIds: attributeIds ?? this.attributeIds,
      relatedSkillIds: relatedSkillIds ?? this.relatedSkillIds,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'attribute_ids': attributeIds,
        'related_skill_ids': relatedSkillIds,
        'last_practiced_at': lastPracticedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  static Skill fromMap(Map<String, dynamic> map) => Skill(
        id: map['id'] as String,
        name: map['name'] as String,
        attributeIds: (map['attribute_ids'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        relatedSkillIds: (map['related_skill_ids'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        lastPracticedAt: map['last_practiced_at'] != null
            ? DateTime.tryParse(map['last_practiced_at'] as String)
            : null,
        createdAt:
            DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
      );
}
