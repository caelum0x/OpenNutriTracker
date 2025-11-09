import 'package:json_annotation/json_annotation.dart';

part 'food_analysis_dto.g.dart';

/// DTO for AI food analysis result
@JsonSerializable()
class FoodAnalysisDTO {
  final List<FoodItemDTO> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String? notes;

  FoodAnalysisDTO({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.notes,
  });

  factory FoodAnalysisDTO.fromJson(Map<String, dynamic> json) =>
      _$FoodAnalysisDTOFromJson(json);

  Map<String, dynamic> toJson() => _$FoodAnalysisDTOToJson(this);
}

@JsonSerializable()
class FoodItemDTO {
  final String name;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int confidence;

  FoodItemDTO({
    required this.name,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });

  factory FoodItemDTO.fromJson(Map<String, dynamic> json) =>
      _$FoodItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemDTOToJson(this);
}
