import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/player.dart';
import '../../core/models/attribute.dart';
import '../../widgets/floating_window.dart';
import '../../widgets/draggable_panel.dart';
import '../quests/quest_board_panel.dart';
import '../quests/create_quest_panel.dart';
import 'radar_chart_widget.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier()
      : super(Player(
          name: 'Victor',
          attributes: Attribute.defaults('Victor'),
        ));

  void updateAttribute(Attribute attr) {
    state = state.copyWithAttribute(attr);
  }
}

final _showQuestsProvider = StateProvider<bool>((ref) => false);
final _showCreateProvider = StateProvider<bool>((ref) => false);

class DashboardPanel extends ConsumerWidget {
  const DashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final showQuests = ref.watch(_showQuestsProvider);
    final showCreate = ref.watch(_showCreateProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          DraggablePanel(
            initialOffset: const Offset(16, 16),
            child: _DashboardContent(player: player),
          ),
          if (showQuests)
            DraggablePanel(
              initialOffset: const Offset(360, 16),
              child: QuestBoardPanel(
                onClose: () =>
                    ref.read(_showQuestsProvider.notifier).state = false,
              ),
            ),
          if (showCreate)
            DraggablePanel(
              initialOffset: const Offset(360, 16),
              child: CreateQuestPanel(
                onClose: () =>
                    ref.read(_showCreateProvider.notifier).state = false,
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final Player player;

  const _DashboardContent({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingWindow(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(player),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: RadarChartWidget(attributes: player.attributes),
          ),
          const SizedBox(height: 16),
          _buttons(ref),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _header(Player player) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.accent, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rank ${player.rank.name}  •  Lv. ${player.globalLevel}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Text('⚔', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buttons(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _GlowButton(
              label: 'Quests',
              onTap: () =>
                  ref.read(_showQuestsProvider.notifier).state = true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GlowButton(
              label: '+ Nova',
              onTap: () =>
                  ref.read(_showCreateProvider.notifier).state = true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GlowButton(
              label: 'Stats',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 1),
          borderRadius: BorderRadius.circular(6),
          boxShadow: AppColors.borderGlow,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
