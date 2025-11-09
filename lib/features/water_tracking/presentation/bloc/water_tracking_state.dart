import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/water_tracking/domain/entity/water_intake_entity.dart';

/// States for Water Tracking BLoC
abstract class WaterTrackingState extends Equatable {
  const WaterTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WaterTrackingInitial extends WaterTrackingState {
  const WaterTrackingInitial();
}

/// Loading state
class WaterTrackingLoading extends WaterTrackingState {
  const WaterTrackingLoading();
}

/// Loaded state with water data
class WaterTrackingLoaded extends WaterTrackingState {
  final DailyWaterSummaryEntity summary;

  const WaterTrackingLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

/// Error state
class WaterTrackingError extends WaterTrackingState {
  final String message;

  const WaterTrackingError({required this.message});

  @override
  List<Object?> get props => [message];
}
