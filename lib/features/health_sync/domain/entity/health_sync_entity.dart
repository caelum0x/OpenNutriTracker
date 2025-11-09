import 'package:equatable/equatable.dart';

/// Health sync configuration entity
class HealthSyncConfigEntity extends Equatable {
  final bool isEnabled;
  final bool syncCaloriesBurned;
  final bool syncWeight;
  final bool syncWaterIntake;
  final bool syncNutrition;
  final bool autoSync;
  final DateTime? lastSyncTime;

  const HealthSyncConfigEntity({
    required this.isEnabled,
    required this.syncCaloriesBurned,
    required this.syncWeight,
    required this.syncWaterIntake,
    required this.syncNutrition,
    required this.autoSync,
    this.lastSyncTime,
  });

  HealthSyncConfigEntity copyWith({
    bool? isEnabled,
    bool? syncCaloriesBurned,
    bool? syncWeight,
    bool? syncWaterIntake,
    bool? syncNutrition,
    bool? autoSync,
    DateTime? lastSyncTime,
  }) {
    return HealthSyncConfigEntity(
      isEnabled: isEnabled ?? this.isEnabled,
      syncCaloriesBurned: syncCaloriesBurned ?? this.syncCaloriesBurned,
      syncWeight: syncWeight ?? this.syncWeight,
      syncWaterIntake: syncWaterIntake ?? this.syncWaterIntake,
      syncNutrition: syncNutrition ?? this.syncNutrition,
      autoSync: autoSync ?? this.autoSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        syncCaloriesBurned,
        syncWeight,
        syncWaterIntake,
        syncNutrition,
        autoSync,
        lastSyncTime,
      ];
}

/// Health sync status
enum HealthSyncStatus {
  notConnected,
  connected,
  syncing,
  error,
}

/// Health data summary
class HealthDataSummary extends Equatable {
  final double caloriesBurned;
  final int steps;
  final List<WeightEntry> recentWeights;
  final DateTime date;

  const HealthDataSummary({
    required this.caloriesBurned,
    required this.steps,
    required this.recentWeights,
    required this.date,
  });

  @override
  List<Object?> get props => [caloriesBurned, steps, recentWeights, date];
}

/// Weight entry
class WeightEntry extends Equatable {
  final DateTime date;
  final double weightKg;
  final String source;

  const WeightEntry({
    required this.date,
    required this.weightKg,
    required this.source,
  });

  double get weightLbs => weightKg * 2.20462;

  @override
  List<Object?> get props => [date, weightKg, source];
}
