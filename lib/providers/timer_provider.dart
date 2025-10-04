import 'package:flutter/material.dart';
import 'timer_mode.dart';
import 'settings_provider.dart';

class TimerProvider extends ChangeNotifier {
  void updateFromSettings(SettingsProvider settingsProvider) {
    initializeTimer(settingsProvider);
    notifyListeners();
  }
  // Timer modes
  TimerMode _mode = TimerMode.focus;
  TimerMode get mode => _mode;
  String get modeDisplayName {
    switch (_mode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  int _completedPomodoros = 0;
  int get completedPomodoros => _completedPomodoros;

  String get formattedTime => '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
  int get timeLeft => _remainingSeconds;

  double getProgress(SettingsProvider settingsProvider) {
    int totalSeconds = 0;
    switch (_mode) {
      case TimerMode.focus:
        totalSeconds = settingsProvider.pomodoroMinutes * 60;
        break;
      case TimerMode.shortBreak:
        totalSeconds = settingsProvider.shortBreakMinutes * 60;
        break;
      case TimerMode.longBreak:
        totalSeconds = settingsProvider.longBreakMinutes * 60;
        break;
    }
    return totalSeconds == 0 ? 0 : _remainingSeconds / totalSeconds;
  }

  void switchMode(TimerMode mode, SettingsProvider settingsProvider) {
    _mode = mode;
    initializeTimer(settingsProvider);
    notifyListeners();
  }

  void initializeTimer(SettingsProvider settingsProvider) {
    switch (_mode) {
      case TimerMode.focus:
        _remainingSeconds = settingsProvider.pomodoroMinutes * 60;
        break;
      case TimerMode.shortBreak:
        _remainingSeconds = settingsProvider.shortBreakMinutes * 60;
        break;
      case TimerMode.longBreak:
        _remainingSeconds = settingsProvider.longBreakMinutes * 60;
        break;
    }
    notifyListeners();
  }

  void pauseTimer() {
    _isRunning = false;
    notifyListeners();
  }

  void startTimer(SettingsProvider settingsProvider) {
    initializeTimer(settingsProvider);
    _isRunning = true;
    notifyListeners();
  }
  // Timer logic and state
  int _remainingSeconds = 0;
  bool _isRunning = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  // Removed duplicate startTimer(int seconds)

  void stopTimer() {
    _isRunning = false;
    notifyListeners();
    // Add stop logic here
  }

  void resetTimer() {
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  // Add more timer logic as needed
}
