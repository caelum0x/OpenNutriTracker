import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';

/// States for AI Photo Analysis BLoC
abstract class AIPhotoState extends Equatable {
  const AIPhotoState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no analysis
class AIPhotoInitial extends AIPhotoState {
  const AIPhotoInitial();
}

/// Loading state - analyzing image
class AIPhotoAnalyzing extends AIPhotoState {
  final String? progressMessage;

  const AIPhotoAnalyzing({this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

/// Success state - analysis complete
class AIPhotoAnalyzed extends AIPhotoState {
  final FoodAnalysisEntity analysis;

  const AIPhotoAnalyzed({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}

/// Error state - analysis failed
class AIPhotoError extends AIPhotoState {
  final String message;
  final String? technicalDetails;

  const AIPhotoError({
    required this.message,
    this.technicalDetails,
  });

  @override
  List<Object?> get props => [message, technicalDetails];
}

/// State when analysis is being confirmed/saved
class AIPhotoSaving extends AIPhotoState {
  final FoodAnalysisEntity analysis;

  const AIPhotoSaving({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}

/// State when analysis has been saved successfully
class AIPhotoSaved extends AIPhotoState {
  final FoodAnalysisEntity analysis;

  const AIPhotoSaved({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}
