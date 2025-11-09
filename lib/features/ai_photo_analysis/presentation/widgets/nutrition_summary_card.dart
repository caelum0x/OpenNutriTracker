import 'package:flutter/material.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';

/// Card showing total nutrition summary
class NutritionSummaryCard extends StatelessWidget {
  final FoodAnalysisEntity analysis;

  const NutritionSummaryCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Nutrition',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Calories - Large display
            Center(
              child: Column(
                children: [
                  Text(
                    analysis.totalCalories.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'calories',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Macros in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroColumn(
                  context,
                  'Protein',
                  analysis.totalProtein.toInt(),
                  'g',
                  Icons.egg_outlined,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                _buildMacroColumn(
                  context,
                  'Carbs',
                  analysis.totalCarbs.toInt(),
                  'g',
                  Icons.grain,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                _buildMacroColumn(
                  context,
                  'Fat',
                  analysis.totalFat.toInt(),
                  'g',
                  Icons.water_drop_outlined,
                ),
              ],
            ),

            // Items count
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${analysis.foods.length} item${analysis.foods.length != 1 ? 's' : ''} detected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn(
    BuildContext context,
    String label,
    int value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          '$value$unit',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
