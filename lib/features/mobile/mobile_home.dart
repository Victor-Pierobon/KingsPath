import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/attribute.dart';
import '../../core/utils/xp_calculator.dart';
import '../dashboard/dashboard_panel.dart';
import '../dashboard/radar_chart_widget.dart';
import '../quests/quest_board_panel.dart';
import '../quests/create_quest_panel.dart';
import '../calendar/calendar_panel.dart';

class MobileHome extends ConsumerStatefulWidget {
  const MobileHome({super.key});

  @override
  ConsumerState<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends ConsumerState<MobileHome> {
  int _tab = 0;

  void _openCreate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: CreateQuestPanel(onClose: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: const [
            _DashTab(),
            _QuestsTab(),
            _CalendarTab(),
          ],
        ),
      ),
      floatingActionButton: _tab == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: _openCreate,
              child: const Icon(Icons.add, color: Colors.black87),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Quests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
        ],
      ),
    );
  }
}

class _DashTab extends ConsumerWidget {
  const _DashTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final info = player.archetypeInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rank ${player.rank.name}  •  Lv. ${player.globalLevel}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(info.icon, style: TextStyle(fontSize: 12, color: info.color)),
                        const SizedBox(width: 4),
                        Text(
                          info.label.toUpperCase(),
                          style: TextStyle(
                            color: info.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (player.archetype.name != 'equilibrado') ...[
                          const SizedBox(width: 8),
                          _archetypeBadge(player, info.color),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(info.icon, style: TextStyle(fontSize: 32, color: info.color)),
            ],
          ),
          const SizedBox(height: 24),
          // Radar chart
          SizedBox(
            height: 260,
            child: RadarChartWidget(attributes: player.attributes),
          ),
          const SizedBox(height: 24),
          // Attribute bars
          const Text(
            'ATRIBUTOS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...player.attributes.map((a) => _AttributeBar(attribute: a)),
        ],
      ),
    );
  }

  Widget _archetypeBadge(dynamic player, Color color) {
    if (player.archetypeBonusUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 0.5),
        ),
        child: Text(
          '+5% XP',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Text(
      'Nv. ${player.archetypeLevel}/10',
      style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11),
    );
  }
}

class _AttributeBar extends StatelessWidget {
  final Attribute attribute;

  const _AttributeBar({required this.attribute});

  @override
  Widget build(BuildContext context) {
    final xpNeeded = xpForLevel(attribute.level);
    final progress = (attribute.currentXp / xpNeeded).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${attribute.icon} ${attribute.name}',
                  style: const TextStyle(color: AppColors.text, fontSize: 13)),
              const Spacer(),
              Text(
                'Lv. ${attribute.level}  •  ${attribute.currentXp}/$xpNeeded xp',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestsTab extends StatelessWidget {
  const _QuestsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: QuestBoardPanel(onClose: () {}, mobileMode: true),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: CalendarPanel(onClose: () {}, mobileMode: true),
    );
  }
}
