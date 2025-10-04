import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CircularTimer extends StatelessWidget {
  final int timeLeft;
  final double progress;
  final String formattedTime;

  const CircularTimer({
    super.key,
    required this.timeLeft,
    required this.progress,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: AppTheme.panelDark,
            valueColor: AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }
}
