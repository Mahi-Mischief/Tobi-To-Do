import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';
import 'package:tobi_todo/features/analytics/screens/analytics_dashboard_page.dart';
import 'package:tobi_todo/features/auth/screens/login_screen.dart';
import 'package:tobi_todo/features/dashboard/screens/dashboard_screen.dart';
import 'package:tobi_todo/features/focus/screens/focus_screen_clean.dart' as focus_clean;
import 'package:tobi_todo/features/growth/screens/growth_screen.dart';
import 'package:tobi_todo/features/growth/screens/dream_me_screen.dart';
import 'package:tobi_todo/features/plan/screens/plan_screen.dart';
import 'package:tobi_todo/features/profile/screens/profile_screen.dart';
import 'package:tobi_todo/features/shared/widgets/tobi_ai_assistant.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
import 'package:tobi_todo/services/firebase_options.dart' as fb_options;

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _RootGate(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsDashboardPage(),
    ),
    GoRoute(
      path: '/dream-me',
      builder: (context, state) => const DreamMeScreen(),
    ),
  ],
  initialLocation: '/',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for all platforms (web + native).
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: fb_options.DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase init error (falling back to API auth): $e');
  }

  // Initialize Supabase (for avatar persistence and future backend calls)
  try {
    await Supabase.initialize(
      url: 'https://trcmyrwxihgkmxnvhfqv.supabase.co',
      anonKey: 'sb_publishable_DKzrua89HR7XU3tcrI-mjw_317t1lsA',
    );
    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('⚠️ Supabase init error: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Tobi To-Do',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

  class _RootGate extends ConsumerWidget {
    const _RootGate();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final authState = ref.watch(authProvider);
      return authState.when(
        data: (user) => user != null ? const MainNavigation() : const LoginScreen(),
        loading: () => Scaffold(
          body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade900, Colors.blue.shade600],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 24),
                Text(
                  'Loading Tobi To-Do...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stackTrace) {
          debugPrint('❌ Auth error: $error');
          return const LoginScreen();
        },
      );
    }
  }
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PlanScreen(),
    const focus_clean.FocusScreen(),
    const GrowthScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (TobiService.instance.shouldShowOnIndex(_selectedIndex)) const TobiAIAssistant(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Growth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
