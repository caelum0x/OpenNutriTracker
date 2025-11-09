import 'package:hive/hive.dart';

part 'subscription_dbo.g.dart';

/// Database object for subscription (Hive)
@HiveType(typeId: 21)
class SubscriptionDBO extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String tier; // free, premium, premiumPlus

  @HiveField(2)
  String status; // active, expired, canceled, trial, pending

  @HiveField(3)
  DateTime? expiresAt;

  @HiveField(4)
  DateTime? startedAt;

  @HiveField(5)
  bool isTrialUsed;

  @HiveField(6)
  String? productId;

  SubscriptionDBO({
    required this.userId,
    required this.tier,
    required this.status,
    this.expiresAt,
    this.startedAt,
    required this.isTrialUsed,
    this.productId,
  });
}

/// Database object for premium usage tracking
@HiveType(typeId: 22)
class PremiumUsageDBO extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int aiScansUsed;

  @HiveField(3)
  int aiScansLimit;

  @HiveField(4)
  Map<String, int> featureUsage;

  PremiumUsageDBO({
    required this.userId,
    required this.date,
    required this.aiScansUsed,
    required this.aiScansLimit,
    required this.featureUsage,
  });
}
