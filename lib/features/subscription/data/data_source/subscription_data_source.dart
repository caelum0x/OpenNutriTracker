import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/subscription/data/dbo/subscription_dbo.dart';
import 'package:opennutritracker/features/subscription/domain/entity/subscription_entity.dart';

/// Data source for subscription management (Hive)
class SubscriptionDataSource {
  static const String subscriptionBoxName = 'subscriptionBox';
  static const String usageBoxName = 'premiumUsageBox';
  final log = Logger('SubscriptionDataSource');

  Box<SubscriptionDBO> get _subscriptionBox =>
      Hive.box<SubscriptionDBO>(subscriptionBoxName);
  Box<PremiumUsageDBO> get _usageBox =>
      Hive.box<PremiumUsageDBO>(usageBoxName);

  /// Gets subscription for user
  SubscriptionEntity? getSubscription(String userId) {
    try {
      final dbo = _subscriptionBox.get(userId);
      if (dbo == null) return null;

      return _mapDboToEntity(dbo);
    } catch (e, stackTrace) {
      log.severe('Error getting subscription', e, stackTrace);
      return null;
    }
  }

  /// Saves subscription
  Future<void> saveSubscription(SubscriptionEntity subscription) async {
    try {
      final dbo = _mapEntityToDbo(subscription);
      await _subscriptionBox.put(subscription.userId, dbo);
      log.fine('Saved subscription for ${subscription.userId}');
    } catch (e, stackTrace) {
      log.severe('Error saving subscription', e, stackTrace);
      rethrow;
    }
  }

  /// Gets or creates default free subscription
  SubscriptionEntity getOrCreateSubscription(String userId) {
    final existing = getSubscription(userId);
    if (existing != null) return existing;

    // Create default free subscription
    final defaultSub = SubscriptionEntity(
      userId: userId,
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.active,
      isTrialUsed: false,
    );

    saveSubscription(defaultSub);
    return defaultSub;
  }

  /// Gets premium usage for today
  PremiumUsageEntity getTodayUsage(String userId) {
    try {
      final today = DateTime.now();
      final key = '${userId}_${today.year}_${today.month}_${today.day}';
      final dbo = _usageBox.get(key);

      if (dbo != null) {
        return PremiumUsageEntity(
          userId: dbo.userId,
          date: dbo.date,
          aiScansUsed: dbo.aiScansUsed,
          aiScansLimit: dbo.aiScansLimit,
          featureUsage: dbo.featureUsage,
        );
      }

      // Create default usage for today
      final subscription = getOrCreateSubscription(userId);
      final limit = subscription.isPremium ? 999999 : 10; // Unlimited for premium

      return PremiumUsageEntity(
        userId: userId,
        date: today,
        aiScansUsed: 0,
        aiScansLimit: limit,
        featureUsage: {},
      );
    } catch (e, stackTrace) {
      log.severe('Error getting usage', e, stackTrace);
      // Return safe default
      return PremiumUsageEntity(
        userId: userId,
        date: DateTime.now(),
        aiScansUsed: 0,
        aiScansLimit: 10,
        featureUsage: {},
      );
    }
  }

  /// Saves premium usage
  Future<void> saveUsage(PremiumUsageEntity usage) async {
    try {
      final key =
          '${usage.userId}_${usage.date.year}_${usage.date.month}_${usage.date.day}';
      final dbo = PremiumUsageDBO(
        userId: usage.userId,
        date: usage.date,
        aiScansUsed: usage.aiScansUsed,
        aiScansLimit: usage.aiScansLimit,
        featureUsage: usage.featureUsage,
      );
      await _usageBox.put(key, dbo);
      log.fine('Saved usage for ${usage.userId}');
    } catch (e, stackTrace) {
      log.severe('Error saving usage', e, stackTrace);
      rethrow;
    }
  }

  /// Increments AI scan usage
  Future<PremiumUsageEntity> incrementAIScan(String userId) async {
    final usage = getTodayUsage(userId);
    final updated = usage.incrementScan();
    await saveUsage(updated);
    return updated;
  }

  /// Checks if user can use premium feature
  bool canUsePremiumFeature(String userId, String featureName) {
    final subscription = getOrCreateSubscription(userId);

    // Premium users can use all features
    if (subscription.canAccessPremiumFeatures) return true;

    // Check feature-specific limits for free users
    if (featureName == 'ai_scan') {
      final usage = getTodayUsage(userId);
      return usage.canUseAIScan;
    }

    return false;
  }

  /// Maps DBO to Entity
  SubscriptionEntity _mapDboToEntity(SubscriptionDBO dbo) {
    return SubscriptionEntity(
      userId: dbo.userId,
      tier: _parseTier(dbo.tier),
      status: _parseStatus(dbo.status),
      expiresAt: dbo.expiresAt,
      startedAt: dbo.startedAt,
      isTrialUsed: dbo.isTrialUsed,
      productId: dbo.productId,
    );
  }

  /// Maps Entity to DBO
  SubscriptionDBO _mapEntityToDbo(SubscriptionEntity entity) {
    return SubscriptionDBO(
      userId: entity.userId,
      tier: entity.tier.name,
      status: entity.status.name,
      expiresAt: entity.expiresAt,
      startedAt: entity.startedAt,
      isTrialUsed: entity.isTrialUsed,
      productId: entity.productId,
    );
  }

  SubscriptionTier _parseTier(String tier) {
    switch (tier) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'premiumPlus':
        return SubscriptionTier.premiumPlus;
      default:
        return SubscriptionTier.free;
    }
  }

  SubscriptionStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'trial':
        return SubscriptionStatus.trial;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.active;
    }
  }
}
