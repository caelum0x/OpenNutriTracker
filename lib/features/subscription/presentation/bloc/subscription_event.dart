import 'package:equatable/equatable.dart';

/// Events for Subscription BLoC
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load subscription status
class LoadSubscription extends SubscriptionEvent {
  final String userId;

  const LoadSubscription({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load available products
class LoadProducts extends SubscriptionEvent {
  const LoadProducts();
}

/// Event to purchase a product
class PurchaseProduct extends SubscriptionEvent {
  final String productId;

  const PurchaseProduct({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Event to restore purchases
class RestorePurchases extends SubscriptionEvent {
  const RestorePurchases();
}

/// Event when purchase is updated
class PurchaseUpdated extends SubscriptionEvent {
  final String productId;
  final bool success;

  const PurchaseUpdated({
    required this.productId,
    required this.success,
  });

  @override
  List<Object?> get props => [productId, success];
}

/// Event to check premium feature access
class CheckFeatureAccess extends SubscriptionEvent {
  final String featureName;

  const CheckFeatureAccess({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

/// Event to start free trial
class StartFreeTrial extends SubscriptionEvent {
  final String userId;

  const StartFreeTrial({required this.userId});

  @override
  List<Object?> get props => [userId];
}
