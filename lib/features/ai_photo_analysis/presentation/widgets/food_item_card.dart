import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_bloc.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_event.dart';

/// Card displaying a single food item from AI analysis
class FoodItemCard extends StatelessWidget {
  final FoodItemEntity food;
  final int index;

  const FoodItemCard({
    super.key,
    required this.food,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food name and confidence
              Row(
                children: [
                  Expanded(
                    child: Text(
                      food.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildConfidenceBadge(context),
                ],
              ),

              const SizedBox(height: 8),

              // Serving size
              Text(
                '${food.servingSize} ${food.servingUnit}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

              const SizedBox(height: 12),

              // Nutrition info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildNutrientChip(
                    context,
                    '${food.calories.toInt()} cal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildNutrientChip(
                    context,
                    '${food.protein.toInt()}g protein',
                    Icons.egg,
                    Colors.red,
                  ),
                  _buildNutrientChip(
                    context,
                    '${food.carbs.toInt()}g carbs',
                    Icons.grain,
                    Colors.amber,
                  ),
                  _buildNutrientChip(
                    context,
                    '${food.fat.toInt()}g fat',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ],
              ),

              // Edit hint
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    Color badgeColor;
    String confidenceText;

    if (food.isHighConfidence) {
      badgeColor = Colors.green;
      confidenceText = 'High';
    } else if (food.isLowConfidence) {
      badgeColor = Colors.red;
      confidenceText = 'Low';
    } else {
      badgeColor = Colors.orange;
      confidenceText = 'Medium';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$confidenceText ${food.confidence}%',
            style: TextStyle(
              fontSize: 12,
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final servingSizeController =
        TextEditingController(text: food.servingSize.toString());
    final caloriesController =
        TextEditingController(text: food.calories.toString());
    final proteinController =
        TextEditingController(text: food.protein.toString());
    final carbsController = TextEditingController(text: food.carbs.toString());
    final fatController = TextEditingController(text: food.fat.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${food.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: servingSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Serving Size (${food.servingUnit})',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Protein (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carbs (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fat (g)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update food item
              context.read<AIPhotoBloc>().add(
                    AdjustFoodItem(
                      foodIndex: index,
                      servingSize: double.tryParse(servingSizeController.text),
                      calories: double.tryParse(caloriesController.text),
                      protein: double.tryParse(proteinController.text),
                      carbs: double.tryParse(carbsController.text),
                      fat: double.tryParse(fatController.text),
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
