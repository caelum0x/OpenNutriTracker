import 'dart:typed_data';

import 'package:opennutritracker/features/ai_photo_analysis/data/repository/ai_photo_repository.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';

/// Use case for analyzing food photos with AI
class AnalyzeFoodPhotoUseCase {
  final AIPhotoRepository repository;

  AnalyzeFoodPhotoUseCase({required this.repository});

  /// Analyzes a food photo from a file path
  Future<FoodAnalysisEntity> execute({
    required String imagePath,
    bool includeVolumeData = false,
  }) async {
    return await repository.analyzeFoodPhoto(
      imagePath: imagePath,
      includeVolumeData: includeVolumeData,
    );
  }

  /// Analyzes a food photo from bytes (camera capture)
  Future<FoodAnalysisEntity> executeFromBytes({
    required Uint8List imageBytes,
    bool includeVolumeData = false,
  }) async {
    return await repository.analyzeFoodPhotoFromBytes(
      imageBytes: imageBytes,
      includeVolumeData: includeVolumeData,
    );
  }
}
