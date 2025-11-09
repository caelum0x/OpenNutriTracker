import 'package:equatable/equatable.dart';

/// Events for Water Tracking BLoC
abstract class WaterTrackingEvent extends Equatable {
  const WaterTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load water data for a specific date
class LoadWaterData extends WaterTrackingEvent {
  final DateTime date;

  const LoadWaterData({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Event to add water intake
class AddWaterIntake extends WaterTrackingEvent {
  final double amountMl;
  final DateTime? date;

  const AddWaterIntake({
    required this.amountMl,
    this.date,
  });

  @override
  List<Object?> get props => [amountMl, date];
}

/// Event to delete a water intake entry
class DeleteWaterIntake extends WaterTrackingEvent {
  final String id;

  const DeleteWaterIntake({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to update water goal
class UpdateWaterGoal extends WaterTrackingEvent {
  final double goalMl;

  const UpdateWaterGoal({required this.goalMl});

  @override
  List<Object?> get props => [goalMl];
}
