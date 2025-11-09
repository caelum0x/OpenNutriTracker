import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/subscription/data/data_source/subscription_data_source.dart';
import 'package:opennutritracker/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:opennutritracker/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:opennutritracker/features/subscription/presentation/screens/paywall_screen.dart';

/// Premium feature names
class PremiumFeatures {
  static const String aiPhotoScan = 'ai_scan';
  static const String aiCoaching = 'ai_coaching';
  static const String advancedAnalytics = 'analytics';
  static const String fitnessSyncGoogle = 'fitness_sync_google';
  static const String fitnessSyncApple = 'fitness_sync_apple';
  static const String exportData = 'export_data';
  static const String customGoals = 'custom_goals';
}

/// Helper class to check and gate premium features
class PremiumFeatureGate {
  final SubscriptionDataSource subscriptionDataSource;

  PremiumFeatureGate({required this.subscriptionDataSource});

  /// Checks if user can access a feature
  /// Returns true if allowed, false if blocked
  bool canAccessFeature(String userId, String featureName) {
    return subscriptionDataSource.canUsePremiumFeature(userId, featureName);
  }

  /// Attempts to use a feature, showing paywall if needed
  /// Returns true if feature can be used, false if blocked
  Future<bool> requestFeatureAccess({
    required BuildContext context,
    required String userId,
    required String featureName,
    String? featureDisplayName,
  }) async {
    // Check if user can access
    if (canAccessFeature(userId, featureName)) {
      // If it's AI scan, increment usage
      if (featureName == PremiumFeatures.aiPhotoScan) {
        await subscriptionDataSource.incrementAIScan(userId);
      }
      return true;
    }

    // Show paywall
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<SubscriptionBloc>()
          ..add(LoadSubscription(userId: userId)),
        child: PaywallScreen(
          featureName: featureDisplayName ?? featureName,
        ),
      ),
    );

    return result == true;
  }

  /// Shows a simple premium badge
  Widget buildPremiumBadge({Color color = Colors.amber}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a lock icon for premium features
  Widget buildLockIcon({double size = 24, Color? color}) {
    return Icon(
      Icons.lock,
      size: size,
      color: color ?? Colors.grey[400],
    );
  }
}

/// Extension to make feature gating easier
extension PremiumFeatureGateContext on BuildContext {
  /// Quick access to feature gate
  Future<bool> requestPremiumFeature({
    required String userId,
    required String featureName,
    String? featureDisplayName,
  }) async {
    final gate = PremiumFeatureGate(
      subscriptionDataSource: SubscriptionDataSource(),
    );

    return await gate.requestFeatureAccess(
      context: this,
      userId: userId,
      featureName: featureName,
      featureDisplayName: featureDisplayName,
    );
  }
}

/// Widget wrapper that shows premium badge and gates access
class PremiumFeatureWidget extends StatelessWidget {
  final String userId;
  final String featureName;
  final String? featureDisplayName;
  final Widget child;
  final bool showBadge;
  final VoidCallback? onTap;

  const PremiumFeatureWidget({
    super.key,
    required this.userId,
    required this.featureName,
    this.featureDisplayName,
    required this.child,
    this.showBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gate = PremiumFeatureGate(
      subscriptionDataSource: SubscriptionDataSource(),
    );
    final canAccess = gate.canAccessFeature(userId, featureName);

    if (canAccess) {
      // User has access, show normal widget
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    // Show locked version
    return GestureDetector(
      onTap: () async {
        await gate.requestFeatureAccess(
          context: context,
          userId: userId,
          featureName: featureName,
          featureDisplayName: featureDisplayName,
        );
      },
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: child,
          ),
          if (showBadge)
            Positioned(
              top: 8,
              right: 8,
              child: gate.buildPremiumBadge(),
            ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Premium Feature',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to unlock',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
