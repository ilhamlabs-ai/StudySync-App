import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<ChatMessage> _messages = [];
  int _unreadCount = 0;
  bool _chatOpen = false;
  
  List<ChatMessage> get messages => _messages;
  int get unreadCount => _unreadCount;
  bool get chatOpen => _chatOpen;

  void setChatOpen(bool open) {
    _chatOpen = open;
    if (open) {
      _unreadCount = 0;
    }
    notifyListeners();
  }

  // Setup chat listener for a session
  void setupChatListener(String sessionId) {
    _database
        .child('sessions')
        .child(sessionId)
        .child('messages')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _messages = data.entries.map((entry) {
          final messageData = Map<String, dynamic>.from(entry.value);
          return ChatMessage(
            id: entry.key,
            userId: messageData['userId'],
            userName: messageData['userName'],
            userPhotoURL: messageData['userPhotoURL'],
            message: messageData['message'],
            timestamp: DateTime.parse(messageData['timestamp']),
          );
        }).toList();
        
        // Sort by timestamp
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Increment unread count if chat is closed
        if (!_chatOpen && _messages.isNotEmpty) {
          _unreadCount++;
        }
      } else {
        _messages = [];
      }
      notifyListeners();
    });
  }

  // Send a message
  Future<void> sendMessage(String sessionId, String message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || message.trim().isEmpty) return;

      await _database.child('sessions').child(sessionId).child('messages').push().set({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhotoURL': user.photoURL,
        'message': message.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Clear messages when leaving session
  void clearMessages() {
    _messages = [];
    _unreadCount = 0;
    _chatOpen = false;
    notifyListeners();
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoURL;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoURL,
    required this.message,
    required this.timestamp,
  });
}
