import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? _currentSessionId;
  int _participantCount = 1;
  String? get currentSessionId => _currentSessionId;
  int get participantCount => _participantCount;

  Future<void> joinSession(String sessionId) async {
    _currentSessionId = sessionId;
    notifyListeners();
    // Add more logic for joining session in realtime DB
  }

  Future<void> leaveSession() async {
    _currentSessionId = null;
    notifyListeners();
    // Add more logic for leaving session
  }

  // Add more collaborative session logic here
}

class Session {
  final String id;
  Session(this.id);
}
