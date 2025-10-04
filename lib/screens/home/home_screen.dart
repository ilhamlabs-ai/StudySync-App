import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.accentGradient.createShader(bounds),
          child: const Text(
            'StudySync',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authProvider.photoURL != null)
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(authProvider.photoURL!),
                      ),
                    const SizedBox(width: 8),
                      Text(
                        authProvider.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.backgroundDark, AppTheme.panelDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: AppTheme.spacingXL),
                _buildQuickActions(),
                const SizedBox(height: AppTheme.spacingXL),
                _buildCurrentTimer(),
                const SizedBox(height: AppTheme.spacingXL),
                _buildFeatureCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final timeOfDay = DateTime.now().hour;
        String greeting;
        
        if (timeOfDay < 12) {
          greeting = 'Good morning';
        } else if (timeOfDay < 17) {
          greeting = 'Good afternoon';
        } else {
          greeting = 'Good evening';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  '$greeting, ${authProvider.displayName?.split(' ')[0] ?? ''}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'Ready to boost your productivity?',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to do today?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Start Studying',
                icon: Icon(Icons.play_arrow),
                onPressed: () => context.go('/timer'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: CustomButton(
                text: 'Join Session',
                icon: Icon(Icons.group),
                onPressed: () => context.go('/session'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentTimer() {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timerProvider, settingsProvider, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: timerProvider.isRunning 
                          ? AppTheme.accentGradient 
                          : null,
                      color: timerProvider.isRunning 
                          ? null 
                          : AppTheme.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      timerProvider.isRunning ? 'Running' : 'Paused',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: timerProvider.isRunning 
                            ? Colors.white 
                            : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timerProvider.formattedTime,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                            fontFamily: 'monospace',
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          timerProvider.modeDisplayName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (timerProvider.completedPomodoros > 0) ...[
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            'Completed: ${timerProvider.completedPomodoros} pomodoros',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Go to Timer',
                    icon: Icon(Icons.timer),
                    onPressed: () => context.go('/timer'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.note_outlined,
        'title': 'My Notes',
        'description': 'Access your personal study notes',
        'route': '/notes',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.group_outlined,
        'title': 'Study Sessions',
        'description': 'Join or create collaborative sessions',
        'route': '/session',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'description': 'Customize your timer preferences',
        'route': '/settings',
        'color': const Color(0xFFFF9800),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: _FeatureCard(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
            color: feature['color'] as Color,
            onTap: () => context.go(feature['route'] as String),
          ),
        )).toList(),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: AppTheme.panelDecoration.copyWith(
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}