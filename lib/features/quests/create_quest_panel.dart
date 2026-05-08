import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quest.dart';
import '../../core/utils/xp_calculator.dart';
import '../../widgets/floating_window.dart';
import '../dashboard/dashboard_panel.dart';
import '../skills/skills_panel.dart';
import 'quest_board_panel.dart';

const _attributes = [
  'fisico', 'inteligencia', 'sabedoria', 'espiritualidade', 'carisma', 'relacionamento'
];
const _attributeLabels = {
  'fisico': '💪 Físico',
  'inteligencia': '📘 Inteligência',
  'sabedoria': '🌿 Sabedoria',
  'espiritualidade': '✨ Espiritualidade',
  'carisma': '👁 Carisma',
  'relacionamento': '🤝 Relacionamento',
};

class CreateQuestPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const CreateQuestPanel({super.key, required this.onClose});

  @override
  ConsumerState<CreateQuestPanel> createState() => _CreateQuestPanelState();
}

class _CreateQuestPanelState extends ConsumerState<CreateQuestPanel> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Set<String> _selected = {};
  final Set<String> _selectedSkills = {};
  QuestDifficulty _difficulty = QuestDifficulty.medio;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWindow(
      width: 340,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _field('Título', _titleCtrl),
            const SizedBox(height: 12),
            _field('Descrição (opcional)', _descCtrl, maxLines: 2),
            const SizedBox(height: 12),
            const Text('Atributos',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            _attributeChips(),
            const SizedBox(height: 12),
            _skillsSection(),
            const SizedBox(height: 12),
            const Text('Dificuldade',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            _difficultyChips(),
            const SizedBox(height: 12),
            _xpPreview(),
            const SizedBox(height: 20),
            _createButton(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Text('NOVA QUEST',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              )),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.4), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _attributeChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _attributes.map((attr) {
        final selected = _selected.contains(attr);
        return GestureDetector(
          onTap: () => setState(() {
            selected ? _selected.remove(attr) : _selected.add(attr);
          }),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.accent
                    : AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _attributeLabels[attr] ?? attr,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _skillsSection() {
    final skills = ref.watch(skillsProvider);
    if (skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Habilidades praticadas (opcional)',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        const Text(
          'Reacende o brilho dessas habilidades na teia',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills.map((skill) {
            final on = _selectedSkills.contains(skill.id);
            return GestureDetector(
              onTap: () => setState(
                  () => on ? _selectedSkills.remove(skill.id) : _selectedSkills.add(skill.id)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: on
                      ? AppColors.gold.withValues(alpha: 0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: on
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill.name,
                  style: TextStyle(
                      color: on ? AppColors.gold : AppColors.textMuted,
                      fontSize: 11),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _xpPreview() {
    final globalLevel = ref.read(playerProvider).globalLevel;
    final xp = questXpForLevel(globalLevel, _difficulty);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$xp XP por atributo  •  Lv. $globalLevel global',
        style: const TextStyle(color: AppColors.accent, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _difficultyChips() {
    final labels = {
      QuestDifficulty.facil: 'Fácil',
      QuestDifficulty.medio: 'Médio',
      QuestDifficulty.dificil: 'Difícil',
      QuestDifficulty.epico: 'Épico',
    };
    return Wrap(
      spacing: 6,
      children: QuestDifficulty.values.map((d) {
        final selected = _difficulty == d;
        return GestureDetector(
          onTap: () => setState(() => _difficulty = d),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.accent
                    : AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labels[d]!,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _createButton() {
    return GestureDetector(
      onTap: _create,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(6),
          boxShadow: AppColors.borderGlow,
        ),
        alignment: Alignment.center,
        child: const Text(
          'CRIAR QUEST',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Preencha o título e selecione ao menos um atributo.')),
      );
      return;
    }
    final globalLevel = ref.read(playerProvider).globalLevel;
    final xp = questXpForLevel(globalLevel, _difficulty);
    final quest = Quest(
      id: const Uuid().v4(),
      title: title,
      description: _descCtrl.text.trim(),
      xpPerAttribute: {for (final a in _selected) a: xp},
      difficulty: _difficulty,
      recurrence: QuestRecurrence.none,
      status: QuestStatus.pending,
      createdAt: DateTime.now(),
      skillIds: _selectedSkills.toList(),
    );
    try {
      await ref.read(questsProvider.notifier).addQuest(quest);
      widget.onClose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao salvar quest. Verifique sua conexão.'),
          backgroundColor: Color(0xFFEF5350),
        ));
      }
    }
  }
}
