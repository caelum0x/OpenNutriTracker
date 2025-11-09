import 'package:hive/hive.dart';

part 'water_intake_dbo.g.dart';

/// Database object for water intake (Hive)
@HiveType(typeId: 20) // Using 20, adjust if conflicts with existing types
class WaterIntakeDBO extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double amountMl;

  @HiveField(3)
  DateTime timestamp;

  WaterIntakeDBO({
    required this.id,
    required this.date,
    required this.amountMl,
    required this.timestamp,
  });

  /// Converts DBO to Entity
  Map<String, dynamic> toEntity() => {
        'id': id,
        'date': date,
        'amountMl': amountMl,
        'timestamp': timestamp,
      };

  /// Creates DBO from Entity data
  factory WaterIntakeDBO.fromEntity(Map<String, dynamic> entity) {
    return WaterIntakeDBO(
      id: entity['id'] as String,
      date: entity['date'] as DateTime,
      amountMl: entity['amountMl'] as double,
      timestamp: entity['timestamp'] as DateTime,
    );
  }
}
