import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/skill.dart';
import '../../data/supabase_service.dart';
import '../../widgets/floating_window.dart';
import '../dashboard/dashboard_panel.dart';
import 'skill_web_widget.dart';
import 'create_skill_panel.dart';

final skillsProvider =
    StateNotifierProvider<SkillsNotifier, List<Skill>>((ref) => SkillsNotifier());

class SkillsNotifier extends StateNotifier<List<Skill>> {
  SkillsNotifier() : super([]);

  Future<void> loadFromSupabase() async {
    state = await SupabaseService.instance.fetchSkills();
  }

  Future<void> addSkill(Skill skill) async {
    state = [...state, skill];
    await SupabaseService.instance.upsertSkill(skill);
  }

  Future<void> updateSkill(Skill skill) async {
    state = state.map((s) => s.id == skill.id ? skill : s).toList();
    await SupabaseService.instance.upsertSkill(skill);
  }

  Future<void> deleteSkill(String id) async {
    state = state.where((s) => s.id != id).toList();
    await SupabaseService.instance.deleteSkill(id);
    // Remove referências em outras habilidades
    final updated = state
        .where((s) => s.relatedSkillIds.contains(id))
        .map((s) => s.copyWith(
              relatedSkillIds: s.relatedSkillIds.where((r) => r != id).toList(),
            ))
        .toList();
    for (final s in updated) {
      await updateSkill(s);
    }
  }

  Future<void> markPracticed(List<String> skillIds) async {
    if (skillIds.isEmpty) return;
    final now = DateTime.now();
    state = state
        .map((s) => skillIds.contains(s.id) ? s.copyWith(lastPracticedAt: now) : s)
        .toList();
    await SupabaseService.instance.markSkillsPracticed(skillIds);
  }

  String newId() => const Uuid().v4();
}

class SkillsPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final bool mobileMode;

  const SkillsPanel({super.key, required this.onClose, this.mobileMode = false});

  @override
  ConsumerState<SkillsPanel> createState() => _SkillsPanelState();
}

class _SkillsPanelState extends ConsumerState<SkillsPanel> {
  String? _selectedSkillId;
  bool _showCreate = false;
  Skill? _editingSkill;

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(skillsProvider);
    final player = ref.watch(playerProvider);

    if (_showCreate) {
      return FloatingWindow(
        width: widget.mobileMode ? null : 380,
        child: CreateSkillPanel(
          allSkills: skills,
          editingSkill: _editingSkill,
          onSave: (skill) async {
            if (_editingSkill != null) {
              await ref.read(skillsProvider.notifier).updateSkill(skill);
            } else {
              await ref.read(skillsProvider.notifier).addSkill(skill);
            }
            setState(() {
              _showCreate = false;
              _editingSkill = null;
            });
          },
          onClose: () => setState(() {
            _showCreate = false;
            _editingSkill = null;
          }),
        ),
      );
    }

    final selected = _selectedSkillId != null
        ? skills.firstWhere((s) => s.id == _selectedSkillId,
            orElse: () => skills.first)
        : null;

    return FloatingWindow(
      width: widget.mobileMode ? null : 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          SizedBox(
            height: widget.mobileMode ? 300 : 340,
            child: SkillWebWidget(
              attributes: player.attributes,
              skills: skills,
              selectedSkillId: _selectedSkillId,
              onSkillTap: (id) => setState(() =>
                  _selectedSkillId = _selectedSkillId == id ? null : id),
            ),
          ),
          if (selected != null) _selectedCard(selected, skills),
          _addButton(),
          const SizedBox(height: 8),
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
              'TEIA DE HABILIDADES',
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
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _selectedCard(Skill skill, List<Skill> allSkills) {
    final attrIcons = {
      'fisico': '💪', 'inteligencia': '📘', 'sabedoria': '🌿',
      'espiritualidade': '✨', 'carisma': '👁', 'relacionamento': '🤝',
    };
    final attrNames = {
      'fisico': 'Físico', 'inteligencia': 'Inteligência', 'sabedoria': 'Sabedoria',
      'espiritualidade': 'Espiritualidade', 'carisma': 'Carisma',
      'relacionamento': 'Relacionamento',
    };
    final related = allSkills.where((s) => skill.relatedSkillIds.contains(s.id)).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(skill.name,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              _iconButton(Icons.edit_outlined, () => setState(() {
                _editingSkill = skill;
                _showCreate = true;
              })),
              _iconButton(Icons.delete_outline, () async {
                await ref.read(skillsProvider.notifier).deleteSkill(skill.id);
                setState(() => _selectedSkillId = null);
              }),
            ],
          ),
          const SizedBox(height: 6),
          Text(skill.brightnessLabel,
              style: TextStyle(
                  color: _brightnessColor(skill.brightness), fontSize: 11)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...skill.attributeIds.map((id) => _tag(
                  '${attrIcons[id] ?? ''} ${attrNames[id] ?? id}',
                  AppColors.accent)),
              if (related.isNotEmpty)
                ...related.map((s) =>
                    _tag('↔ ${s.name}', AppColors.gold.withValues(alpha: 0.8))),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ref
                .read(skillsProvider.notifier)
                .markPracticed([skill.id]),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text('✦  Praticar hoje',
                  style: TextStyle(color: AppColors.accent, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GestureDetector(
        onTap: () => setState(() => _showCreate = true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.accent),
            borderRadius: BorderRadius.circular(6),
            boxShadow: AppColors.borderGlow,
          ),
          alignment: Alignment.center,
          child: const Text(
            '+ NOVA HABILIDADE',
            style: TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 10)),
      );

  Widget _iconButton(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, color: AppColors.textMuted, size: 16),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      );

  Color _brightnessColor(double b) {
    if (b >= 0.9) return AppColors.success;
    if (b >= 0.6) return AppColors.accent;
    if (b >= 0.4) return AppColors.gold;
    return AppColors.textMuted;
  }
}
