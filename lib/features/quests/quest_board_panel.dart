import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quest.dart';
import '../../core/utils/xp_calculator.dart';
import '../../data/supabase_service.dart';
import '../../widgets/floating_window.dart';
import '../dashboard/dashboard_panel.dart';
import '../../data/system_quests_data.dart';

final questsProvider = StateNotifierProvider<QuestsNotifier, List<Quest>>((ref) {
  return QuestsNotifier();
});

class QuestsNotifier extends StateNotifier<List<Quest>> {
  QuestsNotifier() : super([]);

  Future<void> loadFromSupabase() async {
    state = await SupabaseService.instance.fetchQuests();
  }

  void addQuest(Quest quest) {
    state = [...state, quest];
    SupabaseService.instance.insertQuest(quest);
  }

  void completeQuest(String id) {
    final completedAt = DateTime.now();
    state = state
        .map((q) => q.id == id
            ? q.copyWith(status: QuestStatus.completed, completedAt: completedAt)
            : q)
        .toList();
    SupabaseService.instance.updateQuestStatus(id, QuestStatus.completed, completedAt);
  }

  void addSystemQuest(Quest quest) {
    if (!state.any((q) => q.id == quest.id)) {
      state = [...state, quest];
      SupabaseService.instance.insertQuest(quest);
    }
  }
}

class QuestBoardPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const QuestBoardPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questsProvider)
        .where((q) => q.status == QuestStatus.pending)
        .toList();

    return FloatingWindow(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          if (quests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhuma quest pendente.\nCrie uma ou sugira uma do dia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: quests.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _QuestCard(quest: quests[i]),
              ),
            ),
          _suggestButton(context, ref),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.accent, width: 0.5)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'QUESTS PENDENTES',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _suggestButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _suggestQuest(context, ref),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text(
            '✦  Sugerir Quest do Dia',
            style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _suggestQuest(BuildContext context, WidgetRef ref) {
    final idx = DateTime.now().millisecondsSinceEpoch % systemQuests.length;
    final quest = systemQuests[idx];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.accent),
        ),
        title: const Text('⚔ NOVA QUEST DISPONÍVEL',
            style: TextStyle(color: AppColors.text, fontSize: 14, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title,
                style: const TextStyle(
                    color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('+${quest.totalXp} XP  •  ${quest.xpPerAttribute.keys.first}',
                style: const TextStyle(color: AppColors.accent, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ignorar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(questsProvider.notifier).addSystemQuest(quest);
              Navigator.pop(context);
            },
            child: const Text('Aceitar',
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends ConsumerWidget {
  final Quest quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quest.title,
              style: const TextStyle(
                  color: AppColors.text, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            quest.xpPerAttribute.entries.map((e) => '+${e.value} XP ${e.key}').join('  '),
            style: const TextStyle(color: AppColors.accent, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionButton(
                label: 'Concluir',
                color: AppColors.success,
                onTap: () => _complete(context, ref),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Abandonar',
                color: AppColors.danger,
                onTap: () => ref.read(questsProvider.notifier).completeQuest(quest.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _complete(BuildContext context, WidgetRef ref) {
    ref.read(questsProvider.notifier).completeQuest(quest.id);

    final playerNotifier = ref.read(playerProvider.notifier);
    final player = ref.read(playerProvider);
    final levelUps = <String>[];

    for (final entry in quest.xpPerAttribute.entries) {
      final attr = player.attribute(entry.key);
      if (attr == null) continue;
      final result = addXp(attr, entry.value);
      playerNotifier.updateAttribute(result.attribute);
      if (result.leveledUp) {
        levelUps.add('${attr.name} ${result.oldLevel} → ${result.attribute.level}');
      }
    }

    if (levelUps.isNotEmpty && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.gold),
          ),
          title: const Text('✦ LEVEL UP! ✦',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gold, fontSize: 18, letterSpacing: 2)),
          content: Text(levelUps.join('\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
