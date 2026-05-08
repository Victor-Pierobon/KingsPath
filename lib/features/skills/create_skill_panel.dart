import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/skill.dart';

const _attrIds = [
  'fisico', 'inteligencia', 'sabedoria', 'espiritualidade', 'carisma', 'relacionamento'
];
const _attrLabels = {
  'fisico': '💪 Físico',
  'inteligencia': '📘 Inteligência',
  'sabedoria': '🌿 Sabedoria',
  'espiritualidade': '✨ Espiritualidade',
  'carisma': '👁 Carisma',
  'relacionamento': '🤝 Relacionamento',
};

class CreateSkillPanel extends ConsumerStatefulWidget {
  final List<Skill> allSkills;
  final Skill? editingSkill;
  final ValueChanged<Skill> onSave;
  final VoidCallback onClose;

  const CreateSkillPanel({
    super.key,
    required this.allSkills,
    required this.onSave,
    required this.onClose,
    this.editingSkill,
  });

  @override
  ConsumerState<CreateSkillPanel> createState() => _CreateSkillPanelState();
}

class _CreateSkillPanelState extends ConsumerState<CreateSkillPanel> {
  late final TextEditingController _nameCtrl;
  late Set<String> _selectedAttrs;
  late Set<String> _selectedRelated;

  @override
  void initState() {
    super.initState();
    final s = widget.editingSkill;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _selectedAttrs = Set.from(s?.attributeIds ?? []);
    _selectedRelated = Set.from(s?.relatedSkillIds ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<Skill> get _otherSkills => widget.allSkills
      .where((s) => s.id != widget.editingSkill?.id)
      .toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 16),
          _label('Nome da habilidade'),
          const SizedBox(height: 6),
          _nameField(),
          const SizedBox(height: 14),
          _label('Atributos relacionados'),
          const SizedBox(height: 8),
          _chips(_attrIds, _selectedAttrs,
              labelOf: (id) => _attrLabels[id] ?? id,
              color: AppColors.accent),
          if (_otherSkills.isNotEmpty) ...[
            const SizedBox(height: 14),
            _label('Habilidades conectadas (opcional)'),
            const SizedBox(height: 4),
            const Text(
              'Aparecem ligadas na teia — sem pré-requisito',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 8),
            _chips(_otherSkills.map((s) => s.id).toList(), _selectedRelated,
                labelOf: (id) =>
                    _otherSkills.firstWhere((s) => s.id == id).name,
                color: AppColors.gold),
          ],
          const SizedBox(height: 20),
          _saveButton(),
        ],
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Expanded(
            child: Text(
              widget.editingSkill != null ? 'EDITAR HABILIDADE' : 'NOVA HABILIDADE',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
            onPressed: widget.onClose,
          ),
        ],
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: AppColors.textMuted, fontSize: 12));

  Widget _nameField() => TextField(
        controller: _nameCtrl,
        style: const TextStyle(color: AppColors.text, fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black26,
          hintText: 'ex: Programação Java, Oratória, Leitura Corporal...',
          hintStyle:
              TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.accent, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.4), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.accent, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );

  Widget _chips(
    List<String> ids,
    Set<String> selected, {
    required String Function(String) labelOf,
    required Color color,
  }) =>
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: ids.map((id) {
          final on = selected.contains(id);
          return GestureDetector(
            onTap: () => setState(() => on ? selected.remove(id) : selected.add(id)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: on ? color.withValues(alpha: 0.18) : Colors.transparent,
                border: Border.all(
                    color: on ? color : color.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labelOf(id),
                style: TextStyle(
                    color: on ? color : AppColors.textMuted, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      );

  Widget _saveButton() => GestureDetector(
        onTap: _save,
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
          child: Text(
            widget.editingSkill != null ? 'SALVAR' : 'ADICIONAR',
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
        ),
      );

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome para a habilidade.')),
      );
      return;
    }
    final skill = Skill(
      id: widget.editingSkill?.id ?? const Uuid().v4(),
      name: name,
      attributeIds: _selectedAttrs.toList(),
      relatedSkillIds: _selectedRelated.toList(),
      lastPracticedAt: widget.editingSkill?.lastPracticedAt,
      createdAt: widget.editingSkill?.createdAt ?? DateTime.now(),
    );
    widget.onSave(skill);
  }
}
