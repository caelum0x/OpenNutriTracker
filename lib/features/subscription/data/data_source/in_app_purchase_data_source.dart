import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/subscription/domain/entity/subscription_entity.dart';

/// Data source for In-App Purchases
class InAppPurchaseDataSource {
  final log = Logger('InAppPurchaseDataSource');
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Product IDs - Configure these in App Store Connect / Play Console
  static const String monthlyPremiumId = 'com.calai.premium.monthly';
  static const String yearlyPremiumId = 'com.calai.premium.yearly';

  Stream<List<PurchaseDetails>>? _purchaseStream;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Initializes the in-app purchase system
  Future<bool> initialize() async {
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        log.warning('In-app purchases not available');
        return false;
      }

      log.fine('In-app purchase system initialized');
      return true;
    } catch (e, stackTrace) {
      log.severe('Error initializing IAP', e, stackTrace);
      return false;
    }
  }

  /// Gets available subscription products
  Future<List<SubscriptionProductEntity>> getProducts() async {
    try {
      final productIds = {monthlyPremiumId, yearlyPremiumId};
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        log.warning('Error querying products: ${response.error}');
        return _getDefaultProducts(); // Return default for testing
      }

      if (response.productDetails.isEmpty) {
        log.warning('No products found');
        return _getDefaultProducts();
      }

      return response.productDetails.map((product) {
        final isYearly = product.id == yearlyPremiumId;
        return SubscriptionProductEntity(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          currencyCode: product.currencyCode,
          rawPrice: double.tryParse(product.rawPrice.toString()) ?? 0,
          tier: SubscriptionTier.premium,
          duration: isYearly ? const Duration(days: 365) : const Duration(days: 30),
          features: _getPremiumFeatures(),
          isPopular: isYearly, // Yearly is popular choice
          discount: isYearly ? 40 : null, // 40% off for yearly
        );
      }).toList();
    } catch (e, stackTrace) {
      log.severe('Error getting products', e, stackTrace);
      return _getDefaultProducts();
    }
  }

  /// Starts a purchase flow
  Future<bool> purchaseProduct(String productId) async {
    try {
      final productIds = {productId};
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.productDetails.isEmpty) {
        log.warning('Product not found: $productId');
        return false;
      }

      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);

      log.fine('Starting purchase for: $productId');
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e, stackTrace) {
      log.severe('Error purchasing product', e, stackTrace);
      return false;
    }
  }

  /// Restores previous purchases
  Future<List<PurchaseDetails>> restorePurchases() async {
    try {
      log.fine('Restoring purchases');
      await _inAppPurchase.restorePurchases();

      // The restored purchases will come through the purchase stream
      return [];
    } catch (e, stackTrace) {
      log.severe('Error restoring purchases', e, stackTrace);
      return [];
    }
  }

  /// Listens to purchase updates
  Stream<List<PurchaseDetails>> get purchaseStream {
    _purchaseStream ??= _inAppPurchase.purchaseStream;
    return _purchaseStream!;
  }

  /// Completes a purchase (mark as delivered)
  Future<void> completePurchase(PurchaseDetails purchase) async {
    try {
      await _inAppPurchase.completePurchase(purchase);
      log.fine('Purchase completed: ${purchase.productID}');
    } catch (e, stackTrace) {
      log.severe('Error completing purchase', e, stackTrace);
    }
  }

  /// Returns default products for testing/development
  List<SubscriptionProductEntity> _getDefaultProducts() {
    return [
      SubscriptionProductEntity(
        id: monthlyPremiumId,
        title: 'Premium Monthly',
        description: 'Unlimited AI scans and all premium features',
        price: '\$9.99',
        currencyCode: 'USD',
        rawPrice: 9.99,
        tier: SubscriptionTier.premium,
        duration: const Duration(days: 30),
        features: _getPremiumFeatures(),
        isPopular: false,
      ),
      SubscriptionProductEntity(
        id: yearlyPremiumId,
        title: 'Premium Yearly',
        description: 'Best value - Save 40%',
        price: '\$59.99',
        currencyCode: 'USD',
        rawPrice: 59.99,
        tier: SubscriptionTier.premium,
        duration: const Duration(days: 365),
        features: _getPremiumFeatures(),
        isPopular: true,
        discount: 40,
      ),
    ];
  }

  List<String> _getPremiumFeatures() {
    return [
      'Unlimited AI photo scans',
      'AI nutrition coaching',
      'Advanced analytics & insights',
      'Fitness app integrations',
      'Export data (CSV/PDF)',
      'Ad-free experience',
      'Priority support',
      'Early access to new features',
    ];
  }

  /// Disposes resources
  void dispose() {
    _subscription?.cancel();
  }
}
