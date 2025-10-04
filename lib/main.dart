import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ...existing code...
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/timer/timer_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/session/session_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/session_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if Firebase is already initialized to avoid duplicate initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase is already initialized, continue with the app
      print('Firebase already initialized, continuing...');
    } else {
      // Re-throw other errors
      rethrow;
    }
  }
  
  runApp(const MainApp());
}

// GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final isOnLoginPage = state.uri.path == '/login';

    // If not authenticated and not on login page, redirect to login
    if (!isAuthenticated && !isOnLoginPage) {
      return '/login';
    }

    // If authenticated and on login page, redirect to home
    if (isAuthenticated && isOnLoginPage) {
      return '/';
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NotesScreen(),
        ),
        GoRoute(
          path: '/session',
          builder: (context, state) => const SessionScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.materialTheme,
        routerConfig: _router,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/timer');
        break;
      case 2:
        context.go('/notes');
        break;
      case 3:
        context.go('/session');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index based on current route
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        _selectedIndex = 0;
        break;
      case '/timer':
        _selectedIndex = 1;
        break;
      case '/notes':
        _selectedIndex = 2;
        break;
      case '/session':
        _selectedIndex = 3;
        break;
      case '/settings':
        _selectedIndex = 4;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudySync'),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundImage: authProvider.photoURL != null
                      ? NetworkImage(authProvider.photoURL!)
                      : null,
                  backgroundColor: AppTheme.accent,
                  child: authProvider.photoURL == null
                      ? Text(
                          authProvider.displayName?.isNotEmpty == true
                              ? authProvider.displayName![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authProvider.displayName ?? 'User',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (authProvider.email != null)
                              Text(
                                authProvider.email!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.textMuted,
        backgroundColor: AppTheme.backgroundDark,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Session'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
