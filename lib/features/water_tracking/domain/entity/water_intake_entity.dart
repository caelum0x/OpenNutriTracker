import 'package:equatable/equatable.dart';

/// Domain entity for water intake tracking
class WaterIntakeEntity extends Equatable {
  final String id;
  final DateTime date;
  final double amountMl;
  final DateTime timestamp;

  const WaterIntakeEntity({
    required this.id,
    required this.date,
    required this.amountMl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, date, amountMl, timestamp];
}

/// Entity for daily water intake summary
class DailyWaterSummaryEntity extends Equatable {
  final DateTime date;
  final double totalMl;
  final double goalMl;
  final List<WaterIntakeEntity> intakes;

  const DailyWaterSummaryEntity({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.intakes,
  });

  /// Returns progress percentage (0-100)
  double get progressPercentage => (totalMl / goalMl * 100).clamp(0, 100);

  /// Returns true if goal is reached
  bool get isGoalReached => totalMl >= goalMl;

  /// Returns remaining amount to reach goal
  double get remainingMl => (goalMl - totalMl).clamp(0, double.infinity);

  /// Returns number of glasses (250ml each)
  int get glassesCount => (totalMl / 250).round();

  @override
  List<Object?> get props => [date, totalMl, goalMl, intakes];
}
