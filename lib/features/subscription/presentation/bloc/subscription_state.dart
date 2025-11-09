import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/subscription/domain/entity/subscription_entity.dart';

/// States for Subscription BLoC
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

/// Loading state
class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

/// Loaded subscription state
class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionEntity subscription;
  final PremiumUsageEntity usage;
  final List<SubscriptionProductEntity> products;

  const SubscriptionLoaded({
    required this.subscription,
    required this.usage,
    required this.products,
  });

  bool get isPremium => subscription.canAccessPremiumFeatures;
  bool get canUseAIScan => isPremium || usage.canUseAIScan;

  @override
  List<Object?> get props => [subscription, usage, products];
}

/// Purchase in progress
class PurchaseInProgress extends SubscriptionState {
  final String productId;

  const PurchaseInProgress({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Purchase successful
class PurchaseSuccess extends SubscriptionState {
  final SubscriptionEntity subscription;
  final String productId;

  const PurchaseSuccess({
    required this.subscription,
    required this.productId,
  });

  @override
  List<Object?> get props => [subscription, productId];
}

/// Purchase failed
class PurchaseFailed extends SubscriptionState {
  final String message;
  final String? productId;

  const PurchaseFailed({
    required this.message,
    this.productId,
  });

  @override
  List<Object?> get props => [message, productId];
}

/// Restoring purchases
class RestoringPurchases extends SubscriptionState {
  const RestoringPurchases();
}

/// Purchases restored
class PurchasesRestored extends SubscriptionState {
  final SubscriptionEntity subscription;
  final int restoredCount;

  const PurchasesRestored({
    required this.subscription,
    required this.restoredCount,
  });

  @override
  List<Object?> get props => [subscription, restoredCount];
}

/// Error state
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Feature access denied (need premium)
class FeatureAccessDenied extends SubscriptionState {
  final String featureName;
  final String message;

  const FeatureAccessDenied({
    required this.featureName,
    required this.message,
  });

  @override
  List<Object?> get props => [featureName, message];
}
