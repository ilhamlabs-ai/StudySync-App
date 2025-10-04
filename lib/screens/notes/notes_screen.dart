import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notesProvider = context.watch<NotesProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {}); // Refresh the FutureBuilder
            },
          ),
        ],
      ),
      body: authProvider.user == null 
        ? const Center(
            child: Text(
              'Please sign in to view your notes',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
        : FutureBuilder<List<Map<String, dynamic>>>(
            future: notesProvider.fetchNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notes: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 64,
                        color: AppTheme.accent.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No notes yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to create your first note',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }
              final notes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.panelDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        note['content'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: note['timestamp'] != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _formatTimestamp(note['timestamp']),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey[400]),
                        onPressed: () async {
                          // TODO: Implement delete note functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delete functionality coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        onPressed: () async {
          String? noteContent;
          final content = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.panelDark,
              title: const Text('Add Note', style: TextStyle(color: Colors.white)),
              content: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your note here...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                onChanged: (value) => noteContent = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(noteContent);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (content != null && content.isNotEmpty) {
            await context.read<NotesProvider>().addNote(content);
            setState(() {}); // Refresh the notes list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'No date';
    
    try {
      DateTime date;
      if (timestamp is Map && timestamp.containsKey('seconds')) {
        // Firestore Timestamp
        date = DateTime.fromMillisecondsSinceEpoch(timestamp['seconds'] * 1000);
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Invalid date';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
