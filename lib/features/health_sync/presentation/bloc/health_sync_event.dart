import 'package:equatable/equatable.dart';

/// Events for Health Sync BLoC
abstract class HealthSyncEvent extends Equatable {
  const HealthSyncEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize health sync
class InitializeHealthSync extends HealthSyncEvent {
  const InitializeHealthSync();
}

/// Event to request health permissions
class RequestHealthPermissions extends HealthSyncEvent {
  const RequestHealthPermissions();
}

/// Event to enable/disable health sync
class ToggleHealthSync extends HealthSyncEvent {
  final bool enabled;

  const ToggleHealthSync({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle specific sync feature
class ToggleSyncFeature extends HealthSyncEvent {
  final String feature; // calories_burned, weight, water, nutrition
  final bool enabled;

  const ToggleSyncFeature({
    required this.feature,
    required this.enabled,
  });

  @override
  List<Object?> get props => [feature, enabled];
}

/// Event to manually trigger sync
class ManualSync extends HealthSyncEvent {
  const ManualSync();
}

/// Event to sync today's data
class SyncTodayData extends HealthSyncEvent {
  const SyncTodayData();
}

/// Event to load health data summary
class LoadHealthSummary extends HealthSyncEvent {
  final DateTime date;

  const LoadHealthSummary({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Event to write water intake to health
class WriteWaterToHealth extends HealthSyncEvent {
  final double milliliters;
  final DateTime date;

  const WriteWaterToHealth({
    required this.milliliters,
    required this.date,
  });

  @override
  List<Object?> get props => [milliliters, date];
}

/// Event to write nutrition to health
class WriteNutritionToHealth extends HealthSyncEvent {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;

  const WriteNutritionToHealth({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
  });

  @override
  List<Object?> get props => [calories, protein, carbs, fat, date];
}

/// Event to write weight to health
class WriteWeightToHealth extends HealthSyncEvent {
  final double weightKg;
  final DateTime date;

  const WriteWeightToHealth({
    required this.weightKg,
    required this.date,
  });

  @override
  List<Object?> get props => [weightKg, date];
}
