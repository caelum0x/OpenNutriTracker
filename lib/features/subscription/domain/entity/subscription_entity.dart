import 'package:equatable/equatable.dart';

/// Subscription tier levels
enum SubscriptionTier {
  free,
  premium,
  premiumPlus, // Future expansion
}

/// Subscription status
enum SubscriptionStatus {
  active,
  expired,
  canceled,
  trial,
  pending,
}

/// Domain entity for user subscription
class SubscriptionEntity extends Equatable {
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final bool isTrialUsed;
  final String? productId;

  const SubscriptionEntity({
    required this.userId,
    required this.tier,
    required this.status,
    this.expiresAt,
    this.startedAt,
    required this.isTrialUsed,
    this.productId,
  });

  /// Returns true if user has active premium subscription
  bool get isPremium =>
      tier != SubscriptionTier.free &&
      (status == SubscriptionStatus.active || status == SubscriptionStatus.trial);

  /// Returns true if subscription is expired
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Returns days remaining in subscription
  int? get daysRemaining {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns true if user is on trial
  bool get isTrial => status == SubscriptionStatus.trial;

  /// Returns true if user can access premium features
  bool get canAccessPremiumFeatures => isPremium && !isExpired;

  @override
  List<Object?> get props => [
        userId,
        tier,
        status,
        expiresAt,
        startedAt,
        isTrialUsed,
        productId,
      ];

  /// Creates a copy with updated fields
  SubscriptionEntity copyWith({
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? expiresAt,
    DateTime? startedAt,
    bool? isTrialUsed,
    String? productId,
  }) {
    return SubscriptionEntity(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      startedAt: startedAt ?? this.startedAt,
      isTrialUsed: isTrialUsed ?? this.isTrialUsed,
      productId: productId ?? this.productId,
    );
  }
}

/// Entity for subscription products/pricing
class SubscriptionProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final double rawPrice;
  final SubscriptionTier tier;
  final Duration duration; // Monthly, yearly
  final List<String> features;
  final bool isPopular;
  final double? discount; // Percentage discount if applicable

  const SubscriptionProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.rawPrice,
    required this.tier,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.discount,
  });

  /// Returns monthly equivalent price
  double get monthlyPrice {
    final months = duration.inDays / 30;
    return rawPrice / months;
  }

  /// Returns savings percentage compared to another product
  double savingsPercentage(SubscriptionProductEntity other) {
    final thisMonthly = monthlyPrice;
    final otherMonthly = other.monthlyPrice;
    return ((otherMonthly - thisMonthly) / otherMonthly * 100);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        currencyCode,
        rawPrice,
        tier,
        duration,
        features,
        isPopular,
        discount,
      ];
}

/// Entity for tracking premium feature usage
class PremiumUsageEntity extends Equatable {
  final String userId;
  final DateTime date;
  final int aiScansUsed;
  final int aiScansLimit;
  final Map<String, int> featureUsage; // Track other features

  const PremiumUsageEntity({
    required this.userId,
    required this.date,
    required this.aiScansUsed,
    required this.aiScansLimit,
    required this.featureUsage,
  });

  /// Returns true if user can use AI scan
  bool get canUseAIScan => aiScansUsed < aiScansLimit;

  /// Returns remaining AI scans
  int get remainingScans => aiScansLimit - aiScansUsed;

  /// Returns usage percentage
  double get usagePercentage => (aiScansUsed / aiScansLimit * 100);

  /// Creates updated entity with incremented scan
  PremiumUsageEntity incrementScan() {
    return PremiumUsageEntity(
      userId: userId,
      date: date,
      aiScansUsed: aiScansUsed + 1,
      aiScansLimit: aiScansLimit,
      featureUsage: featureUsage,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        date,
        aiScansUsed,
        aiScansLimit,
        featureUsage,
      ];
}
