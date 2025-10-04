import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesProvider extends ChangeNotifier {
  // Firestore notes collection for current user
  
  // Get current user ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  
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
      print('Fetching notes for user: $_userId');
      // Get all notes, order by updatedAt if present, else createdAt, else timestamp
      final snapshot = await _notesRef!.get();
      List<Map<String, dynamic>> notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort notes by most recent timestamp
      notes.sort((a, b) {
        int getMillis(Map<String, dynamic> note) {
          if (note['updatedAt'] != null) {
            // Firestore Timestamp object
            final ts = note['updatedAt'];
            if (ts is DateTime) return ts.millisecondsSinceEpoch;
            if (ts is Map && ts.containsKey('seconds')) return ts['seconds'] * 1000;
            if (ts is String) return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
          }
          if (note['createdAt'] != null) {
            final ts = note['createdAt'];
            if (ts is DateTime) return ts.millisecondsSinceEpoch;
            if (ts is Map && ts.containsKey('seconds')) return ts['seconds'] * 1000;
            if (ts is String) return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
          }
          if (note['timestamp'] != null) {
            final ts = note['timestamp'];
            if (ts is DateTime) return ts.millisecondsSinceEpoch;
            if (ts is Map && ts.containsKey('seconds')) return ts['seconds'] * 1000;
            if (ts is String) return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
          }
          return 0;
        }
        return getMillis(b).compareTo(getMillis(a));
      });

      print('Fetched ${notes.length} notes');
      return notes;
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  // Add user-specific note
  Future<void> addNote(String content, {String? title}) async {
    if (_notesRef == null) {
      print('User not authenticated, cannot add note');
      return;
    }
    try {
      await _notesRef!.add({
        'content': content,
        if (title != null && title.isNotEmpty) 'title': title,
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
