import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SessionProvider extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _currentSessionId;
  String? _currentSessionCode;
  bool _isHost = false;
  List<Participant> _participants = [];
  int _timerSeconds = 0;
  bool _timerRunning = false;
  String _timerMode = 'focus'; // focus, shortBreak, longBreak
  
  // Getters
  String? get currentSessionId => _currentSessionId;
  String? get currentSessionCode => _currentSessionCode;
  bool get isHost => _isHost;
  bool get isInSession => _currentSessionId != null;
  List<Participant> get participants => _participants;
  int get participantCount => _participants.length;
  int get timerSeconds => _timerSeconds;
  bool get timerRunning => _timerRunning;
  String get timerMode => _timerMode;
  
  String get formattedTime {
    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Generate random 6-character session code
  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // Create a new session
  Future<String?> createSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Error: User not authenticated');
        return null;
      }

      print('[SessionProvider] Creating session for user: ${user.uid}');
      final sessionCode = _generateSessionCode();
      final sessionRef = _database.child('sessions').child(sessionCode);

      final sessionData = {
        'host': user.uid,
        'created': ServerValue.timestamp,
        'timer': {
          'seconds': 1500,
          'running': false,
          'mode': 'focus',
        },
        'participants': {
          user.uid: {
            'name': user.displayName ?? 'Anonymous',
            'photoURL': user.photoURL,
            'joinedAt': ServerValue.timestamp,
          }
        }
      };

      print('[SessionProvider] Setting session data for code: $sessionCode');
      await sessionRef.set(sessionData);
      print('[SessionProvider] Session created successfully, verifying data...');
      final verifySnapshot = await sessionRef.get();
      print('[SessionProvider] Session data after creation: ${verifySnapshot.value}');

      _currentSessionId = sessionCode;
      _currentSessionCode = sessionCode;
      _isHost = true;
      _timerSeconds = 1500;
      _timerRunning = false;
      _timerMode = 'focus';
      _participants = [
        Participant(
          id: user.uid,
          name: user.displayName ?? 'Anonymous',
          photoURL: user.photoURL,
        )
      ];

      print('[SessionProvider] Setting up session listener for $sessionCode');
      _setupSessionListener(sessionCode);
      notifyListeners();

      return sessionCode;
    } catch (e) {
      print('[SessionProvider] Error creating session: $e');
      return null;
    }
  }

  // Join an existing session
  Future<bool> joinSession(String sessionCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('[SessionProvider] Error: User not authenticated');
        return false;
      }

      print('[SessionProvider] Joining session with code: $sessionCode');
      final sessionRef = _database.child('sessions').child(sessionCode.toUpperCase());
      final snapshot = await sessionRef.get();

      if (!snapshot.exists) {
        print('[SessionProvider] Error: Session does not exist');
        return false;
      }

      print('[SessionProvider] Session found, adding participant');
      await sessionRef.child('participants').child(user.uid).set({
        'name': user.displayName ?? 'Anonymous',
        'photoURL': user.photoURL,
        'joinedAt': ServerValue.timestamp,
      });

      _currentSessionId = sessionCode.toUpperCase();
      _currentSessionCode = sessionCode.toUpperCase();
      _isHost = false;

      final sessionData = Map<String, dynamic>.from(snapshot.value as Map);
      print('[SessionProvider] Session data after join: $sessionData');
      final timerData = sessionData['timer'] as Map<String, dynamic>?;
      _timerSeconds = timerData?['seconds'] ?? 1500;
      _timerRunning = timerData?['running'] ?? false;
      _timerMode = timerData?['mode'] ?? 'focus';

      print('[SessionProvider] Setting up session listener for $sessionCode');
      _setupSessionListener(sessionCode.toUpperCase());
      notifyListeners();

      print('[SessionProvider] Successfully joined session');
      return true;
    } catch (e) {
      print('[SessionProvider] Error joining session: $e');
      return false;
    }
  }

  // Leave current session
  Future<void> leaveSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _currentSessionId == null) return;

      // Remove participant from session
      await _database
          .child('sessions')
          .child(_currentSessionId!)
          .child('participants')
          .child(user.uid)
          .remove();

      // If host is leaving and there are other participants, transfer host
      if (_isHost && _participants.length > 1) {
        final newHost = _participants.firstWhere((p) => p.id != user.uid);
        await _database
            .child('sessions')
            .child(_currentSessionId!)
            .update({
          'hostId': newHost.id,
          'hostName': newHost.name,
        });
      }

      // If no participants left, delete session
      if (_participants.length <= 1) {
        await _database.child('sessions').child(_currentSessionId!).remove();
      }

      _cleanupSession();
    } catch (e) {
      print('Error leaving session: $e');
    }
  }

  // Setup real-time listener for session updates
  void _setupSessionListener(String sessionCode) {
    print('[SessionProvider] Setting up session listener for $sessionCode');
    _database.child('sessions').child(sessionCode).onValue.listen((event) {
      print('[SessionProvider] Session listener triggered for $sessionCode');
      if (!event.snapshot.exists) {
        print('[SessionProvider] Session listener: session does not exist, cleaning up');
        _cleanupSession();
        return;
      }

  final rawMap = event.snapshot.value as Map<Object?, Object?>;
  final data = Map<String, dynamic>.from(rawMap.map((key, value) => MapEntry(key.toString(), value)));
      print('[SessionProvider] Session listener data: $data');

      // Update participants
      if (data['participants'] != null) {
        final participantsRaw = data['participants'] as Map<Object?, Object?>;
        final participantsData = Map<String, dynamic>.from(
          participantsRaw.map((key, value) => MapEntry(key.toString(), value))
        );
        _participants = participantsData.entries.map((entry) {
          final participantRaw = entry.value as Map<Object?, Object?>;
          final participantData = Map<String, dynamic>.from(
            participantRaw.map((key, value) => MapEntry(key.toString(), value))
          );
          return Participant(
            id: entry.key,
            name: participantData['name'] ?? 'Anonymous',
            photoURL: participantData['photoURL'],
          );
        }).toList();
      }

      // Check for timer completion (when timer reaches 0)
      final previousSeconds = _timerSeconds;

      // Update timer state
      final timerData = data['timer'] != null
        ? Map<String, dynamic>.from(
            (data['timer'] as Map<Object?, Object?>).map((key, value) => MapEntry(key.toString(), value))
          )
        : null;
      _timerSeconds = timerData?['seconds'] ?? 1500;
      _timerRunning = timerData?['running'] ?? false;
      _timerMode = timerData?['mode'] ?? 'focus';

      // Play notification sound if timer just completed
      if (previousSeconds > 0 && _timerSeconds == 0) {
        _playTimerCompleteSound();
      }

      // Check if current user is host
      final user = FirebaseAuth.instance.currentUser;
      _isHost = user != null && data['host'] == user.uid;

      print('[SessionProvider] Listener state: isHost=$_isHost, timerSeconds=$_timerSeconds, timerRunning=$_timerRunning, timerMode=$_timerMode, participants=${_participants.length}');
      notifyListeners();
    });
  }

  // Play notification sound when timer completes
  void _playTimerCompleteSound() async {
    try {
      // Play haptic feedback
      HapticFeedback.heavyImpact();
      
      // Play notification sound
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/notification.mp3'));
      
      print('Timer completed! Played notification sound and haptic feedback.');
    } catch (e) {
      print('Error playing notification sound: $e');
      // Fallback to system sound
      SystemSound.play(SystemSoundType.alert);
    }
  }

  // Timer control methods (host only)
  Future<void> startTimer() async {
    if (!_isHost || _currentSessionId == null) return;
    
    await _database.child('sessions').child(_currentSessionId!).child('timer').update({
      'running': true,
      'startedAt': ServerValue.timestamp,
    });
  }

  Future<void> pauseTimer() async {
    if (!_isHost || _currentSessionId == null) return;
    
    await _database.child('sessions').child(_currentSessionId!).child('timer').update({
      'running': false,
    });
  }

  Future<void> resetTimer() async {
    if (!_isHost || _currentSessionId == null) return;
    
    int defaultSeconds = 1500; // 25 minutes
    if (_timerMode == 'shortBreak') defaultSeconds = 300; // 5 minutes
    if (_timerMode == 'longBreak') defaultSeconds = 900; // 15 minutes
    
    await _database.child('sessions').child(_currentSessionId!).child('timer').update({
      'seconds': defaultSeconds,
      'running': false,
    });
  }

  Future<void> switchTimerMode(String mode) async {
    if (!_isHost || _currentSessionId == null) return;
    
    int seconds = 1500; // focus: 25 minutes
    if (mode == 'shortBreak') seconds = 300; // 5 minutes  
    if (mode == 'longBreak') seconds = 900; // 15 minutes
    
    await _database.child('sessions').child(_currentSessionId!).child('timer').update({
      'mode': mode,
      'seconds': seconds,
      'running': false,
    });
  }

  void _cleanupSession() {
    _currentSessionId = null;
    _currentSessionCode = null;
    _isHost = false;
    _participants = [];
    _timerSeconds = 0;
    _timerRunning = false;
    _timerMode = 'focus';
    notifyListeners();
  }

  @override
  void dispose() {
    leaveSession();
    super.dispose();
  }
}

class Participant {
  final String id;
  final String name;
  final String? photoURL;

  Participant({
    required this.id,
    required this.name,
    this.photoURL,
  });
}
