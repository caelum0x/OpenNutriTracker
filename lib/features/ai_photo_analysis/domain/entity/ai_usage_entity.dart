import 'package:equatable/equatable.dart';

/// Domain entity for tracking AI usage (for freemium limits)
class AIUsageEntity extends Equatable {
  final String userId;
  final DateTime date;
  final int photoScansUsed;
  final int photoScansLimit;
  final bool isPremium;

  const AIUsageEntity({
    required this.userId,
    required this.date,
    required this.photoScansUsed,
    required this.photoScansLimit,
    required this.isPremium,
  });

  /// Returns true if user can use AI photo scan
  bool get canUseScan => isPremium || photoScansUsed < photoScansLimit;

  /// Returns remaining scans for free users
  int get remainingScans => photoScansLimit - photoScansUsed;

  /// Returns usage percentage
  double get usagePercentage => (photoScansUsed / photoScansLimit) * 100;

  /// Creates a new entity with incremented scan count
  AIUsageEntity incrementScan() {
    return AIUsageEntity(
      userId: userId,
      date: date,
      photoScansUsed: photoScansUsed + 1,
      photoScansLimit: photoScansLimit,
      isPremium: isPremium,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        date,
        photoScansUsed,
        photoScansLimit,
        isPremium,
      ];
}
