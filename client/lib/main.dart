import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';
import 'package:tobi_todo/features/auth/screens/login_screen.dart';
import 'package:tobi_todo/features/dashboard/screens/dashboard_screen.dart';
import 'package:tobi_todo/features/plan/screens/plan_screen.dart';
import 'package:tobi_todo/features/focus/screens/focus_screen_clean.dart' as focus_clean;
import 'package:tobi_todo/features/growth/screens/growth_screen.dart';
import 'package:tobi_todo/features/profile/screens/profile_screen.dart';
import 'package:tobi_todo/features/shared/widgets/tobi_ai_assistant.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/services/firebase_options.dart' as fb_options;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only initialize Firebase on native platforms (not web)
  if (!kIsWeb) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: fb_options.DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase initialized (native platform)');
      }
    } catch (e) {
      debugPrint('⚠️ Firebase init error (will use API auth): $e');
    }
  } else {
    debugPrint('✅ Web platform - using API authentication');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state from authProvider (StateNotifier) instead of Firebase stream
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Tobi To-Do',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) {
          return user != null ? const MainNavigation() : const LoginScreen();
        },
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
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                const Text(
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

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
          const TobiAIAssistant(),
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
