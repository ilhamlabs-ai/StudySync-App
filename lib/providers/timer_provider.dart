import 'dart:async';
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

  void startTimer(SettingsProvider settingsProvider) {
    if (_remainingSeconds <= 0) {
      initializeTimer(settingsProvider);
    }
    _isRunning = true;
    _startCountdown();
    notifyListeners();
  }
  
  // Timer logic and state
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isRunning) {
        _remainingSeconds--;
        notifyListeners();
      } else if (_remainingSeconds <= 0) {
        _completeTimer();
      }
    });
  }

  void _completeTimer() {
    _isRunning = false;
    _timer?.cancel();
    _completedPomodoros++;
    
    // Auto-switch mode after completion
    if (_mode == TimerMode.focus) {
      _mode = _completedPomodoros % 4 == 0 ? TimerMode.longBreak : TimerMode.shortBreak;
    } else {
      _mode = TimerMode.focus;
    }
    
    notifyListeners();
  }

  void pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer(SettingsProvider settingsProvider) {
    _isRunning = false;
    _timer?.cancel();
    initializeTimer(settingsProvider);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Add more timer logic as needed
}
