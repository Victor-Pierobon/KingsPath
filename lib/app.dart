import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/models/attribute.dart';
import 'core/models/quest.dart';
import 'core/utils/xp_calculator.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_panel.dart';
import 'features/mobile/mobile_home.dart';
import 'features/quests/quest_board_panel.dart';
import 'features/skills/skills_panel.dart';

class KingsPathApp extends StatelessWidget {
  const KingsPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kings Path',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      ),
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, _) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) return const _AppInitializer();
        return const AuthScreen();
      },
    );
  }
}

class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer>
    with WidgetsBindingObserver {
  bool _loading = true;
  String? _error;
  DateTime? _lastDecayCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _silentRefresh();
  }

  Future<void> _silentRefresh() async {
    try {
      await ref.read(playerProvider.notifier).loadFromSupabase();
      await ref.read(questsProvider.notifier).loadFromSupabase();
      await ref.read(skillsProvider.notifier).loadFromSupabase();
      final penalties = await _runDecayCheck();
      if (penalties.isNotEmpty && mounted) {
        _showDecayWarning(penalties);
      }
    } catch (e) {
      debugPrint('[AppInit] refresh: $e');
    }
  }

  Future<void> _load() async {
    try {
      await ref.read(playerProvider.notifier).loadFromSupabase();
      await ref.read(questsProvider.notifier).loadFromSupabase();
      await ref.read(skillsProvider.notifier).loadFromSupabase();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      return;
    }
    final penalties = await _runDecayCheck();
    if (mounted) {
      setState(() => _loading = false);
      if (penalties.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showDecayWarning(penalties));
      }
    }
  }

  // Calcula e aplica o decay de XP por inatividade. Roda no máximo uma vez por dia.
  Future<List<String>> _runDecayCheck() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastDecayCheck == todayDate) return [];
    _lastDecayCheck = todayDate;

    final player = ref.read(playerProvider);
    final quests = ref.read(questsProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final globalLevel = player.globalLevel;

    final penalties = <String>[];

    for (final attr in player.attributes) {
      final lastQuest = quests
          .where((q) =>
              q.status == QuestStatus.completed &&
              q.xpPerAttribute.containsKey(attr.id) &&
              q.completedAt != null)
          .fold<Quest?>(
            null,
            (latest, q) => latest == null || q.completedAt!.isAfter(latest.completedAt!)
                ? q
                : latest,
          );

      if (lastQuest == null) continue;

      final lastDate = DateTime(
        lastQuest.completedAt!.year,
        lastQuest.completedAt!.month,
        lastQuest.completedAt!.day,
      );

      final graceDays = Attribute.decayGraceDays[attr.id] ?? 7;
      final graceEnd = lastDate.add(Duration(days: graceDays));

      if (!todayDate.isAfter(graceEnd)) {
        // Dentro do período de graça — limpa decay acumulado se houver
        if (attr.decayAppliedUntil != null) {
          await playerNotifier.updateAttribute(attr.copyWith(clearDecay: true));
        }
        continue;
      }

      // Fora do período de graça — calcula dias ainda não penalizados
      final effectiveFrom =
          (attr.decayAppliedUntil != null && attr.decayAppliedUntil!.isAfter(graceEnd))
              ? attr.decayAppliedUntil!
              : graceEnd;

      final daysToApply = todayDate.difference(effectiveFrom).inDays;
      if (daysToApply <= 0) continue;

      final xpToRemove = daysToApply * decayXpPerDay(globalLevel);
      final result = subtractXp(attr, xpToRemove);
      final newAttr = result.attribute.copyWith(decayAppliedUntil: todayDate);
      await playerNotifier.updateAttribute(newAttr);

      final change = result.leveledDown
          ? 'nível ${result.oldLevel} → ${result.attribute.level}'
          : '-$xpToRemove XP';
      penalties.add('${attr.icon} ${attr.name}: $change  (${daysToApply}d inativo)');
    }

    return penalties;
  }

  void _showDecayWarning(List<String> penalties) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.danger),
        ),
        title: const Text(
          '⚠ ATRIBUTOS ENFRAQUECENDO',
          style: TextStyle(
            color: AppColors.danger,
            fontSize: 14,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Você ficou inativo em alguns atributos:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...penalties.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(p,
                      style: const TextStyle(color: AppColors.text, fontSize: 13)),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Entendido',
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() {
                  _error = null;
                  _loading = true;
                }),
                child: const Text('Tentar novamente',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      );
    }
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
              SizedBox(height: 16),
              Text('Carregando dados...',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return _isMobile ? const MobileHome() : const DashboardPanel();
  }
}
