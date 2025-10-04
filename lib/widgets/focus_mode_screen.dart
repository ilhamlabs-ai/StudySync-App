import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/session_provider.dart';

class FocusModeScreen extends StatefulWidget {
  final SessionProvider sessionProvider;
  final VoidCallback onExit;

  const FocusModeScreen({
    super.key,
    required this.sessionProvider,
    required this.onExit,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: widget.onExit,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer Display
                  Text(
                    widget.sessionProvider.formattedTime,
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Mode Indicator
                  Text(
                    _getTimerModeText(widget.sessionProvider.timerMode),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.sessionProvider.timerRunning 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.sessionProvider.timerRunning 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                    ),
                    child: Text(
                      widget.sessionProvider.timerRunning ? 'RUNNING' : 'PAUSED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.sessionProvider.timerRunning 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Exit Instructions
                  Text(
                    'Press ESC or tap to exit Focus Mode',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Participant Count
                  if (widget.sessionProvider.participantCount > 1)
                    Text(
                      '${widget.sessionProvider.participantCount} participants studying',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}