import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_panel.dart';
import 'features/quests/quest_board_panel.dart';

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
    } catch (e) {
      debugPrint('[AppInit] refresh: $e');
    }
  }

  Future<void> _load() async {
    try {
      await ref.read(playerProvider.notifier).loadFromSupabase();
      await ref.read(questsProvider.notifier).loadFromSupabase();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

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
                onTap: () => setState(() { _error = null; _loading = true; }),
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
    return const DashboardPanel();
  }
}
