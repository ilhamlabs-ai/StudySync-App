import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Default settings
  int _pomodoroMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  int _longBreakInterval = 4;
  
  // Getters
  int get pomodoroMinutes => _pomodoroMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  int get longBreakInterval => _longBreakInterval;
  
  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _pomodoroMinutes = prefs.getInt('pomodoro_minutes') ?? 25;
      _shortBreakMinutes = prefs.getInt('short_break_minutes') ?? 5;
      _longBreakMinutes = prefs.getInt('long_break_minutes') ?? 15;
      _autoStartBreaks = prefs.getBool('auto_start_breaks') ?? false;
      _autoStartPomodoros = prefs.getBool('auto_start_pomodoros') ?? false;
      _longBreakInterval = prefs.getInt('long_break_interval') ?? 4;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }
  
  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('pomodoro_minutes', _pomodoroMinutes);
      await prefs.setInt('short_break_minutes', _shortBreakMinutes);
      await prefs.setInt('long_break_minutes', _longBreakMinutes);
      await prefs.setBool('auto_start_breaks', _autoStartBreaks);
      await prefs.setBool('auto_start_pomodoros', _autoStartPomodoros);
      await prefs.setInt('long_break_interval', _longBreakInterval);
      
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
  
  // Update pomodoro duration
  Future<void> updatePomodoroMinutes(int minutes) async {
    if (minutes >= 1 && minutes <= 60) {
      _pomodoroMinutes = minutes;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Update short break duration
  Future<void> updateShortBreakMinutes(int minutes) async {
    if (minutes >= 1 && minutes <= 30) {
      _shortBreakMinutes = minutes;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Update long break duration
  Future<void> updateLongBreakMinutes(int minutes) async {
    if (minutes >= 1 && minutes <= 60) {
      _longBreakMinutes = minutes;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Toggle auto start breaks
  Future<void> toggleAutoStartBreaks() async {
    _autoStartBreaks = !_autoStartBreaks;
    await _saveSettings();
    notifyListeners();
  }
  
  // Toggle auto start pomodoros
  Future<void> toggleAutoStartPomodoros() async {
    _autoStartPomodoros = !_autoStartPomodoros;
    await _saveSettings();
    notifyListeners();
  }
  
  // Update long break interval
  Future<void> updateLongBreakInterval(int interval) async {
    if (interval >= 2 && interval <= 10) {
      _longBreakInterval = interval;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _pomodoroMinutes = 25;
    _shortBreakMinutes = 5;
    _longBreakMinutes = 15;
    _autoStartBreaks = false;
    _autoStartPomodoros = false;
    _longBreakInterval = 4;
    
    await _saveSettings();
    notifyListeners();
  }
  
  // Apply settings from a map (useful for bulk updates)
  Future<void> applySettings({
    int? pomodoroMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    int? longBreakInterval,
  }) async {
    bool hasChanges = false;
    
    if (pomodoroMinutes != null && pomodoroMinutes >= 1 && pomodoroMinutes <= 60) {
      _pomodoroMinutes = pomodoroMinutes;
      hasChanges = true;
    }
    
    if (shortBreakMinutes != null && shortBreakMinutes >= 1 && shortBreakMinutes <= 30) {
      _shortBreakMinutes = shortBreakMinutes;
      hasChanges = true;
    }
    
    if (longBreakMinutes != null && longBreakMinutes >= 1 && longBreakMinutes <= 60) {
      _longBreakMinutes = longBreakMinutes;
      hasChanges = true;
    }
    
    if (autoStartBreaks != null) {
      _autoStartBreaks = autoStartBreaks;
      hasChanges = true;
    }
    
    if (autoStartPomodoros != null) {
      _autoStartPomodoros = autoStartPomodoros;
      hasChanges = true;
    }
    
    if (longBreakInterval != null && longBreakInterval >= 2 && longBreakInterval <= 10) {
      _longBreakInterval = longBreakInterval;
      hasChanges = true;
    }
    
    if (hasChanges) {
      await _saveSettings();
      notifyListeners();
    }
  }
}