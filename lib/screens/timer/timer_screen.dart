import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_mode.dart';
import '../../providers/settings_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/circular_timer.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize timer with current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = context.read<TimerProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      timerProvider.initializeTimer(settingsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudySync',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
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
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                _buildSessionInfo(),
                const SizedBox(height: AppTheme.spacingL),
                _buildModeSelector(),
                const SizedBox(height: AppTheme.spacingXL),
                Expanded(
                  child: _buildTimerSection(),
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildControlButtons(),
                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
  if (sessionProvider.currentSessionId == null) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: AppTheme.panelDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solo Study Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Study independently with your personal timer',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Join Session',
                  onPressed: () => context.push('/session'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0x1A7C5CFF), Color(0x0A00D4FF)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session: ${sessionProvider.currentSessionId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentPurple,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sessionProvider.participantCount} participant${sessionProvider.participantCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Leave',
                onPressed: () => sessionProvider.leaveSession(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF9AA4B2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildModeTab(
                  'Pomodoro',
                  TimerMode.focus,
                  timerProvider.mode == TimerMode.focus,
                  timerProvider,
                ),
              ),
              Expanded(
                child: _buildModeTab(
                  'Short Break',
                  TimerMode.shortBreak,
                  timerProvider.mode == TimerMode.shortBreak,
                  timerProvider,
                ),
              ),
              Expanded(
                child: _buildModeTab(
                  'Long Break',
                  TimerMode.longBreak,
                  timerProvider.mode == TimerMode.longBreak,
                  timerProvider,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeTab(String text, TimerMode mode, bool isSelected, TimerProvider timerProvider) {
    return GestureDetector(
      onTap: () {
        if (!timerProvider.isRunning) {
          final settingsProvider = context.read<SettingsProvider>();
          timerProvider.switchMode(mode, settingsProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.accentPurple : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timerProvider, settingsProvider, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Timer
            CircularTimer(
              timeLeft: timerProvider.timeLeft,
              progress: timerProvider.getProgress(settingsProvider),
              formattedTime: timerProvider.formattedTime,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            
            // Timer Display
            Text(
              timerProvider.formattedTime,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
                fontFamily: 'monospace',
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Mode Display
            Text(
              timerProvider.modeDisplayName,
              style: const TextStyle(
                fontSize: 20,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            
            // Completed Pomodoros
            if (timerProvider.completedPomodoros > 0)
              Text(
                'Completed: ${timerProvider.completedPomodoros} pomodoros',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timerProvider, settingsProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Start/Pause Button
            CustomButton(
              text: timerProvider.isRunning ? 'Pause' : 'Start',
              icon: timerProvider.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              onPressed: () {
                if (timerProvider.isRunning) {
                  timerProvider.pauseTimer();
                } else {
                  timerProvider.startTimer(settingsProvider);
                }
              },
            ),
            
            // Reset Button
            CustomButton(
              text: 'Reset',
              icon: Icon(Icons.refresh),
              onPressed: () => timerProvider.resetTimer(),
            ),
            
            // Focus Mode Button
            CustomButton(
              text: 'Focus',
              icon: Icon(Icons.fullscreen),
              onPressed: () => _enterFocusMode(),
            ),
          ],
        );
      },
    );
  }

  void _enterFocusMode() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FocusModeDialog(),
    );
  }
}

// Focus Mode Dialog
class FocusModeDialog extends StatelessWidget {
  const FocusModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppTheme.backgroundDark,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Close Button
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.textLight,
                    size: 32,
                  ),
                ),
              ),
              
              // Timer Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Consumer2<TimerProvider, SettingsProvider>(
                    builder: (context, timerProvider, settingsProvider, _) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large Circular Timer
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: CircularTimer(
                                timeLeft: timerProvider.timeLeft,
                                progress: timerProvider.getProgress(settingsProvider),
                                formattedTime: timerProvider.formattedTime,
                              ),
                          ),
                          const SizedBox(height: AppTheme.spacingXXL),
                          
                          // Large Timer Display
                          Text(
                            timerProvider.formattedTime,
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                              fontFamily: 'monospace',
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          
                          // Mode Display
                          Text(
                            timerProvider.modeDisplayName,
                            style: const TextStyle(
                              fontSize: 28,
                              color: AppTheme.accentPurple,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXXL),
                          
                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                text: timerProvider.isRunning ? 'Pause' : 'Start',
                                icon: timerProvider.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                                onPressed: () {
                                  if (timerProvider.isRunning) {
                                    timerProvider.pauseTimer();
                                  } else {
                                    timerProvider.startTimer(settingsProvider);
                                  }
                                },
                              ),
                              const SizedBox(width: AppTheme.spacingL),
                              CustomButton(
                                text: 'Reset',
                                icon: Icon(Icons.refresh),
                                onPressed: () => timerProvider.resetTimer(),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingXL),
                          
                          // Exit Instructions
                          const Text(
                            'Press ESC or tap × to exit focus mode',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}