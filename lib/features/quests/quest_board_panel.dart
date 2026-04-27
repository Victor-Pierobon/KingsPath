import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quest.dart';
import '../../core/utils/xp_calculator.dart';
import '../../data/supabase_service.dart';
import '../../widgets/floating_window.dart';
import '../dashboard/dashboard_panel.dart';
import '../../data/system_quests_data.dart';

void _showSaveError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Falha ao salvar. Verifique sua conexão.'),
    backgroundColor: Color(0xFFEF5350),
  ));
}

final questsProvider = StateNotifierProvider<QuestsNotifier, List<Quest>>((ref) {
  return QuestsNotifier();
});

class QuestsNotifier extends StateNotifier<List<Quest>> {
  QuestsNotifier() : super([]);

  Future<void> loadFromSupabase() async {
    state = await SupabaseService.instance.fetchQuests();
  }

  Future<void> addQuest(Quest quest) async {
    state = [...state, quest];
    await SupabaseService.instance.insertQuest(quest);
  }

  Future<void> completeQuest(String id, {String? reflection}) async {
    final completedAt = DateTime.now();
    state = state
        .map((q) => q.id == id
            ? q.copyWith(
                status: QuestStatus.completed,
                completedAt: completedAt,
                reflection: reflection,
              )
            : q)
        .toList();
    await SupabaseService.instance.updateQuestStatus(
        id, QuestStatus.completed, completedAt,
        reflection: reflection);
  }

  Future<void> addSystemQuest(Quest quest) async {
    if (!state.any((q) => q.id == quest.id)) {
      state = [...state, quest];
      await SupabaseService.instance.insertQuest(quest);
    }
  }
}

class QuestBoardPanel extends ConsumerWidget {
  final VoidCallback onClose;
  final bool mobileMode;

  const QuestBoardPanel({super.key, required this.onClose, this.mobileMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questsProvider)
        .where((q) => q.status == QuestStatus.pending)
        .toList();

    Widget list = quests.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Nenhuma quest pendente.\nCrie uma ou sugira uma do dia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: quests.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _QuestCard(quest: quests[i]),
          );

    if (!mobileMode) {
      list = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: quests.isEmpty
            ? list
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: quests.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _QuestCard(quest: quests[i]),
              ),
      );
    }

    return FloatingWindow(
      width: mobileMode ? null : 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          list,
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
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ignorar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(questsProvider.notifier).addSystemQuest(quest);
              } catch (e) {
                if (context.mounted) _showSaveError(context);
              }
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
                label: '✓ Concluir',
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
    final reflectionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.accent),
        ),
        title: Text(
          quest.title,
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '+${applyDifficulty(quest.totalXp, quest.difficulty)} XP total',
              style: const TextStyle(color: AppColors.accent, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              'O que você aprendeu? (opcional)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reflectionCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Reflexão, insight, observação...',
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 12),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.accent, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.4), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final reflection = reflectionCtrl.text.trim().isEmpty
                  ? null
                  : reflectionCtrl.text.trim();
              Navigator.pop(dialogContext);
              await _applyCompletion(context, ref, reflection);
            },
            child: const Text('CONCLUIR',
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCompletion(BuildContext context, WidgetRef ref, String? reflection) async {
    final playerNotifier = ref.read(playerProvider.notifier);
    final player = ref.read(playerProvider);
    final levelUps = <String>[];
    final saves = <Future<void>>[];

    for (final entry in quest.xpPerAttribute.entries) {
      final attr = player.attribute(entry.key);
      if (attr == null) continue;
      final base = applyDifficulty(entry.value, quest.difficulty);
      final xp = (base * player.xpBonusFor(entry.key)).round();
      final result = addXp(attr, xp);
      saves.add(playerNotifier.updateAttribute(result.attribute));
      if (result.leveledUp) {
        levelUps.add('${attr.name} ${result.oldLevel} → ${result.attribute.level}');
      }
    }

    saves.add(ref.read(questsProvider.notifier).completeQuest(quest.id, reflection: reflection));

    try {
      await Future.wait(saves);
    } catch (e) {
      if (context.mounted) _showSaveError(context);
      return;
    }

    if (levelUps.isNotEmpty && context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
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
