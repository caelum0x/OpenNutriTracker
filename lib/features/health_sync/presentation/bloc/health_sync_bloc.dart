import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/health_sync/data/data_source/health_data_source.dart';
import 'package:opennutritracker/features/health_sync/domain/entity/health_sync_entity.dart';
import 'package:opennutritracker/features/health_sync/presentation/bloc/health_sync_event.dart';
import 'package:opennutritracker/features/health_sync/presentation/bloc/health_sync_state.dart';

/// BLoC for managing health sync state
class HealthSyncBloc extends Bloc<HealthSyncEvent, HealthSyncState> {
  final HealthDataSource healthDataSource;
  final log = Logger('HealthSyncBloc');

  // Default configuration
  HealthSyncConfigEntity _config = const HealthSyncConfigEntity(
    isEnabled: false,
    syncCaloriesBurned: true,
    syncWeight: true,
    syncWaterIntake: true,
    syncNutrition: true,
    autoSync: true,
  );

  HealthSyncBloc({required this.healthDataSource})
      : super(const HealthSyncInitial()) {
    on<InitializeHealthSync>(_onInitialize);
    on<RequestHealthPermissions>(_onRequestPermissions);
    on<ToggleHealthSync>(_onToggleHealthSync);
    on<ToggleSyncFeature>(_onToggleSyncFeature);
    on<ManualSync>(_onManualSync);
    on<SyncTodayData>(_onSyncTodayData);
    on<LoadHealthSummary>(_onLoadHealthSummary);
    on<WriteWaterToHealth>(_onWriteWaterToHealth);
    on<WriteNutritionToHealth>(_onWriteNutritionToHealth);
    on<WriteWeightToHealth>(_onWriteWeightToHealth);
  }

  Future<void> _onInitialize(
    InitializeHealthSync event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(const HealthSyncLoading(message: 'Initializing health sync...'));

    try {
      log.fine('Initializing health sync');

      // Check if health is available
      final isAvailable = await healthDataSource.isHealthAvailable();

      if (!isAvailable) {
        emit(const HealthNotAvailable(
          message: 'Health data is not available on this device',
        ));
        return;
      }

      // Return configured state
      emit(HealthSyncConfigured(
        config: _config,
        status: HealthSyncStatus.notConnected,
      ));
    } catch (error, stackTrace) {
      log.severe('Error initializing health sync', error, stackTrace);
      emit(HealthSyncError(
        message: 'Failed to initialize health sync',
        technicalDetails: error.toString(),
      ));
    }
  }

  Future<void> _onRequestPermissions(
    RequestHealthPermissions event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(const HealthSyncLoading(message: 'Requesting permissions...'));

    try {
      log.fine('Requesting health permissions');

      final granted = await healthDataSource.requestPermissions();

      if (granted) {
        _config = _config.copyWith(isEnabled: true);

        emit(HealthSyncConfigured(
          config: _config,
          status: HealthSyncStatus.connected,
        ));

        // Load today's data automatically
        add(LoadHealthSummary(date: DateTime.now()));
      } else {
        emit(const HealthPermissionsDenied(
          message: 'Health permissions were not granted',
        ));
      }
    } catch (error, stackTrace) {
      log.severe('Error requesting permissions', error, stackTrace);
      emit(HealthSyncError(
        message: 'Failed to request permissions',
        technicalDetails: error.toString(),
      ));
    }
  }

  void _onToggleHealthSync(
    ToggleHealthSync event,
    Emitter<HealthSyncState> emit,
  ) {
    log.fine('Toggling health sync: ${event.enabled}');

    _config = _config.copyWith(isEnabled: event.enabled);

    if (state is HealthSyncConfigured) {
      final currentState = state as HealthSyncConfigured;
      emit(HealthSyncConfigured(
        config: _config,
        status: currentState.status,
        summary: currentState.summary,
      ));
    }
  }

  void _onToggleSyncFeature(
    ToggleSyncFeature event,
    Emitter<HealthSyncState> emit,
  ) {
    log.fine('Toggling ${event.feature}: ${event.enabled}');

    switch (event.feature) {
      case 'calories_burned':
        _config = _config.copyWith(syncCaloriesBurned: event.enabled);
        break;
      case 'weight':
        _config = _config.copyWith(syncWeight: event.enabled);
        break;
      case 'water':
        _config = _config.copyWith(syncWaterIntake: event.enabled);
        break;
      case 'nutrition':
        _config = _config.copyWith(syncNutrition: event.enabled);
        break;
    }

    if (state is HealthSyncConfigured) {
      final currentState = state as HealthSyncConfigured;
      emit(HealthSyncConfigured(
        config: _config,
        status: currentState.status,
        summary: currentState.summary,
      ));
    }
  }

  Future<void> _onManualSync(
    ManualSync event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(const HealthSyncing(progressMessage: 'Syncing with health app...'));

    try {
      log.fine('Starting manual sync');

      // TODO: Implement full sync logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate sync

      _config = _config.copyWith(lastSyncTime: DateTime.now());

      emit(HealthSyncSuccess(
        message: 'Sync completed successfully',
        summary: null, // TODO: Return actual summary
      ));

      // Return to configured state
      add(LoadHealthSummary(date: DateTime.now()));
    } catch (error, stackTrace) {
      log.severe('Error during manual sync', error, stackTrace);
      emit(HealthSyncError(
        message: 'Sync failed',
        technicalDetails: error.toString(),
      ));
    }
  }

  Future<void> _onSyncTodayData(
    SyncTodayData event,
    Emitter<HealthSyncState> emit,
  ) async {
    // Similar to manual sync but specifically for today
    add(const ManualSync());
  }

  Future<void> _onLoadHealthSummary(
    LoadHealthSummary event,
    Emitter<HealthSyncState> emit,
  ) async {
    if (!_config.isEnabled) return;

    try {
      log.fine('Loading health summary for ${event.date}');

      // Get activity summary
      final activity = await healthDataSource.getTodayActivity();

      // Get recent weights
      final weights = await healthDataSource.getWeightData(
        startDate: event.date.subtract(const Duration(days: 30)),
        endDate: event.date,
      );

      final summary = HealthDataSummary(
        caloriesBurned: activity.caloriesBurned,
        steps: activity.steps,
        recentWeights: weights
            .map((w) => WeightEntry(
                  date: w.date,
                  weightKg: w.weightKg,
                  source: w.source,
                ))
            .toList(),
        date: event.date,
      );

      if (state is HealthSyncConfigured) {
        final currentState = state as HealthSyncConfigured;
        emit(HealthSyncConfigured(
          config: _config,
          status: currentState.status,
          summary: summary,
        ));
      }
    } catch (error, stackTrace) {
      log.severe('Error loading health summary', error, stackTrace);
    }
  }

  Future<void> _onWriteWaterToHealth(
    WriteWaterToHealth event,
    Emitter<HealthSyncState> emit,
  ) async {
    if (!_config.isEnabled || !_config.syncWaterIntake) return;

    try {
      log.fine('Writing water to health: ${event.milliliters}ml');

      await healthDataSource.writeWater(
        milliliters: event.milliliters,
        date: event.date,
      );
    } catch (error, stackTrace) {
      log.severe('Error writing water to health', error, stackTrace);
    }
  }

  Future<void> _onWriteNutritionToHealth(
    WriteNutritionToHealth event,
    Emitter<HealthSyncState> emit,
  ) async {
    if (!_config.isEnabled || !_config.syncNutrition) return;

    try {
      log.fine('Writing nutrition to health');

      await healthDataSource.writeNutrition(
        calories: event.calories,
        proteinGrams: event.protein,
        carbsGrams: event.carbs,
        fatGrams: event.fat,
        date: event.date,
      );
    } catch (error, stackTrace) {
      log.severe('Error writing nutrition to health', error, stackTrace);
    }
  }

  Future<void> _onWriteWeightToHealth(
    WriteWeightToHealth event,
    Emitter<HealthSyncState> emit,
  ) async {
    if (!_config.isEnabled || !_config.syncWeight) return;

    try {
      log.fine('Writing weight to health: ${event.weightKg}kg');

      await healthDataSource.writeWeight(
        weightKg: event.weightKg,
        date: event.date,
      );
    } catch (error, stackTrace) {
      log.severe('Error writing weight to health', error, stackTrace);
    }
  }
}
