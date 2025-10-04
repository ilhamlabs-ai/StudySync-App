import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/session_provider.dart';
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
                _buildSessionSection(),
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

  Widget _buildSessionSection() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        if (sessionProvider.isInSession) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.panelDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group_work,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Current Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sessionProvider.currentSessionCode ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${sessionProvider.participantCount} participants',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    if (sessionProvider.isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/session'),
                        child: const Text('View Session'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await sessionProvider.leaveSession();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Left session')),
                            );
                          }
                        },
                        child: const Text('Leave'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Session controls when not in a session
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Study Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Study with friends in real-time with synchronized timers',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateSessionDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Room'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showJoinSessionDialog(),
                      icon: const Icon(Icons.login),
                      label: const Text('Join Room'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateSessionDialog() async {
    final sessionProvider = context.read<SessionProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelDark,
        title: const Text('Creating Session...', style: TextStyle(color: AppTheme.textLight)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accent),
            SizedBox(height: 16),
            Text('Setting up your study room', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );

    print('Starting session creation...');
    try {
      final sessionCode = await sessionProvider.createSession();
      print('Session creation result: $sessionCode');

      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context, rootNavigator: true).pop();

          if (sessionCode != null) {
            print('Session created successfully, showing code dialog');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _showSessionCodeDialog(sessionCode);
              }
            });
          } else {
            print('Session creation failed - returned null');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to create session. Please check your internet connection and try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Exception during session creation: $e');
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  void _showSessionCodeDialog(String sessionCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelDark,
        title: const Text('Session Created!', style: TextStyle(color: AppTheme.textLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this code with your study partners:',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent),
              ),
              child: Text(
                sessionCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final sessionProvider = context.read<SessionProvider>();
              void waitForSession() {
                if (!context.mounted) return;
                if (sessionProvider.isInSession) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/session');
                    }
                  });
                } else {
                  Future.delayed(const Duration(milliseconds: 100), waitForSession);
                }
              }
              Future.delayed(const Duration(milliseconds: 100), waitForSession);
            },
            child: const Text('Enter Session'),
          ),
        ],
      ),
    );
  }

  void _showJoinSessionDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelDark,
        title: const Text('Join Session', style: TextStyle(color: AppTheme.textLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the 6-character session code:',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppTheme.textLight,
              ),
              decoration: InputDecoration(
                hintText: 'ABC123',
                hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.5)),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _joinSession(codeController.text.trim()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _joinSession(String code) async {
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session code must be 6 characters')),
      );
      return;
    }

    Navigator.of(context).pop(); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelDark,
        title: const Text('Joining Session...', style: TextStyle(color: AppTheme.textLight)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accent),
            SizedBox(height: 16),
            Text('Connecting to study room', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );

    try {
      final sessionProvider = context.read<SessionProvider>();
      print('Attempting to join session: $code');
      final success = await sessionProvider.joinSession(code);
      print('Join session result: $success');

      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading

          if (success) {
            print('Successfully joined, waiting for session to be ready');
            void waitForSession() {
              if (!context.mounted) return;
              final sessionProvider = context.read<SessionProvider>();
              if (sessionProvider.isInSession) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go('/session');
                  }
                });
              } else {
                Future.delayed(const Duration(milliseconds: 100), waitForSession);
              }
            }
            Future.delayed(const Duration(milliseconds: 100), waitForSession);
          } else {
            print('Failed to join session');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session not found or invalid code'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Exception joining session: $e');
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error joining session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
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