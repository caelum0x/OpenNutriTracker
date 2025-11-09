import 'package:equatable/equatable.dart';

/// Domain entity representing the result of AI food analysis
class FoodAnalysisEntity extends Equatable {
  final List<FoodItemEntity> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String? notes;
  final DateTime analyzedAt;

  const FoodAnalysisEntity({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.notes,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        foods,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        notes,
        analyzedAt,
      ];
}

/// Domain entity representing a single food item identified by AI
class FoodItemEntity extends Equatable {
  final String name;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int confidence;

  const FoodItemEntity({
    required this.name,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });

  /// Returns true if the AI is confident about this identification
  bool get isHighConfidence => confidence >= 70;

  /// Returns true if the identification is uncertain
  bool get isLowConfidence => confidence < 50;

  @override
  List<Object?> get props => [
        name,
        servingSize,
        servingUnit,
        calories,
        protein,
        carbs,
        fat,
        confidence,
      ];
}
