import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/water_tracking/data/dbo/water_intake_dbo.dart';
import 'package:opennutritracker/features/water_tracking/domain/entity/water_intake_entity.dart';
import 'package:uuid/uuid.dart';

/// Data source for water intake (Hive storage)
class WaterIntakeDataSource {
  static const String boxName = 'waterIntakeBox';
  final log = Logger('WaterIntakeDataSource');
  final Uuid uuid = const Uuid();

  /// Gets the Hive box for water intake
  Box<WaterIntakeDBO> get _box => Hive.box<WaterIntakeDBO>(boxName);

  /// Adds a water intake entry
  Future<WaterIntakeEntity> addWaterIntake({
    required DateTime date,
    required double amountMl,
  }) async {
    try {
      final id = uuid.v4();
      final timestamp = DateTime.now();

      final dbo = WaterIntakeDBO(
        id: id,
        date: date,
        amountMl: amountMl,
        timestamp: timestamp,
      );

      await _box.put(id, dbo);

      log.fine('Added water intake: $amountMl ml on ${date.toIso8601String()}');

      return WaterIntakeEntity(
        id: id,
        date: date,
        amountMl: amountMl,
        timestamp: timestamp,
      );
    } catch (e, stackTrace) {
      log.severe('Error adding water intake', e, stackTrace);
      rethrow;
    }
  }

  /// Gets all water intakes for a specific date
  List<WaterIntakeEntity> getWaterIntakesForDate(DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _box.values
          .where((dbo) =>
              dbo.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              dbo.date.isBefore(endOfDay))
          .map((dbo) => WaterIntakeEntity(
                id: dbo.id,
                date: dbo.date,
                amountMl: dbo.amountMl,
                timestamp: dbo.timestamp,
              ))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
    } catch (e, stackTrace) {
      log.severe('Error getting water intakes for date', e, stackTrace);
      return [];
    }
  }

  /// Gets total water intake for a specific date
  double getTotalWaterForDate(DateTime date) {
    final intakes = getWaterIntakesForDate(date);
    return intakes.fold<double>(0, (sum, intake) => sum + intake.amountMl);
  }

  /// Deletes a specific water intake entry
  Future<void> deleteWaterIntake(String id) async {
    try {
      await _box.delete(id);
      log.fine('Deleted water intake: $id');
    } catch (e, stackTrace) {
      log.severe('Error deleting water intake', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes all water intakes for a specific date
  Future<void> deleteAllForDate(DateTime date) async {
    try {
      final intakes = getWaterIntakesForDate(date);
      for (final intake in intakes) {
        await _box.delete(intake.id);
      }
      log.fine('Deleted all water intakes for ${date.toIso8601String()}');
    } catch (e, stackTrace) {
      log.severe('Error deleting water intakes for date', e, stackTrace);
      rethrow;
    }
  }

  /// Gets water intake history for the last N days
  Map<DateTime, double> getWaterHistory(int days) {
    try {
      final now = DateTime.now();
      final history = <DateTime, double>{};

      for (var i = 0; i < days; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        history[date] = getTotalWaterForDate(date);
      }

      return history;
    } catch (e, stackTrace) {
      log.severe('Error getting water history', e, stackTrace);
      return {};
    }
  }
}
