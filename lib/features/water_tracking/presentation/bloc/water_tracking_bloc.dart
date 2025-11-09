import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/water_tracking/data/data_source/water_intake_data_source.dart';
import 'package:opennutritracker/features/water_tracking/domain/entity/water_intake_entity.dart';
import 'package:opennutritracker/features/water_tracking/presentation/bloc/water_tracking_event.dart';
import 'package:opennutritracker/features/water_tracking/presentation/bloc/water_tracking_state.dart';

/// BLoC for managing water tracking state
class WaterTrackingBloc extends Bloc<WaterTrackingEvent, WaterTrackingState> {
  final WaterIntakeDataSource dataSource;
  final log = Logger('WaterTrackingBloc');

  // Default water goal in ml (2000ml = 2 liters = ~8 glasses)
  double waterGoalMl = 2000.0;

  WaterTrackingBloc({required this.dataSource})
      : super(const WaterTrackingInitial()) {
    on<LoadWaterData>(_onLoadWaterData);
    on<AddWaterIntake>(_onAddWaterIntake);
    on<DeleteWaterIntake>(_onDeleteWaterIntake);
    on<UpdateWaterGoal>(_onUpdateWaterGoal);
  }

  Future<void> _onLoadWaterData(
    LoadWaterData event,
    Emitter<WaterTrackingState> emit,
  ) async {
    emit(const WaterTrackingLoading());

    try {
      log.fine('Loading water data for ${event.date}');

      final intakes = dataSource.getWaterIntakesForDate(event.date);
      final totalMl = intakes.fold<double>(0, (sum, intake) => sum + intake.amountMl);

      final summary = DailyWaterSummaryEntity(
        date: event.date,
        totalMl: totalMl,
        goalMl: waterGoalMl,
        intakes: intakes,
      );

      emit(WaterTrackingLoaded(summary: summary));
    } catch (error, stackTrace) {
      log.severe('Error loading water data', error, stackTrace);
      emit(WaterTrackingError(
        message: 'Failed to load water data: $error',
      ));
    }
  }

  Future<void> _onAddWaterIntake(
    AddWaterIntake event,
    Emitter<WaterTrackingState> emit,
  ) async {
    try {
      final date = event.date ?? DateTime.now();
      log.fine('Adding water intake: ${event.amountMl}ml on $date');

      await dataSource.addWaterIntake(
        date: date,
        amountMl: event.amountMl,
      );

      // Reload data for the current date
      final currentDate = (state is WaterTrackingLoaded)
          ? (state as WaterTrackingLoaded).summary.date
          : DateTime.now();

      add(LoadWaterData(date: currentDate));
    } catch (error, stackTrace) {
      log.severe('Error adding water intake', error, stackTrace);
      emit(WaterTrackingError(
        message: 'Failed to add water intake: $error',
      ));
    }
  }

  Future<void> _onDeleteWaterIntake(
    DeleteWaterIntake event,
    Emitter<WaterTrackingState> emit,
  ) async {
    try {
      log.fine('Deleting water intake: ${event.id}');

      await dataSource.deleteWaterIntake(event.id);

      // Reload data for the current date
      final currentDate = (state is WaterTrackingLoaded)
          ? (state as WaterTrackingLoaded).summary.date
          : DateTime.now();

      add(LoadWaterData(date: currentDate));
    } catch (error, stackTrace) {
      log.severe('Error deleting water intake', error, stackTrace);
      emit(WaterTrackingError(
        message: 'Failed to delete water intake: $error',
      ));
    }
  }

  void _onUpdateWaterGoal(
    UpdateWaterGoal event,
    Emitter<WaterTrackingState> emit,
  ) {
    log.fine('Updating water goal to ${event.goalMl}ml');
    waterGoalMl = event.goalMl;

    // Reload current data with new goal
    if (state is WaterTrackingLoaded) {
      final currentState = state as WaterTrackingLoaded;
      add(LoadWaterData(date: currentState.summary.date));
    }
  }
}
