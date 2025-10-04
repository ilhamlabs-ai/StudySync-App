import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimerSettings(context),
              const SizedBox(height: AppTheme.spacingL),
              _buildAutoStartSettings(context),
              const SizedBox(height: AppTheme.spacingL),
              _buildLongBreakSettings(context),
              const SizedBox(height: AppTheme.spacingL),
              _buildAccountSettings(context),
              const SizedBox(height: AppTheme.spacingXL),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: AppTheme.accentPurple,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Timer Durations (minutes)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInput(
                      'Pomodoro',
                      settings.pomodoroMinutes,
                      1,
                      60,
                      (value) => settings.updatePomodoroMinutes(value),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildTimeInput(
                      'Short Break',
                      settings.shortBreakMinutes,
                      1,
                      30,
                      (value) => settings.updateShortBreakMinutes(value),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildTimeInput(
                      'Long Break',
                      settings.longBreakMinutes,
                      1,
                      60,
                      (value) => settings.updateLongBreakMinutes(value),
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

  Widget _buildTimeInput(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextFormField(
            initialValue: value.toString(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (text) {
              final intValue = int.tryParse(text);
              if (intValue != null && intValue >= min && intValue <= max) {
                onChanged(intValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAutoStartSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.autorenew,
                    color: AppTheme.accentPurple,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Auto Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildToggleItem(
                'Auto Start Breaks',
                settings.autoStartBreaks,
                settings.toggleAutoStartBreaks,
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildToggleItem(
                'Auto Start Pomodoros',
                settings.autoStartPomodoros,
                settings.toggleAutoStartPomodoros,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleItem(String title, bool value, VoidCallback onToggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            width: 50,
            height: 26,
            decoration: BoxDecoration(
              gradient: value 
                  ? AppTheme.accentGradient
                  : null,
              color: value 
                  ? null 
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(26),
              border: value 
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
            ),
            child: AnimatedAlign(
              duration: AppTheme.mediumAnimation,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLongBreakSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.accentPurple,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Long Break Interval',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  const Text(
                    'Long break every',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: TextFormField(
                      initialValue: settings.longBreakInterval.toString(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLight,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (text) {
                        final intValue = int.tryParse(text);
                        if (intValue != null && intValue >= 2 && intValue <= 10) {
                          settings.updateLongBreakInterval(intValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  const Text(
                    'pomodoros',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
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

  Widget _buildAccountSettings(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: AppTheme.accentPurple,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  if (authProvider.photoURL != null)
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(authProvider.photoURL!),
                    )
                  else
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.accentPurple,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Text(
                              authProvider.displayName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight,
                          ),
                        ),
                        if (authProvider.email != null)
                          Text(
                            authProvider.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Reset to Defaults',
                onPressed: () => _showResetDialog(context),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    text: 'Sign Out',
                    onPressed: () => _showSignOutDialog(context, authProvider),
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        const Text(
          'Built with ❤️ for productive studying',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.panelDark,
          title: const Text(
            'Reset Settings',
            style: TextStyle(color: AppTheme.textLight),
          ),
          content: const Text(
            'Are you sure you want to reset all settings to their default values?',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                final settingsProvider = context.read<SettingsProvider>();
                final timerProvider = context.read<TimerProvider>();
                
                settingsProvider.resetToDefaults();
                timerProvider.updateFromSettings(settingsProvider);
                
                Navigator.of(dialogContext).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: AppTheme.accentPurple,
                  ),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppTheme.accentPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.panelDark,
          title: const Text(
            'Sign Out',
            style: TextStyle(color: AppTheme.textLight),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await authProvider.signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.accentPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}