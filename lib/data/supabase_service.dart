import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/models/attribute.dart';
import '../core/models/player.dart';
import '../core/models/quest.dart';

class SupabaseService {
  static final instance = SupabaseService._();
  SupabaseService._();

  SupabaseClient get _db => Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  void _log(String op, Object e) =>
      debugPrint('[Supabase] ERRO em $op: $e');

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password) =>
      _db.auth.signUp(email: email, password: password);

  Future<void> signOut() => _db.auth.signOut();

  // ── Player ────────────────────────────────────────────────────────────────

  Future<Player?> fetchPlayer() async {
    try {
      final profile = await _db
          .from('profile')
          .select()
          .eq('user_id', _uid)
          .maybeSingle();

      if (profile == null) return null;

      final rows = await _db
          .from('attributes')
          .select()
          .eq('user_id', _uid);

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
    } catch (e) {
      _log('fetchPlayer', e);
      rethrow;
    }
  }

  Future<void> initPlayer(Player player) async {
    try {
      await _db.from('profile').upsert({
        'user_id': _uid,
        'name': player.name,
      });
    } catch (e) {
      _log('initPlayer/profile', e);
      rethrow;
    }
    for (final attr in player.attributes) {
      try {
        await _db.from('attributes').upsert({
          'user_id': _uid,
          'attribute_id': attr.id,
          'level': attr.level,
          'current_xp': attr.currentXp,
          'total_xp_earned': attr.totalXpEarned,
        });
      } catch (e) {
        _log('initPlayer/attribute(${attr.id})', e);
        rethrow;
      }
    }
  }

  Future<void> saveAttribute(Attribute attr) async {
    try {
      await _db.from('attributes').upsert({
        'user_id': _uid,
        'attribute_id': attr.id,
        'level': attr.level,
        'current_xp': attr.currentXp,
        'total_xp_earned': attr.totalXpEarned,
      });
    } catch (e) {
      _log('saveAttribute(${attr.id})', e);
      rethrow;
    }
  }

  // ── Quests ────────────────────────────────────────────────────────────────

  Future<List<Quest>> fetchQuests() async {
    try {
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
          completedAt: r['completed_at'] != null
              ? DateTime.parse(r['completed_at'])
              : null,
          reflection: r['reflection'] as String?,
          isSystemQuest: r['is_system_quest'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      _log('fetchQuests', e);
      rethrow;
    }
  }

  Future<void> insertQuest(Quest q) async {
    try {
      await _db.from('quests').insert({
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
    } catch (e) {
      _log('insertQuest(${q.id})', e);
      rethrow;
    }
  }

  Future<void> updateQuestStatus(
    String id,
    QuestStatus status,
    DateTime? completedAt, {
    String? reflection,
  }) async {
    try {
      await _db.from('quests').update({
        'status': status.name,
        'completed_at': completedAt?.toIso8601String(),
        'reflection': reflection,
      }).eq('id', id).eq('user_id', _uid);
    } catch (e) {
      _log('updateQuestStatus($id)', e);
      rethrow;
    }
  }
}
