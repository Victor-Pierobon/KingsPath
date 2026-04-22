import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/models/attribute.dart';
import '../core/models/player.dart';
import '../core/models/quest.dart';

class SupabaseService {
  static final instance = SupabaseService._();
  SupabaseService._();

  SupabaseClient get _db => Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password) =>
      _db.auth.signUp(email: email, password: password);

  Future<void> signOut() => _db.auth.signOut();

  // ── Player ────────────────────────────────────────────────────────────────

  Future<Player?> fetchPlayer() async {
    final profile = await _db
        .from('profile')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    if (profile == null) return null;

    final rows = await _db.from('attributes').select().eq('user_id', _uid);
    final name = profile['name'] as String;

    final attributes = (rows as List).isEmpty
        ? Attribute.defaults(name)
        : rows.map((r) => Attribute.fromMap({
              'attribute': r['attribute_id'],
              'level': r['level'],
              'current_xp': r['current_xp'],
              'total_xp_earned': r['total_xp_earned'],
            })).toList();

    return Player(name: name, attributes: attributes);
  }

  Future<void> initPlayer(Player player) async {
    await _db.from('profile').upsert({'user_id': _uid, 'name': player.name});
    for (final attr in player.attributes) {
      await upsertAttribute(attr);
    }
  }

  Future<void> upsertAttribute(Attribute attr) => _db.from('attributes').upsert(
        {
          'user_id': _uid,
          'attribute_id': attr.id,
          'level': attr.level,
          'current_xp': attr.currentXp,
          'total_xp_earned': attr.totalXpEarned,
        },
        onConflict: 'user_id,attribute_id',
      );

  // ── Quests ────────────────────────────────────────────────────────────────

  Future<List<Quest>> fetchQuests() async {
    final rows = await _db
        .from('quests')
        .select()
        .eq('user_id', _uid)
        .order('created_at');

    return (rows as List).map((r) {
      final rawXp = r['xp_per_attribute'] as Map<String, dynamic>;
      return Quest(
        id: r['id'] as String,
        title: r['title'] as String,
        description: r['description'] as String? ?? '',
        xpPerAttribute: rawXp.map((k, v) => MapEntry(k, (v as num).toInt())),
        difficulty: QuestDifficulty.values.firstWhere(
          (d) => d.name == r['difficulty'],
          orElse: () => QuestDifficulty.facil,
        ),
        dueDate: r['due_date'] != null ? DateTime.parse(r['due_date']) : null,
        recurrence: QuestRecurrence.values.firstWhere(
          (rec) => rec.name == r['recurrence'],
          orElse: () => QuestRecurrence.none,
        ),
        status: QuestStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => QuestStatus.pending,
        ),
        createdAt: DateTime.parse(r['created_at'] as String),
        completedAt:
            r['completed_at'] != null ? DateTime.parse(r['completed_at']) : null,
        isSystemQuest: r['is_system_quest'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> insertQuest(Quest q) => _db.from('quests').insert({
        'id': q.id,
        'user_id': _uid,
        'title': q.title,
        'description': q.description,
        'xp_per_attribute': q.xpPerAttribute,
        'difficulty': q.difficulty.name,
        'due_date': q.dueDate?.toIso8601String(),
        'recurrence': q.recurrence.name,
        'status': q.status.name,
        'created_at': q.createdAt.toIso8601String(),
        'completed_at': q.completedAt?.toIso8601String(),
        'is_system_quest': q.isSystemQuest,
      });

  Future<void> updateQuestStatus(
    String id,
    QuestStatus status,
    DateTime? completedAt,
  ) =>
      _db.from('quests').update({
        'status': status.name,
        'completed_at': completedAt?.toIso8601String(),
      }).eq('id', id);
}
