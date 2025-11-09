import 'package:flutter/material.dart';

/// Streak tracking widget
class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalDaysLogged;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDaysLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Fire emoji and current streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak Day Streak!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Keep it up!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.emoji_events,
                    'Longest',
                    '$longestStreak days',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.calendar_today,
                    'Total',
                    '$totalDaysLogged days',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage() {
    if (currentStreak == 0) {
      return 'Start your streak today! 💪';
    } else if (currentStreak < 3) {
      return 'Great start! Keep logging daily! 🌟';
    } else if (currentStreak < 7) {
      return 'You\'re on fire! Don\'t break the chain! 🔥';
    } else if (currentStreak < 30) {
      return 'Amazing consistency! You\'re unstoppable! ⚡';
    } else {
      return 'Legendary streak! You\'re a nutrition champion! 🏆';
    }
  }
}
