import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quest.dart';
import '../../core/utils/xp_calculator.dart';
import '../../widgets/floating_window.dart';
import 'quest_board_panel.dart';

const _attributes = [
  'forca', 'inteligencia', 'sabedoria', 'destreza', 'carisma', 'relacionamento'
];
const _attributeLabels = {
  'forca': '⚡ Força',
  'inteligencia': '📘 Inteligência',
  'sabedoria': '🌿 Sabedoria',
  'destreza': '💨 Destreza',
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
  QuestDifficulty _difficulty = QuestDifficulty.medio;
  int _baseXp = 50;

  static const _xpPresets = [25, 50, 100, 250, 500];

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
            const Text('XP base por atributo',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            _xpPresetChips(),
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

  Widget _xpPresetChips() {
    return Wrap(
      spacing: 6,
      children: _xpPresets.map((xp) {
        final selected = _baseXp == xp;
        return GestureDetector(
          onTap: () => setState(() => _baseXp = xp),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$xp',
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.textMuted,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _xpPreview() {
    final finalXp = applyDifficulty(_baseXp, _difficulty);
    final multiplier = difficultyMultiplier(_difficulty);
    final multiplierStr = multiplier == multiplier.truncateToDouble()
        ? '${multiplier.toInt()}x'
        : '${multiplier}x';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$_baseXp × $multiplierStr = $finalXp XP por atributo',
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
    final quest = Quest(
      id: const Uuid().v4(),
      title: title,
      description: _descCtrl.text.trim(),
      xpPerAttribute: {for (final a in _selected) a: _baseXp},
      difficulty: _difficulty,
      recurrence: QuestRecurrence.none,
      status: QuestStatus.pending,
      createdAt: DateTime.now(),
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
