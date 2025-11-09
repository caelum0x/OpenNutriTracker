import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/data_sources/openrouter_data_source.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/dto/food_analysis_dto.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';

/// Repository for AI photo analysis operations
class AIPhotoRepository {
  final OpenRouterDataSource dataSource;
  final log = Logger('AIPhotoRepository');

  AIPhotoRepository({required this.dataSource});

  /// Analyzes a food photo and returns nutritional information
  ///
  /// [imagePath] - Path to the image file
  /// [includeVolumeData] - Whether to request volume estimation
  Future<FoodAnalysisEntity> analyzeFoodPhoto({
    required String imagePath,
    bool includeVolumeData = false,
  }) async {
    try {
      log.fine('Reading image file: $imagePath');

      // Read image file and convert to base64
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      log.fine('Image size: ${imageBytes.length} bytes');

      // Call OpenRouter API
      final response = await dataSource.analyzeFoodImage(
        imageBase64: base64Image,
        includeVolumeData: includeVolumeData,
      );

      // Parse the AI response content which should be JSON
      final content = response.choices.first.message.content;
      log.fine('Received AI response: ${content.substring(0, 100)}...');

      // Extract JSON from markdown code blocks if present
      final jsonString = _extractJson(content);
      final analysisDto = FoodAnalysisDTO.fromJson(jsonDecode(jsonString));

      // Convert DTO to Entity
      return _mapDtoToEntity(analysisDto);
    } catch (e, stackTrace) {
      log.severe('Error analyzing food photo: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Analyzes a food photo from bytes (useful for camera capture)
  Future<FoodAnalysisEntity> analyzeFoodPhotoFromBytes({
    required Uint8List imageBytes,
    bool includeVolumeData = false,
  }) async {
    try {
      log.fine('Analyzing image from bytes: ${imageBytes.length} bytes');

      final base64Image = base64Encode(imageBytes);

      final response = await dataSource.analyzeFoodImage(
        imageBase64: base64Image,
        includeVolumeData: includeVolumeData,
      );

      final content = response.choices.first.message.content;
      final jsonString = _extractJson(content);
      final analysisDto = FoodAnalysisDTO.fromJson(jsonDecode(jsonString));

      return _mapDtoToEntity(analysisDto);
    } catch (e, stackTrace) {
      log.severe('Error analyzing food photo from bytes: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Gets AI coaching suggestions
  Future<String> getCoachingSuggestions({
    required Map<String, dynamic> dailyIntake,
    required Map<String, dynamic> goals,
    String? context,
  }) async {
    try {
      return await dataSource.getCoachingSuggestions(
        dailyIntake: dailyIntake,
        goals: goals,
        context: context,
      );
    } catch (e, stackTrace) {
      log.severe('Error getting coaching suggestions: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Extracts JSON from AI response (handles markdown code blocks)
  String _extractJson(String content) {
    // Remove markdown code blocks if present
    final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonPattern.firstMatch(content);

    if (match != null) {
      return match.group(1)!.trim();
    }

    // Also try without "json" specifier
    final codeBlockPattern = RegExp(r'```\s*([\s\S]*?)\s*```');
    final codeMatch = codeBlockPattern.firstMatch(content);

    if (codeMatch != null) {
      return codeMatch.group(1)!.trim();
    }

    // If no code blocks, assume the entire content is JSON
    return content.trim();
  }

  /// Maps DTO to Entity
  FoodAnalysisEntity _mapDtoToEntity(FoodAnalysisDTO dto) {
    return FoodAnalysisEntity(
      foods: dto.foods
          .map(
            (foodDto) => FoodItemEntity(
              name: foodDto.name,
              servingSize: foodDto.servingSize,
              servingUnit: foodDto.servingUnit,
              calories: foodDto.calories,
              protein: foodDto.protein,
              carbs: foodDto.carbs,
              fat: foodDto.fat,
              confidence: foodDto.confidence,
            ),
          )
          .toList(),
      totalCalories: dto.totalCalories,
      totalProtein: dto.totalProtein,
      totalCarbs: dto.totalCarbs,
      totalFat: dto.totalFat,
      notes: dto.notes,
      analyzedAt: DateTime.now(),
    );
  }
}
