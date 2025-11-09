import 'package:flutter/material.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/data_sources/openrouter_data_source.dart';

/// Widget showing AI coaching suggestions
class AICoachingCard extends StatefulWidget {
  final Map<String, dynamic> dailyIntake;
  final Map<String, dynamic> goals;
  final String userId;

  const AICoachingCard({
    super.key,
    required this.dailyIntake,
    required this.goals,
    required this.userId,
  });

  @override
  State<AICoachingCard> createState() => _AICoachingCardState();
}

class _AICoachingCardState extends State<AICoachingCard> {
  bool _isLoading = false;
  String? _suggestion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSource = OpenRouterDataSource();
      final timeContext = _getTimeContext();

      final suggestion = await dataSource.getCoachingSuggestions(
        dailyIntake: widget.dailyIntake,
        goals: widget.goals,
        context: timeContext,
      );

      if (mounted) {
        setState(() {
          _suggestion = suggestion;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to get coaching suggestions';
          _isLoading = false;
        });
      }
    }
  }

  String _getTimeContext() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'It\'s morning';
    } else if (hour < 17) {
      return 'It\'s afternoon';
    } else {
      return 'It\'s evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.purple.shade600,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Coach',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!_isLoading)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadSuggestion,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Content
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Getting personalized suggestions...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else if (_error != null)
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else if (_suggestion != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.yellow[300],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Today\'s Tip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _suggestion!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            // Premium badge
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'PREMIUM FEATURE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
