import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/usecase/analyze_food_photo_usecase.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_event.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_state.dart';

/// BLoC for managing AI photo analysis state
class AIPhotoBloc extends Bloc<AIPhotoEvent, AIPhotoState> {
  final AnalyzeFoodPhotoUseCase analyzeFoodPhotoUseCase;
  final log = Logger('AIPhotoBloc');

  AIPhotoBloc({
    required this.analyzeFoodPhotoUseCase,
  }) : super(const AIPhotoInitial()) {
    on<AnalyzePhotoFromPath>(_onAnalyzePhotoFromPath);
    on<AnalyzePhotoFromBytes>(_onAnalyzePhotoFromBytes);
    on<ResetAnalysis>(_onResetAnalysis);
    on<AdjustFoodItem>(_onAdjustFoodItem);
    on<ConfirmAnalysis>(_onConfirmAnalysis);
  }

  Future<void> _onAnalyzePhotoFromPath(
    AnalyzePhotoFromPath event,
    Emitter<AIPhotoState> emit,
  ) async {
    emit(const AIPhotoAnalyzing(
      progressMessage: 'Analyzing your food photo...',
    ));

    try {
      log.fine('Starting photo analysis from path: ${event.imagePath}');

      final analysis = await analyzeFoodPhotoUseCase.execute(
        imagePath: event.imagePath,
        includeVolumeData: event.includeVolumeData,
      );

      log.fine('Analysis complete: ${analysis.foods.length} items found');

      emit(AIPhotoAnalyzed(analysis: analysis));
    } catch (error, stackTrace) {
      log.severe('Error analyzing photo', error, stackTrace);

      emit(AIPhotoError(
        message: 'Failed to analyze photo. Please try again.',
        technicalDetails: error.toString(),
      ));
    }
  }

  Future<void> _onAnalyzePhotoFromBytes(
    AnalyzePhotoFromBytes event,
    Emitter<AIPhotoState> emit,
  ) async {
    emit(const AIPhotoAnalyzing(
      progressMessage: 'Analyzing your food photo...',
    ));

    try {
      log.fine('Starting photo analysis from bytes');

      final analysis = await analyzeFoodPhotoUseCase.executeFromBytes(
        imageBytes: event.imageBytes,
        includeVolumeData: event.includeVolumeData,
      );

      log.fine('Analysis complete: ${analysis.foods.length} items found');

      emit(AIPhotoAnalyzed(analysis: analysis));
    } catch (error, stackTrace) {
      log.severe('Error analyzing photo', error, stackTrace);

      emit(AIPhotoError(
        message: 'Failed to analyze photo. Please try again.',
        technicalDetails: error.toString(),
      ));
    }
  }

  void _onResetAnalysis(
    ResetAnalysis event,
    Emitter<AIPhotoState> emit,
  ) {
    log.fine('Resetting analysis');
    emit(const AIPhotoInitial());
  }

  void _onAdjustFoodItem(
    AdjustFoodItem event,
    Emitter<AIPhotoState> emit,
  ) {
    if (state is AIPhotoAnalyzed) {
      final currentState = state as AIPhotoAnalyzed;
      final analysis = currentState.analysis;

      // Create a copy of the foods list with the adjusted item
      final updatedFoods = List<FoodItemEntity>.from(analysis.foods);
      final food = updatedFoods[event.foodIndex];

      // Update the food item with new values
      updatedFoods[event.foodIndex] = FoodItemEntity(
        name: food.name,
        servingSize: event.servingSize ?? food.servingSize,
        servingUnit: food.servingUnit,
        calories: event.calories ?? food.calories,
        protein: event.protein ?? food.protein,
        carbs: event.carbs ?? food.carbs,
        fat: event.fat ?? food.fat,
        confidence: food.confidence,
      );

      // Recalculate totals
      final totalCalories = updatedFoods.fold<double>(
        0,
        (sum, item) => sum + item.calories,
      );
      final totalProtein = updatedFoods.fold<double>(
        0,
        (sum, item) => sum + item.protein,
      );
      final totalCarbs = updatedFoods.fold<double>(
        0,
        (sum, item) => sum + item.carbs,
      );
      final totalFat = updatedFoods.fold<double>(
        0,
        (sum, item) => sum + item.fat,
      );

      // Create updated analysis
      final updatedAnalysis = FoodAnalysisEntity(
        foods: updatedFoods,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        notes: analysis.notes,
        analyzedAt: analysis.analyzedAt,
      );

      emit(AIPhotoAnalyzed(analysis: updatedAnalysis));
    }
  }

  Future<void> _onConfirmAnalysis(
    ConfirmAnalysis event,
    Emitter<AIPhotoState> emit,
  ) async {
    if (state is AIPhotoAnalyzed) {
      final currentState = state as AIPhotoAnalyzed;
      final analysis = currentState.analysis;

      emit(AIPhotoSaving(analysis: analysis));

      try {
        // TODO: Save to diary (will implement when integrating with existing intake system)
        log.fine('Saving analysis to diary for ${event.mealTime}');

        await Future.delayed(const Duration(milliseconds: 500)); // Simulate save

        emit(AIPhotoSaved(analysis: analysis));
      } catch (error, stackTrace) {
        log.severe('Error saving analysis', error, stackTrace);

        emit(AIPhotoError(
          message: 'Failed to save to diary. Please try again.',
          technicalDetails: error.toString(),
        ));
      }
    }
  }
}
