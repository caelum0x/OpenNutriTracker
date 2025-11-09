import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Events for AI Photo Analysis BLoC
abstract class AIPhotoEvent extends Equatable {
  const AIPhotoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to analyze a photo from file path
class AnalyzePhotoFromPath extends AIPhotoEvent {
  final String imagePath;
  final bool includeVolumeData;

  const AnalyzePhotoFromPath({
    required this.imagePath,
    this.includeVolumeData = false,
  });

  @override
  List<Object?> get props => [imagePath, includeVolumeData];
}

/// Event to analyze a photo from bytes (camera)
class AnalyzePhotoFromBytes extends AIPhotoEvent {
  final Uint8List imageBytes;
  final bool includeVolumeData;

  const AnalyzePhotoFromBytes({
    required this.imageBytes,
    this.includeVolumeData = false,
  });

  @override
  List<Object?> get props => [imageBytes, includeVolumeData];
}

/// Event to reset the analysis state
class ResetAnalysis extends AIPhotoEvent {
  const ResetAnalysis();
}

/// Event to adjust a specific food item's nutrition
class AdjustFoodItem extends AIPhotoEvent {
  final int foodIndex;
  final double? servingSize;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const AdjustFoodItem({
    required this.foodIndex,
    this.servingSize,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  @override
  List<Object?> get props => [
        foodIndex,
        servingSize,
        calories,
        protein,
        carbs,
        fat,
      ];
}

/// Event to confirm and save the analysis to diary
class ConfirmAnalysis extends AIPhotoEvent {
  final DateTime mealTime;
  final String mealType; // breakfast, lunch, dinner, snack

  const ConfirmAnalysis({
    required this.mealTime,
    required this.mealType,
  });

  @override
  List<Object?> get props => [mealTime, mealType];
}
