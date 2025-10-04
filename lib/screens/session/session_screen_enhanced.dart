import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/theme.dart';

class EnhancedSessionScreen extends StatefulWidget {
  const EnhancedSessionScreen({super.key});

  @override
  State<EnhancedSessionScreen> createState() => _EnhancedSessionScreenState();
}

class _EnhancedSessionScreenState extends State<EnhancedSessionScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    print('EnhancedSessionScreen initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = context.read<SessionProvider>();
      print('Session screen - isInSession: ${sessionProvider.isInSession}');
      print(
          'Session screen - currentSessionId: ${sessionProvider.currentSessionId}');

      if (sessionProvider.isInSession) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.setupChatListener(sessionProvider.currentSessionId!);
      } else {
        print('WARNING: Session screen accessed but no active session');
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        if (!sessionProvider.isInSession) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            appBar: AppBar(
              title: const Text('Study Session'),
              backgroundColor: AppTheme.backgroundDark,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Session',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create or join a study session to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_isFocusMode) {
          return _buildFocusMode(sessionProvider);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            title: const Text('Study Session'),
            actions: [
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () => setState(() => _isFocusMode = true),
                tooltip: 'Focus Mode',
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: _showLeaveSessionDialog,
                tooltip: 'Leave Session',
              ),
            ],
          ),
          body: Column(
            children: [
              // Session Info Header
              _buildSessionHeader(sessionProvider),

              // Timer Section
              Expanded(
                flex: 2,
                child: _buildTimerSection(sessionProvider),
              ),

              // Participants Section
              _buildParticipantsSection(sessionProvider),

              // Controls Section
              if (sessionProvider.isHost) _buildHostControls(sessionProvider),
            ],
          ),
          floatingActionButton: _buildChatFab(),
        );
      },
    );
  }

  Widget _buildFocusMode(SessionProvider sessionProvider) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _isFocusMode = false),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessionProvider.formattedTime,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  sessionProvider.timerMode.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Press ESC or tap to exit Focus Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(SessionProvider sessionProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.panelDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.group_work,
                color: AppTheme.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    _copySessionCode(sessionProvider.currentSessionCode!),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sessionProvider.currentSessionCode!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${sessionProvider.participantCount} participants',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              if (sessionProvider.isHost)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HOST',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(SessionProvider sessionProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Mode Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _getTimerModeColor(sessionProvider.timerMode)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getTimerModeText(sessionProvider.timerMode),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTimerModeColor(sessionProvider.timerMode),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Circular Timer
            Container(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2),
                        width: 8,
                      ),
                    ),
                  ),

                  // Progress Circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _getTimerProgress(sessionProvider),
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTimerModeColor(sessionProvider.timerMode),
                      ),
                    ),
                  ),

                  // Timer Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sessionProvider.formattedTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.textLight,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sessionProvider.timerRunning ? 'Running' : 'Paused',
                        style: TextStyle(
                          fontSize: 16,
                          color: sessionProvider.timerRunning
                              ? AppTheme.accent
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(SessionProvider sessionProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Participants',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sessionProvider.participants.length,
              itemBuilder: (context, index) {
                final participant = sessionProvider.participants[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: participant.photoURL != null
                            ? NetworkImage(participant.photoURL!)
                            : null,
                        backgroundColor: AppTheme.accent,
                        child: participant.photoURL == null
                            ? Text(
                                participant.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.name.split(' ')[0],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostControls(SessionProvider sessionProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),

          // Timer Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: sessionProvider.timerRunning
                      ? () => sessionProvider.pauseTimer()
                      : () => sessionProvider.startTimer(),
                  icon: Icon(
                    sessionProvider.timerRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(sessionProvider.timerRunning ? 'Pause' : 'Start'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => sessionProvider.resetTimer(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mode Selector
          Row(
            children: [
              _buildModeButton('Focus', 'focus', sessionProvider),
              const SizedBox(width: 8),
              _buildModeButton('Short Break', 'shortBreak', sessionProvider),
              const SizedBox(width: 8),
              _buildModeButton('Long Break', 'longBreak', sessionProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
      String label, String mode, SessionProvider sessionProvider) {
    final isActive = sessionProvider.timerMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => sessionProvider.switchTimerMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildChatFab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Stack(
          children: [
            FloatingActionButton(
              onPressed: () => _showChatDialog(),
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
            if (chatProvider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${chatProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showChatDialog() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setChatOpen(true);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.panelDark,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Chat Header
              Row(
                children: [
                  const Icon(Icons.chat, color: AppTheme.accent),
                  const SizedBox(width: 12),
                  const Text(
                    'Session Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      chatProvider.setChatOpen(false);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  ),
                ],
              ),

              const Divider(color: AppTheme.textMuted),

              // Messages List
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (chatProvider.messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet.\nStart the conversation!',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),

              const Divider(color: AppTheme.textMuted),

              // Message Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppTheme.textLight),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            color: AppTheme.textMuted.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.accent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.accent.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.accent),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => chatProvider.setChatOpen(false));
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.userId ==
        context
            .read<SessionProvider>()
            .participants
            .firstWhere((p) => p.name == message.userName,
                orElse: () => Participant(id: '', name: ''))
            .id;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.accent : AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.accent,
                    ),
                  ),
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final sessionProvider = context.read<SessionProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (sessionProvider.isInSession) {
      chatProvider.sendMessage(sessionProvider.currentSessionId!, message);
      _messageController.clear();
    }
  }

  void _copySessionCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session code copied to clipboard')),
    );
  }

  void _showLeaveSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelDark,
        title: const Text('Leave Session',
            style: TextStyle(color: AppTheme.textLight)),
        content: const Text(
          'Are you sure you want to leave this study session?',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _leaveSession();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _leaveSession() async {
    final sessionProvider = context.read<SessionProvider>();
    final chatProvider = context.read<ChatProvider>();

    await sessionProvider.leaveSession();
    chatProvider.clearMessages();

    if (context.mounted) {
      context.go('/');
    }
  }

  Color _getTimerModeColor(String mode) {
    switch (mode) {
      case 'focus':
        return AppTheme.accent;
      case 'shortBreak':
        return Colors.green;
      case 'longBreak':
        return Colors.blue;
      default:
        return AppTheme.accent;
    }
  }

  String _getTimerModeText(String mode) {
    switch (mode) {
      case 'focus':
        return 'FOCUS TIME';
      case 'shortBreak':
        return 'SHORT BREAK';
      case 'longBreak':
        return 'LONG BREAK';
      default:
        return 'FOCUS TIME';
    }
  }

  double _getTimerProgress(SessionProvider sessionProvider) {
    int totalSeconds = 1500; // Default 25 minutes
    if (sessionProvider.timerMode == 'shortBreak')
      totalSeconds = 300; // 5 minutes
    if (sessionProvider.timerMode == 'longBreak')
      totalSeconds = 900; // 15 minutes

    return totalSeconds == 0
        ? 0
        : (totalSeconds - sessionProvider.timerSeconds) / totalSeconds;
  }
}
