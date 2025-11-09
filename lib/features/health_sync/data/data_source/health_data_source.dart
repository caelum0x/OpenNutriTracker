import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

/// Data source for Google Fit and Apple HealthKit integration
class HealthDataSource {
  final log = Logger('HealthDataSource');
  final Health _health = Health();

  // Data types we want to read/write
  static final List<HealthDataType> readTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
    HealthDataType.WATER,
    HealthDataType.DIETARY_CARBS,
    HealthDataType.DIETARY_PROTEIN,
    HealthDataType.DIETARY_FAT,
    HealthDataType.DIETARY_CALORIES,
  ];

  static final List<HealthDataType> writeTypes = [
    HealthDataType.WATER,
    HealthDataType.DIETARY_CARBS,
    HealthDataType.DIETARY_PROTEIN,
    HealthDataType.DIETARY_FAT,
    HealthDataType.DIETARY_CALORIES,
    HealthDataType.WEIGHT,
  ];

  /// Requests permissions for health data access
  Future<bool> requestPermissions() async {
    try {
      log.fine('Requesting health permissions');

      // Request permissions for read and write
      final permissions = [
        ...readTypes.map((type) => HealthDataAccess.READ),
        ...writeTypes.map((type) => HealthDataAccess.WRITE),
      ];

      final types = [...readTypes, ...writeTypes];

      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      log.fine('Health permissions granted: $granted');
      return granted;
    } catch (e, stackTrace) {
      log.severe('Error requesting health permissions', e, stackTrace);
      return false;
    }
  }

  /// Checks if health data access is available
  Future<bool> isHealthAvailable() async {
    try {
      return await _health.isDataTypeAvailable(
        HealthDataType.ACTIVE_ENERGY_BURNED,
      );
    } catch (e) {
      log.warning('Health data not available: $e');
      return false;
    }
  }

  /// Gets calories burned for a date range
  Future<double> getCaloriesBurned({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log.fine('Getting calories burned from $startDate to $endDate');

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startDate,
        endTime: endDate,
      );

      double totalCalories = 0;
      for (final data in healthData) {
        if (data.value is NumericHealthValue) {
          totalCalories += (data.value as NumericHealthValue).numericValue;
        }
      }

      log.fine('Total calories burned: $totalCalories');
      return totalCalories;
    } catch (e, stackTrace) {
      log.severe('Error getting calories burned', e, stackTrace);
      return 0;
    }
  }

  /// Gets weight measurements for a date range
  Future<List<WeightMeasurement>> getWeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log.fine('Getting weight data from $startDate to $endDate');

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: startDate,
        endTime: endDate,
      );

      final measurements = <WeightMeasurement>[];
      for (final data in healthData) {
        if (data.value is NumericHealthValue) {
          final weight = (data.value as NumericHealthValue).numericValue;
          measurements.add(WeightMeasurement(
            date: data.dateFrom,
            weightKg: weight,
            source: data.sourceName,
          ));
        }
      }

      log.fine('Found ${measurements.length} weight measurements');
      return measurements;
    } catch (e, stackTrace) {
      log.severe('Error getting weight data', e, stackTrace);
      return [];
    }
  }

  /// Gets steps count for a date range
  Future<int> getStepsCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log.fine('Getting steps from $startDate to $endDate');

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startDate,
        endTime: endDate,
      );

      int totalSteps = 0;
      for (final data in healthData) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      log.fine('Total steps: $totalSteps');
      return totalSteps;
    } catch (e, stackTrace) {
      log.severe('Error getting steps', e, stackTrace);
      return 0;
    }
  }

  /// Writes weight data to health store
  Future<bool> writeWeight({
    required double weightKg,
    required DateTime date,
  }) async {
    try {
      log.fine('Writing weight: $weightKg kg at $date');

      final success = await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: date,
        endTime: date,
      );

      log.fine('Weight write success: $success');
      return success;
    } catch (e, stackTrace) {
      log.severe('Error writing weight', e, stackTrace);
      return false;
    }
  }

  /// Writes water intake to health store
  Future<bool> writeWater({
    required double milliliters,
    required DateTime date,
  }) async {
    try {
      log.fine('Writing water: $milliliters ml at $date');

      // Convert ml to liters for Health API
      final liters = milliliters / 1000;

      final success = await _health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: date,
        endTime: date,
      );

      log.fine('Water write success: $success');
      return success;
    } catch (e, stackTrace) {
      log.severe('Error writing water', e, stackTrace);
      return false;
    }
  }

  /// Writes nutrition data to health store
  Future<bool> writeNutrition({
    required double calories,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required DateTime date,
  }) async {
    try {
      log.fine('Writing nutrition data at $date');

      final results = await Future.wait([
        _health.writeHealthData(
          value: calories,
          type: HealthDataType.DIETARY_CALORIES,
          startTime: date,
          endTime: date,
        ),
        _health.writeHealthData(
          value: proteinGrams,
          type: HealthDataType.DIETARY_PROTEIN,
          startTime: date,
          endTime: date,
        ),
        _health.writeHealthData(
          value: carbsGrams,
          type: HealthDataType.DIETARY_CARBS,
          startTime: date,
          endTime: date,
        ),
        _health.writeHealthData(
          value: fatGrams,
          type: HealthDataType.DIETARY_FAT,
          startTime: date,
          endTime: date,
        ),
      ]);

      final allSuccess = results.every((success) => success);
      log.fine('Nutrition write success: $allSuccess');
      return allSuccess;
    } catch (e, stackTrace) {
      log.severe('Error writing nutrition', e, stackTrace);
      return false;
    }
  }

  /// Syncs local water intake to health store
  Future<bool> syncWaterIntake({
    required double milliliters,
    required DateTime date,
  }) async {
    return await writeWater(milliliters: milliliters, date: date);
  }

  /// Syncs local food intake to health store
  Future<bool> syncFoodIntake({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime date,
  }) async {
    return await writeNutrition(
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      date: date,
    );
  }

  /// Gets today's activity summary
  Future<ActivitySummary> getTodayActivity() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final caloriesBurned = await getCaloriesBurned(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    final steps = await getStepsCount(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return ActivitySummary(
      date: now,
      caloriesBurned: caloriesBurned,
      steps: steps,
    );
  }
}

/// Weight measurement data
class WeightMeasurement {
  final DateTime date;
  final double weightKg;
  final String source;

  WeightMeasurement({
    required this.date,
    required this.weightKg,
    required this.source,
  });
}

/// Daily activity summary
class ActivitySummary {
  final DateTime date;
  final double caloriesBurned;
  final int steps;

  ActivitySummary({
    required this.date,
    required this.caloriesBurned,
    required this.steps,
  });
}
