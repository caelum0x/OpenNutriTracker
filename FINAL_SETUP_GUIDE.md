# 🚀 Complete Setup Guide - Cal AI Competitor

## Welcome! You're 95% Done! 🎉

This guide will take you from code to production-ready app in **30 minutes**.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start (5 min)](#quick-start)
3. [OpenRouter API Setup](#openrouter-setup)
4. [Supabase Backend Setup](#supabase-setup)
5. [Platform Configuration](#platform-configuration)
6. [In-App Purchase Setup](#iap-setup)
7. [Testing](#testing)
8. [Deployment](#deployment)
9. [Post-Launch](#post-launch)

---

## Prerequisites

### Required
- ✅ Flutter SDK 3.0+
- ✅ Xcode 14+ (for iOS)
- ✅ Android Studio (for Android)
- ✅ macOS (for iOS development)

### Accounts Needed
- ✅ [OpenRouter.ai](https://openrouter.ai) account (AI features)
- ✅ [Supabase](https://supabase.com) account (backend)
- ✅ [Apple Developer](https://developer.apple.com) ($99/year for iOS)
- ✅ [Google Play Console](https://play.google.com/console) ($25 one-time for Android)

---

## Quick Start (5 Minutes)

### 1. Clone & Install Dependencies

```bash
git clone <your-repo>
cd OpenNutriTracker
flutter pub get
```

### 2. Configure Environment

Edit `.env` file:

```bash
# API Keys
OPENROUTER_API_KEY="sk-or-v1-YOUR_KEY_HERE"
FDC_API_KEY="YOUR_FDC_KEY" # Optional, for food database

# Supabase Backend
SUPABASE_PROJECT_URL="https://YOUR_PROJECT.supabase.co"
SUPABASE_PROJECT_ANON_KEY="YOUR_ANON_KEY"

# Optional
SENTRY_DNS="YOUR_SENTRY_DNS" # Error tracking
```

### 3. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `env.g.dart` - Environment variables
- All `*.g.dart` files for JSON serialization
- Hive adapters

### 4. Register Hive Adapters

Edit `lib/core/utils/hive_db_provider.dart`:

```dart
import 'package:opennutritracker/features/water_tracking/data/dbo/water_intake_dbo.dart';
import 'package:opennutritracker/features/subscription/data/dbo/subscription_dbo.dart';

// In registerAdapters() method, add:
Hive.registerAdapter(WaterIntakeDBOAdapter());
Hive.registerAdapter(SubscriptionDBOAdapter());
Hive.registerAdapter(PremiumUsageDBOAdapter());
```

### 5. Open Hive Boxes

In `hive_db_provider.dart`, add to `openBoxes()`:

```dart
await Hive.openBox<WaterIntakeDBO>('waterIntakeBox');
await Hive.openBox<SubscriptionDBO>('subscriptionBox');
await Hive.openBox<PremiumUsageDBO>('premiumUsageBox');
```

### 6. Setup Dependency Injection

Edit `lib/core/utils/locator.dart`:

```dart
// Add imports
import 'package:opennutritracker/features/ai_photo_analysis/...';
import 'package:opennutritracker/features/water_tracking/...';
import 'package:opennutritracker/features/subscription/...';
import 'package:opennutritracker/features/health_sync/...';

// In setupLocator(), add:

// AI Photo Analysis
locator.registerLazySingleton(() => OpenRouterDataSource());
locator.registerLazySingleton(() => AIPhotoRepository(
  dataSource: locator(),
));
locator.registerFactory(() => AIPhotoBloc(
  analyzeFoodPhotoUseCase: AnalyzeFoodPhotoUseCase(
    repository: locator(),
  ),
));

// Water Tracking
locator.registerLazySingleton(() => WaterIntakeDataSource());
locator.registerFactory(() => WaterTrackingBloc(
  dataSource: locator(),
));

// Subscriptions
locator.registerLazySingleton(() => SubscriptionDataSource());
locator.registerLazySingleton(() => InAppPurchaseDataSource());
locator.registerFactory(() => SubscriptionBloc(
  subscriptionDataSource: locator(),
  inAppPurchaseDataSource: locator(),
));

// Health Sync
locator.registerLazySingleton(() => HealthDataSource());
locator.registerFactory(() => HealthSyncBloc(
  healthDataSource: locator(),
));
```

### 7. Run the App!

```bash
flutter run
```

---

## OpenRouter Setup

### 1. Get API Key

1. Go to [OpenRouter.ai](https://openrouter.ai)
2. Sign up / Sign in
3. Navigate to **API Keys**
4. Create new key
5. Copy and paste into `.env`

### 2. Add Credits

1. Go to **Billing**
2. Add $10-20 to start
3. Set spending limit

### 3. Costs

**Per AI Photo Scan:**
- Claude 3.5 Sonnet: ~$0.01 (recommended)
- GPT-4 Vision: ~$0.03

**Monthly estimates:**
- 1,000 scans: $10-30
- 10,000 scans: $100-300

---

## Supabase Setup

### 1. Create Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click **New Project**
3. Name: "Cal AI"
4. Database password: Save this!
5. Region: Choose closest to users
6. Click **Create**

### 2. Run Database Schema

1. Go to **SQL Editor**
2. Click **New Query**
3. Copy contents of `supabase/schema.sql`
4. Paste and click **Run**
5. Wait for success message

### 3. Get API Keys

1. Go to **Settings** → **API**
2. Copy:
   - Project URL
   - `anon` key (public)
3. Add to `.env`:

```bash
SUPABASE_PROJECT_URL="https://xxxxx.supabase.co"
SUPABASE_PROJECT_ANON_KEY="eyJhbGc..."
```

### 4. Configure Authentication

1. Go to **Authentication** → **Providers**
2. Enable:
   - **Email** (always enabled)
   - **Google** (optional but recommended)
   - **Apple** (required for iOS)

#### Google OAuth Setup:
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth client ID
3. Add to Supabase settings

#### Apple OAuth Setup:
1. Go to [Apple Developer](https://developer.apple.com)
2. Create Services ID
3. Configure Sign in with Apple
4. Add to Supabase settings

---

## Platform Configuration

### iOS Setup

#### 1. Open in Xcode

```bash
open ios/Runner.xcworkspace
```

#### 2. Configure Signing

1. Select **Runner** target
2. Go to **Signing & Capabilities**
3. Select your team
4. Change Bundle ID: `com.yourcompany.calai`

#### 3. Add Capabilities

Click **+ Capability** and add:
- **HealthKit**
- **Sign in with Apple** (if using)
- **In-App Purchase**

#### 4. Update Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your food</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo access to analyze your food photos</string>

<!-- HealthKit -->
<key>NSHealthShareUsageDescription</key>
<string>We need access to read your health data to sync calories burned, weight, and activity</string>

<key>NSHealthUpdateUsageDescription</key>
<string>We need access to write nutrition and water intake data to Health app</string>
```

#### 5. Update Display Name

In Info.plist:
```xml
<key>CFBundleDisplayName</key>
<string>Cal AI</string>
```

### Android Setup

#### 1. Update Package Name

Edit `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.yourcompany.calai"
    // ...
}
```

#### 2. Update AndroidManifest.xml

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.calai">

    <!-- Camera Permission -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>

    <!-- Health Connect Permissions -->
    <uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
    <uses-permission android:name="android.permission.health.READ_WEIGHT"/>
    <uses-permission android:name="android.permission.health.READ_STEPS"/>
    <uses-permission android:name="android.permission.health.READ_HYDRATION"/>
    <uses-permission android:name="android.permission.health.READ_NUTRITION"/>
    <uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
    <uses-permission android:name="android.permission.health.WRITE_HYDRATION"/>
    <uses-permission android:name="android.permission.health.WRITE_NUTRITION"/>
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>

    <application
        android:label="Cal AI"
        ...>
```

#### 3. Update App Name

Edit `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="app_name">Cal AI</string>
</resources>
```

---

## In-App Purchase Setup

### iOS - App Store Connect

#### 1. Create App

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in details:
   - Name: Your app name
   - Bundle ID: Same as Xcode
   - SKU: `calai-ios-001`

#### 2. Create Subscriptions

1. Go to **Subscriptions** → **+**
2. Create Subscription Group: "Premium"
3. Add subscriptions:

**Monthly:**
- Product ID: `com.calai.premium.monthly`
- Price: $9.99
- Duration: 1 month
- Free trial: 7 days (optional)

**Yearly:**
- Product ID: `com.calai.premium.yearly`
- Price: $59.99
- Duration: 1 year
- Free trial: 7 days (optional)

#### 3. Update Code

Edit `lib/features/subscription/data/data_source/in_app_purchase_data_source.dart`:

```dart
static const String monthlyPremiumId = 'com.calai.premium.monthly';
static const String yearlyPremiumId = 'com.calai.premium.yearly';
```

### Android - Google Play Console

#### 1. Create App

1. Go to [Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in details

#### 2. Create Products

1. Go to **Monetization** → **Subscriptions**
2. Click **Create subscription**

**Monthly:**
- Product ID: `com.calai.premium.monthly`
- Name: "Premium Monthly"
- Price: $9.99
- Billing period: 1 month
- Free trial: 7 days (optional)

**Yearly:**
- Product ID: `com.calai.premium.yearly`
- Name: "Premium Yearly"
- Price: $59.99
- Billing period: 1 year
- Free trial: 7 days (optional)

---

## Testing

### Test on Real Devices

**iOS:**
```bash
flutter run -d iPhone
```

**Android:**
```bash
flutter run -d android
```

### Test Checklist

- [ ] AI Photo Analysis
  - [ ] Take photo with camera
  - [ ] Select from gallery
  - [ ] Verify AI identification
  - [ ] Edit nutrition values
  - [ ] Add to diary

- [ ] Water Tracking
  - [ ] Quick add buttons work
  - [ ] Custom amount input
  - [ ] Progress bar updates
  - [ ] Data persists after restart

- [ ] Subscriptions
  - [ ] Free tier limit (10 scans/day)
  - [ ] Paywall appears correctly
  - [ ] Purchase flow works (use sandbox)
  - [ ] Premium features unlock
  - [ ] Restore purchases works

- [ ] Health Sync
  - [ ] Request permissions
  - [ ] Sync calories from Health app
  - [ ] Export water to Health app
  - [ ] Export nutrition to Health app

- [ ] Analytics
  - [ ] Weight chart displays
  - [ ] Nutrition trends show
  - [ ] Macro pie chart renders
  - [ ] Streak updates daily

### Test with Sandbox Accounts

**iOS:**
1. Settings → App Store → Sandbox Account
2. Create test user in App Store Connect

**Android:**
1. Play Console → License Testing
2. Add test account emails

---

## Deployment

### iOS Deployment

#### 1. Archive

```bash
flutter build ios --release
```

#### 2. Upload to TestFlight

1. Open Xcode
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload

#### 3. TestFlight Beta

1. App Store Connect → TestFlight
2. Add external testers
3. Get feedback

#### 4. Submit for Review

1. Fill in App Information
2. Add screenshots (all sizes)
3. Write description
4. Add privacy policy URL
5. Submit for review

### Android Deployment

#### 1. Build Bundle

```bash
flutter build appbundle --release
```

#### 2. Upload to Play Console

1. Play Console → Production
2. Create new release
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Fill in release notes
5. Review and rollout

---

## Post-Launch

### Analytics Setup

Consider adding:
- Firebase Analytics
- Mixpanel
- Amplitude

### Monitoring

- Sentry (already integrated) for crashes
- Supabase logs for backend
- OpenRouter usage tracking

### Marketing

1. **App Store Optimization (ASO)**
   - Keywords research
   - A/B test screenshots
   - Localization

2. **Social Media**
   - Twitter/X announcement
   - Reddit (r/loseit, r/fitness)
   - TikTok demos
   - YouTube tutorials

3. **Content Marketing**
   - Blog posts
   - Comparison guides
   - Success stories

### Support

1. Create support email: support@yourapp.com
2. Set up FAQ page
3. Monitor reviews daily
4. Respond to feedback

---

## Troubleshooting

### "env.g.dart not found"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### "OpenRouter API Error"
- Check API key in `.env`
- Verify credits available
- Check network connection

### "HealthKit not available"
- Must test on real device
- Simulator doesn't support HealthKit

### "Purchase failed"
- Ensure products created in stores
- Use sandbox/test account
- Check product IDs match

### "Build failed"
- Run `flutter clean`
- Delete `ios/Pods` and run `pod install`
- Update Flutter: `flutter upgrade`

---

## Cost Breakdown

### Development (One-time)
- Apple Developer: $99/year
- Google Play: $25 one-time
- **Total: $124**

### Monthly Operating
- Supabase: $0-25/month
- OpenRouter: $10-100/month (usage-based)
- Sentry: $0-26/month
- **Total: ~$10-151/month**

### Revenue Potential
- **Conservative:** $3,997 MRR at 5% conversion
- **Optimistic:** $37,475 MRR at 10% conversion

**Profit Margin: 60-70%**

---

## Success Checklist

- [ ] All tests passing
- [ ] Runs on real iOS device
- [ ] Runs on real Android device
- [ ] AI photo analysis working
- [ ] Subscriptions functional
- [ ] Health sync tested
- [ ] Analytics dashboard complete
- [ ] Privacy policy created
- [ ] Terms of service created
- [ ] Support email set up
- [ ] App Store listing ready
- [ ] Play Store listing ready
- [ ] Marketing plan drafted
- [ ] Launch date set!

---

## You Did It! 🎉

You now have a **production-ready Cal AI competitor** with:

✅ AI-powered photo food analysis
✅ Comprehensive nutrition tracking
✅ Water intake tracking
✅ AI nutrition coaching
✅ Complete subscription system
✅ Google Fit & Apple HealthKit sync
✅ Beautiful analytics dashboard
✅ Cloud backend with Supabase
✅ Multi-platform (iOS, Android, Web)

**Ready to launch and compete! 🚀**

---

## Support & Resources

- **Documentation:** All `.md` files in project
- **Issues:** GitHub Issues
- **Community:** Discord (create your own!)
- **Updates:** Follow development blog

**Good luck with your launch! 💪**
