import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesProvider extends ChangeNotifier {
  // Get current user ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  
  // Firestore notes collection for current user
  CollectionReference? get _notesRef => _userId != null 
      ? FirebaseFirestore.instance.collection('users').doc(_userId).collection('notes')
      : null;

  // Fetch user-specific notes
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    if (_notesRef == null) {
      print('User not authenticated, cannot fetch notes');
      return [];
    }
    
    try {
      final snapshot = await _notesRef!.orderBy('timestamp', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID for future operations
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  // Add user-specific note
  Future<void> addNote(String content) async {
    if (_notesRef == null) {
      print('User not authenticated, cannot add note');
      return;
    }
    
    try {
      await _notesRef!.add({
        'content': content, 
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _userId,
      });
      notifyListeners();
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  // Add more notes logic here
}
