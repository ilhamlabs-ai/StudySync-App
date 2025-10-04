import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatProvider extends ChangeNotifier {
  // Realtime chat messages for sessions
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref('chats');

  // Example: send message
  Future<void> sendMessage(String sessionId, String message, String userId) async {
    await _chatRef.child(sessionId).push().set({
      'userId': userId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  // Add more chat logic here
}
