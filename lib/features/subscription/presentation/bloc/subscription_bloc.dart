import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/subscription/data/data_source/in_app_purchase_data_source.dart';
import 'package:opennutritracker/features/subscription/data/data_source/subscription_data_source.dart';
import 'package:opennutritracker/features/subscription/domain/entity/subscription_entity.dart';
import 'package:opennutritracker/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:opennutritracker/features/subscription/presentation/bloc/subscription_state.dart';

/// BLoC for managing subscription state
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionDataSource subscriptionDataSource;
  final InAppPurchaseDataSource inAppPurchaseDataSource;
  final log = Logger('SubscriptionBloc');

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  String? _currentUserId;

  SubscriptionBloc({
    required this.subscriptionDataSource,
    required this.inAppPurchaseDataSource,
  }) : super(const SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
    on<LoadProducts>(_onLoadProducts);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<PurchaseUpdated>(_onPurchaseUpdated);
    on<CheckFeatureAccess>(_onCheckFeatureAccess);
    on<StartFreeTrial>(_onStartFreeTrial);

    // Initialize IAP and listen to purchase updates
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    final initialized = await inAppPurchaseDataSource.initialize();
    if (initialized) {
      _purchaseSubscription = inAppPurchaseDataSource.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          log.severe('Purchase stream error: $error');
        },
      );
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Complete the purchase
        inAppPurchaseDataSource.completePurchase(purchase);

        // Update subscription
        if (_currentUserId != null) {
          _updateSubscriptionFromPurchase(_currentUserId!, purchase);
        }

        add(PurchaseUpdated(
          productId: purchase.productID,
          success: true,
        ));
      } else if (purchase.status == PurchaseStatus.error) {
        log.warning('Purchase error: ${purchase.error}');
        add(PurchaseUpdated(
          productId: purchase.productID,
          success: false,
        ));
      }
    }
  }

  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    _currentUserId = event.userId;

    try {
      log.fine('Loading subscription for ${event.userId}');

      final subscription =
          subscriptionDataSource.getOrCreateSubscription(event.userId);
      final usage = subscriptionDataSource.getTodayUsage(event.userId);
      final products = await inAppPurchaseDataSource.getProducts();

      emit(SubscriptionLoaded(
        subscription: subscription,
        usage: usage,
        products: products,
      ));
    } catch (error, stackTrace) {
      log.severe('Error loading subscription', error, stackTrace);
      emit(SubscriptionError(
        message: 'Failed to load subscription: $error',
      ));
    }
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      log.fine('Loading subscription products');
      final products = await inAppPurchaseDataSource.getProducts();

      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(SubscriptionLoaded(
          subscription: currentState.subscription,
          usage: currentState.usage,
          products: products,
        ));
      }
    } catch (error, stackTrace) {
      log.severe('Error loading products', error, stackTrace);
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(PurchaseInProgress(productId: event.productId));

    try {
      log.fine('Initiating purchase for ${event.productId}');

      final success = await inAppPurchaseDataSource.purchaseProduct(
        event.productId,
      );

      if (!success) {
        emit(PurchaseFailed(
          message: 'Failed to initiate purchase',
          productId: event.productId,
        ));

        // Return to previous state
        if (_currentUserId != null) {
          add(LoadSubscription(userId: _currentUserId!));
        }
      }
    } catch (error, stackTrace) {
      log.severe('Error purchasing product', error, stackTrace);
      emit(PurchaseFailed(
        message: 'Purchase error: $error',
        productId: event.productId,
      ));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const RestoringPurchases());

    try {
      log.fine('Restoring purchases');
      await inAppPurchaseDataSource.restorePurchases();

      // Reload subscription after restore
      if (_currentUserId != null) {
        add(LoadSubscription(userId: _currentUserId!));
      }
    } catch (error, stackTrace) {
      log.severe('Error restoring purchases', error, stackTrace);
      emit(SubscriptionError(
        message: 'Failed to restore purchases: $error',
      ));
    }
  }

  Future<void> _onPurchaseUpdated(
    PurchaseUpdated event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (event.success && _currentUserId != null) {
      // Reload subscription to reflect new purchase
      add(LoadSubscription(userId: _currentUserId!));
    } else {
      emit(PurchaseFailed(
        message: 'Purchase was not successful',
        productId: event.productId,
      ));
    }
  }

  void _onCheckFeatureAccess(
    CheckFeatureAccess event,
    Emitter<SubscriptionState> emit,
  ) {
    if (_currentUserId == null) {
      emit(FeatureAccessDenied(
        featureName: event.featureName,
        message: 'User not logged in',
      ));
      return;
    }

    final canAccess = subscriptionDataSource.canUsePremiumFeature(
      _currentUserId!,
      event.featureName,
    );

    if (!canAccess) {
      final usage = subscriptionDataSource.getTodayUsage(_currentUserId!);
      emit(FeatureAccessDenied(
        featureName: event.featureName,
        message: 'You\'ve used ${usage.aiScansUsed}/${usage.aiScansLimit} free scans today. Upgrade to Premium for unlimited scans!',
      ));
    }
  }

  Future<void> _onStartFreeTrial(
    StartFreeTrial event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      log.fine('Starting free trial for ${event.userId}');

      final subscription =
          subscriptionDataSource.getOrCreateSubscription(event.userId);

      if (subscription.isTrialUsed) {
        emit(const SubscriptionError(
          message: 'Trial already used',
        ));
        return;
      }

      // Create trial subscription (7 days)
      final trialSubscription = subscription.copyWith(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.trial,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        isTrialUsed: true,
      );

      await subscriptionDataSource.saveSubscription(trialSubscription);

      // Reload
      add(LoadSubscription(userId: event.userId));
    } catch (error, stackTrace) {
      log.severe('Error starting trial', error, stackTrace);
      emit(SubscriptionError(
        message: 'Failed to start trial: $error',
      ));
    }
  }

  void _updateSubscriptionFromPurchase(
    String userId,
    PurchaseDetails purchase,
  ) {
    try {
      final subscription =
          subscriptionDataSource.getOrCreateSubscription(userId);

      // Determine expiry based on product
      final isYearly = purchase.productID.contains('yearly');
      final duration = isYearly ? 365 : 30;

      final updated = subscription.copyWith(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: duration)),
        productId: purchase.productID,
      );

      subscriptionDataSource.saveSubscription(updated);
      log.fine('Subscription updated from purchase');
    } catch (e, stackTrace) {
      log.severe('Error updating subscription from purchase', e, stackTrace);
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    inAppPurchaseDataSource.dispose();
    return super.close();
  }
}
