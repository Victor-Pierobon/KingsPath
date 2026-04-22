enum QuestDifficulty { facil, medio, dificil, epico }

enum QuestStatus { pending, completed, failed, skipped }

enum QuestRecurrence { none, daily, weekly }

class Quest {
  final String id;
  final String title;
  final String description;
  final Map<String, int> xpPerAttribute; // {'forca': 60, 'inteligencia': 20}
  final QuestDifficulty difficulty;
  final DateTime? dueDate;
  final QuestRecurrence recurrence;
  final QuestStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? reflection;
  final bool isSystemQuest;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpPerAttribute,
    required this.difficulty,
    this.dueDate,
    required this.recurrence,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.reflection,
    this.isSystemQuest = false,
  });

  int get totalXp => xpPerAttribute.values.fold(0, (a, b) => a + b);

  Quest copyWith({QuestStatus? status, DateTime? completedAt, String? reflection}) => Quest(
        id: id,
        title: title,
        description: description,
        xpPerAttribute: xpPerAttribute,
        difficulty: difficulty,
        dueDate: dueDate,
        recurrence: recurrence,
        status: status ?? this.status,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
        reflection: reflection ?? this.reflection,
        isSystemQuest: isSystemQuest,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'attributes': xpPerAttribute.keys.join(','),
        'xp_per_attribute': xpPerAttribute.values.join(','),
        'difficulty': difficulty.name,
        'due_date': dueDate?.toIso8601String() ?? '',
        'recurrence': recurrence.name,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  static Quest fromMap(Map<String, dynamic> map) {
    final attrs = (map['attributes'] as String).split(',');
    final xps = (map['xp_per_attribute'] as String).split(',');
    final xpMap = {
      for (var i = 0; i < attrs.length; i++)
        attrs[i]: int.tryParse(xps[i]) ?? 0,
    };
    return Quest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      xpPerAttribute: xpMap,
      difficulty: QuestDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => QuestDifficulty.medio,
      ),
      dueDate: map['due_date'] != '' ? DateTime.tryParse(map['due_date']) : null,
      recurrence: QuestRecurrence.values.firstWhere(
        (r) => r.name == map['recurrence'],
        orElse: () => QuestRecurrence.none,
      ),
      status: QuestStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => QuestStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['created_at']) ?? DateTime.now(),
    );
  }
}
