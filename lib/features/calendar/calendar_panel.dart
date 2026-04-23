import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quest.dart';
import '../../widgets/floating_window.dart';
import '../quests/quest_board_panel.dart';

const _months = [
  'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
  'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
];
const _weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

class CalendarPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final bool mobileMode;

  const CalendarPanel({super.key, required this.onClose, this.mobileMode = false});

  @override
  ConsumerState<CalendarPanel> createState() => _CalendarPanelState();
}

class _CalendarPanelState extends ConsumerState<CalendarPanel> {
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  Map<DateTime, List<Quest>> _groupByDay(List<Quest> quests) {
    final map = <DateTime, List<Quest>>{};
    for (final q in quests) {
      if (q.completedAt == null) continue;
      final d = DateTime(q.completedAt!.year, q.completedAt!.month, q.completedAt!.day);
      map.putIfAbsent(d, () => []).add(q);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(questsProvider)
        .where((q) => q.status == QuestStatus.completed)
        .toList();
    final byDay = _groupByDay(completed);
    final selectedQuests = _selectedDay != null ? (byDay[_selectedDay] ?? []) : <Quest>[];

    return FloatingWindow(
      width: widget.mobileMode ? null : 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(widget.mobileMode),
          _buildMonthNav(),
          _buildWeekdayLabels(),
          _buildGrid(byDay),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedDay != null
                ? _buildDayDetail(selectedQuests)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(bool mobileMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.accent, width: 0.5)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'PROGRESSÃO DIÁRIA',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          if (!mobileMode)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
              onPressed: widget.onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month - 1);
              _selectedDay = null;
            }),
          ),
          Text(
            '${_months[_month.month - 1]}  ${_month.year}',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month + 1);
              _selectedDay = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _weekdays
            .map((l) => Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGrid(Map<DateTime, List<Quest>> byDay) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7; // 0=Sun
    final today = DateTime.now();

    final cells = <Widget>[
      for (int i = 0; i < leadingBlanks; i++) const SizedBox(),
      for (int day = 1; day <= daysInMonth; day++)
        Builder(builder: (_) {
          final date = DateTime(_month.year, _month.month, day);
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected = _selectedDay == date;
          final dayQuests = byDay[date] ?? [];
          final totalXp = dayQuests.fold(0, (sum, q) => sum + q.totalXp);

          return _DayCell(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            totalXp: totalXp,
            questCount: dayQuests.length,
            onTap: () => setState(() {
              _selectedDay = isSelected ? null : date;
            }),
          );
        }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
    );
  }

  Widget _buildDayDetail(List<Quest> quests) {
    return Container(
      key: ValueKey(_selectedDay),
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: quests.isEmpty
          ? const Text(
              'Nenhuma quest concluída neste dia.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: +${quests.fold(0, (s, q) => s + q.totalXp)} XP',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...quests.map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('✓  ', style: TextStyle(color: AppColors.success, fontSize: 13)),
                            Expanded(
                              child: Text(
                                q.title,
                                style: const TextStyle(color: AppColors.text, fontSize: 13),
                              ),
                            ),
                            Text(
                              '+${q.totalXp}xp',
                              style: const TextStyle(color: AppColors.accent, fontSize: 12),
                            ),
                          ],
                        ),
                        if (q.reflection != null && q.reflection!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 3),
                            child: Text(
                              '💭  ${q.reflection}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final int totalXp;
  final int questCount;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.totalXp,
    required this.questCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const maxXp = 200.0;
    final xpIntensity = totalXp > 0 ? (totalXp / maxXp).clamp(0.15, 1.0) : 0.0;

    Color? bgColor;
    if (isSelected) {
      bgColor = AppColors.accent.withValues(alpha: 0.45);
    } else if (xpIntensity > 0) {
      bgColor = AppColors.accent.withValues(alpha: xpIntensity * 0.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isToday
                ? AppColors.gold
                : isSelected
                    ? AppColors.accent
                    : Colors.transparent,
            width: isToday ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isToday
                      ? AppColors.gold
                      : totalXp > 0
                          ? AppColors.text
                          : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (questCount > 0)
              Positioned(
                bottom: 2,
                right: 3,
                child: Text(
                  '$questCount',
                  style: const TextStyle(color: AppColors.accent, fontSize: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
